#!/bin/bash
#
# extract parties, statements, opinions from offline versions
#
# offline js opinions:
#   negative = -1
#   neutral = 0
#   positive = 1
# 
# json opinions:
#   negative = 1
#   neutral = 2
#   positive = 0

OFFLINE_EXT=".zip"
ORIG_DEF="module_definition.js"

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "ERROR: Script directory could not be detected. Abort!" >&2 && exit 1
OFFLINE_DIR="$SCRIPT_DIR/offline"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR"/../template && pwd)"

( ! which unzip &>/dev/null) && echo "ERROR: Command \"unzip\" not available. Abort!" >&2 && exit 1
( ! which js24 &>/dev/null) && echo "ERROR: Command \"js24\" not available. Abort!" >&2 && exit 1
( ! which sed &>/dev/null) && echo "ERROR: Command \"sed\" not available. Abort!" >&2 && exit 1

# loop over all found zip files (offline versions)
for zipfilename in `ls -1v "$OFFLINE_DIR"/*"$OFFLINE_EXT"`
do
    cd "$OFFLINE_DIR"
    
    filebase="`basename --suffix="$OFFLINE_EXT" "$zipfilename"`"
    filebase_dir="$OFFLINE_DIR/$filebase"
    tmpfilename="$filebase_dir/offline.tmp"
    jsfilename="$filebase_dir/offline.js"
    result_party="$filebase_dir/party.json"
    result_statement="$filebase_dir/statement.json"
    result_opinion="$filebase_dir/opinion.json"
    
    # create folder for each zip and unpack javascript definitions
    mkdir -p "$filebase_dir"
    unzip -qq -aa -p "$zipfilename" **/"$ORIG_DEF" > "$tmpfilename"
    cd "$filebase_dir"
    
    # fix text encoding by converting all files to UTF-8
    if `file "$tmpfilename" | grep -q ISO-8859`
    then
        iconv -f ISO-8859-1 -t UTF-8 "$tmpfilename" > "$jsfilename"
    else
        iconv -f UTF-8 -t UTF-8//IGNORE "$tmpfilename" > "$jsfilename"
    fi
    rm -f "$tmpfilename"
    
    # convert html characters to normal UTF-8
    sed -i 's|\&auml\;|\ä|g;s|\&Auml\;|\Ä|g;s|\&ouml\;|\ö|g;s|\&Ouml\;|\Ö|g;s|\&uuml\;|\ü|g;s|\&Uuml\;|\Ü|g;s|\&szlig\;|\ß|g' "$jsfilename"
    
    # loop over all parties
    pcounter=0
    # write json header
    echo "[" > "$result_party"
    # pipe javascript definition into mozillas javascript interpreter and print parties
    echo 'for (var i=0, l=WOMT_aParteien.length; i<l; i++){WOMT_aParteien[i][0] = WOMT_aParteien[i][0].join("|"); lang=WOMT_aParteien[i].length; for (var j=1; j<lang; j++){WOMT_aParteien[i].splice(1, 1)}; print(WOMT_aParteien[i].join("\n"))}' |\
    js24 --shell "$jsfilename" | sed '1d;$d' |\
    while read line
    do
        if [ "$pcounter" -ne 0 ]
        then
            echo "," >> "$result_party"
        fi
        
        # extract party name/long name and escape ampersand and quote
        pname="`echo "$line"| cut -d'|' -f2 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g'`"
        plongname="`echo "$line"| cut -d'|' -f1 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g'`"
        
        # replace tempate placeholder with extracted data and write json file
        echo -n "  " >> "$result_party"
        cat "$TEMPLATE_DIR/party.json" |\
          sed "s|T_PCOUNTER|$pcounter|g" |\
          sed "s|T_PNAME|$pname|g" |\
          sed "s|T_PLONGNAME|$plongname|g" |\
          tr -d '\n' \
          >> "$result_party"
        
        let pcounter++
    done
    # write json footer
    echo -e "\n]" >> "$result_party"
    
    # loop over all statements
    scounter=0
    # write json header
    echo "[" > "$result_statement"
    # pipe javascript definition into mozillas javascript interpreter and print statements
    echo 'for (var i=0, l=WOMT_aThesen.length; i<l; i++){WOMT_aThesen[i][0] = WOMT_aThesen[i][0].join("|"); lang=WOMT_aThesen[i].length; for (var j=1; j<lang; j++){WOMT_aThesen[i].splice(1, 1)}; print(WOMT_aThesen[i].join("\n"))}' |\
    js24 --shell "$jsfilename" | sed '1d;$d' |\
    while read line
    do
        if [ "$scounter" -ne 0 ]
        then
            echo "," >> "$result_statement"
        fi
        
        # extract statement text and escape ampersand and quote
        stext="`echo "$line"| cut -d'|' -f2 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g'`"
        
        # replace tempate placeholder with extracted data and write json file
        echo -n "  " >> "$result_statement"
        cat "$TEMPLATE_DIR/statement.json" |\
          sed "s|T_SCOUNTER|$scounter|g" |\
          sed "s|T_STEXT|$stext|g" |\
          tr -d '\n' \
          >> "$result_statement"
        
        let scounter++
    done
    # write json footer
    echo -e "\n]" >> "$result_statement"
    
    ocounter=0
    # write json header
    echo "[" > "$result_opinion"
    # pipe javascript definition into mozillas java script interpreter and print opinions
    opinions="`echo 'print(WOMT_aThesenParteien.join("\n"))' | js24 --shell "$jsfilename" | sed '1d;$d'`"
    max_statements="`echo "$opinions" | wc -l`"
    # count commata as delimiter and calculate parties (+1)
    max_parties="`echo "$opinions" | head -1 | grep -o ',' | wc -l`"
    let max_parties++
    
    # loop over all parties
    for pcounter in `seq 0 $((max_parties-1))`
    do
        if [ "$ocounter" -ne 0 ]
        then
            echo "," >> "$result_opinion"
        fi
        
        # loop over all statements
        for scounter in `seq 0 $((max_statements-1))`
        do
            if [ "$scounter" -ne 0 ]
            then
                echo "," >> "$result_opinion"
            fi
            
            # extract opinion and convert offline vs. json
            opinion="`echo "$opinions"| cut -d',' -f$((pcounter+1)) | sed -n "$((scounter+1))p"`"
            if [ "$opinion" -eq 0 ]
            then
                opinion=2
            elif [ "$opinion" -eq 1 ]
            then
                opinion=0
            else
                opinion=1
            fi
            
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
done
