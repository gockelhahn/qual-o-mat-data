#!/bin/bash
#
# extract opinions from pdf versions
#
# positive = 0
# negative = 1
# neutral = 2

###
# hint: gocr has an issue when one line
# starts/consists of unrecognized chars ("2") for the most part
# it will skip/remove it from the result
# (e.g. PositionsvergleichSchleswigHolstein2017)
#
# run the "gocr" command manually, insert missing line, save as txt,
# change the script that the file is read instead and execute again
###

PDF_EXT=".pdf"
STATEMENTS="38"

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "ERROR: Script directory could not be detected. Abort!" >&2 && exit 1
PDF_DIR="$SCRIPT_DIR/pdf"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR"/../template && pwd)"

( ! which pdf2htmlEX &>/dev/null) && echo "ERROR: Command \"pdf2htmlEX\" not available. Abort!" >&2 && exit 1
( ! which convert &>/dev/null) && echo "ERROR: Command \"convert\" not available. Abort!" >&2 && exit 1
( ! which gocr &>/dev/null) && echo "ERROR: Command \"gocr\" not available. Abort!" >&2 && exit 1
( ! which sed &>/dev/null) && echo "ERROR: Command \"sed\" not available. Abort!" >&2 && exit 1

function is_legacy() {
    case "$1" in
        "PositionsvergleichHamburg2011")
            ;&
        "PositionsvergleichBadenWuerttemberg2011")
            ;&
        "PositionsvergleichRheinlandPfalz2011")
            ;&
        "PositionsvergleichBremen2011")
            ;&
        "PositionsvergleichNiedersachsen2013")
            ;&
        "PositionsvergleichNordrheinWestfalen2012")
            ;&
        "PositionsvergleichSaarland2012")
            ;&
        "PositionsvergleichSchleswigHolstein2012")
            ;&
        "PositionsvergleichBerlin2011")
            echo "Use legacy design"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# loop over all found zip files (offline versions)
for pdffilename in `ls -1v "$PDF_DIR"/*"$PDF_EXT"`
do
    cd "$PDF_DIR"
    
    filebase="`basename --suffix="$PDF_EXT" "$pdffilename"`"
    filebase_dir="$PDF_DIR/$filebase"
    result_opinion="$filebase_dir/opinion.json"
    
    # create folder for each pdf and convert into html + images
    mkdir -p "$filebase_dir"
    cd "$filebase_dir"
    pdf2htmlEX --embed-image 0 "$pdffilename" tmp.html &>/dev/null
    
    # write json header
    echo "[" > "$result_opinion"
    images="`ls -1v bg*.png`"
    inum="`echo "$images" | wc -l`"
    if is_legacy "$filebase"
    then
        for ((i=1; i < $inum; i++ ))
        do
            # assemble image name
            image="`echo "$images" | sed -n ${i}p`"
            # chop image top/left/bottom to just show opinions
            convert "$image" -chop 700x310 +repage "$image"
            convert "$image" -gravity South -chop 0x65 +repage "vertical$i.png"
        done
    else
        for image in $images
        do
            # chop image top/left/bottom to just show opinions
            convert "$image" -chop 600x77 +repage "$image"
            convert "$image" -gravity South -chop 0x57 +repage "$image"
            # exception for hamburg as dimensions slightly moved
            if `pwd | grep -q "Hamburg2015"` && [ "$image" == bg5.png ]
            then
                convert "$image" -chop 0x11 +repage "$image"
            fi
        done
    fi
    
    if ! is_legacy "$filebase"
    then
        split=false
        for ((i=1; i <= $inum; i++ ))
        do
            # assemble image name
            image1="`echo "$images" | sed -n ${i}p`"
            image2="`echo "$images" | sed -n $(( $i + 1 ))p`"
            
            # set variable if the pdf opinions are one one page or split
            if [ $i -eq 1 ]
            then
                # scan image and count lines (statements)
                lines="`gocr -l 200 -p "$SCRIPT_DIR/db/" -m 258 -a 50 -u 2 -i "$image1" | grep -v ^$ | tr -d " \t" | tail -n +2 | wc -l`"
                if [ "$lines" -lt "$STATEMENTS" ]
                then
                    split=true
                else
                    split=false
                fi
            fi
            
            if $split
            then
                if [ $(( $i % 2 )) -eq 1 ] && [ $i -ne $inum ]
                then
                    # if page is split, merge two of them vertically
                    final="vertical$(( $i / 2 )).png"
                    convert -append "$image1" "$image2" "$final"
                fi
            else
                # if all on one page, just copy
                final="vertical$i.png"
                cp -f "$image1" "$final"
            fi
        done
    fi
    # merge all vertical pages horizontally
    convert +append vertical*.png horizontal.png
    # scan image and save opinions
    opinions="`gocr -l 200 -p "$SCRIPT_DIR/db/" -m 258 -a 50 -u 2 -i horizontal.png | grep -v ^$ | tr -d " \t"`"
    if ! is_legacy "$filebase"
    then
        opinions="`echo "$opinions" | tail -n +2`"
    fi
    lines="`echo "$opinions" | wc -l`"
    parties="`echo "$opinions" | wc -L`"
    pcounter=0
    ocounter=0
    
    # check if lines are same size as statements
    if [ "$lines" -ne "$STATEMENTS" ]
    then
        echo "ERROR: OCR failed for $pdffilename." >&2 && continue
    fi

    # loop over all parties
    for pcounter in `seq 0 $(( $parties - 1 ))`
    do
        if [ "$ocounter" -ne 0 ]
        then
            echo "," >> "$result_opinion"
        fi
        
        # loop over all statements
        for scounter in `seq 0 $(( $STATEMENTS - 1 ))`
        do
            if [ "$scounter" -ne 0 ]
            then
                echo "," >> "$result_opinion"
            fi
            
            # extract opinion on dedicated position
            opinion="`echo "$opinions"| sed -n "$(( $scounter + 1 ))p" | head -c $(( $pcounter + 1 )) | tail -c 1`"
            # replace tempate placeholder with extracted data and write json file
            echo -n "  " >> "$result_opinion"
            cat "$TEMPLATE_DIR/opinion.json" |\
            sed "s|T_OCOUNTER|$ocounter|g" |\
            sed "s|T_PARTY|$pcounter|g" |\
            sed "s|T_STATEMENT|$scounter|g" |\
            sed "s|T_ANSWER|$opinion|g" |\
            tr -d '\n' \
            >> "$result_opinion"
            
            let ocounter++
        done
    done
    # write json footer
    echo -e "\n]" >> "$result_opinion"
    echo "Extraction done for $pdffilename"
    echo "Please check the result: $result_opinion"
done
