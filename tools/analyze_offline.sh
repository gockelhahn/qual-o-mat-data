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
ORIG_DEF_COMMENTS="module_definition_statements.js"

SCRIPT_DIR="$(cd "`dirname "$0"`" && pwd)"
[ -z "$SCRIPT_DIR" ] && echo "ERROR: Script directory could not be detected. Abort!" >&2 && exit 1
OFFLINE_DIR="$SCRIPT_DIR/offline"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR"/template && pwd)"

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
    jsfilename_offline="$filebase_dir/offline_statements.js"
    result_party="$filebase_dir/party.json"
    result_statement="$filebase_dir/statement.json"
    result_opinion="$filebase_dir/opinion.json"
    result_comment="$filebase_dir/comment.json"
    result_category="$filebase_dir/category.json"
    
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
    sed -i 's|\&auml\;|\ä|g;s|\&Auml\;|\Ä|g;s|\&ouml\;|\ö|g;s|\&Ouml\;|\Ö|g;s|\&uuml\;|\ü|g;s|\&Uuml\;|\Ü|g;s|\&szlig\;|\ß|g;s|\&amp\;|\&|g' "$jsfilename"
    
    cd "$OFFLINE_DIR"
    unzip -qq -aa -p "$zipfilename" **/"$ORIG_DEF_COMMENTS" > "$tmpfilename" 2>/dev/null
    cd "$filebase_dir"
    
    # fix text encoding by converting all files to UTF-8
    if `file "$tmpfilename" | grep -q ISO-8859`
    then
        iconv -f ISO-8859-1 -t UTF-8 "$tmpfilename" > "$jsfilename_offline"
    else
        iconv -f UTF-8 -t UTF-8//IGNORE "$tmpfilename" > "$jsfilename_offline"
    fi
    rm -f "$tmpfilename"
    
    # convert html characters to normal UTF-8
    sed -i 's|\&auml\;|\ä|g;s|\&Auml\;|\Ä|g;s|\&ouml\;|\ö|g;s|\&Ouml\;|\Ö|g;s|\&uuml\;|\ü|g;s|\&Uuml\;|\Ü|g;s|\&szlig\;|\ß|g;s|\&amp\;|\&|g' "$jsfilename_offline"
    file "$jsfilename_offline" | grep -qo empty && rm "$jsfilename_offline"
    
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
        
        # extract party name/long name and escape ampersand and quote, multiple whitespaces and trim
        pname="`echo "$line"| cut -d'|' -f2 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g' |\
          tr -s " " |\
          sed 's/^ *//;s/ *$//'`"
        plongname="`echo "$line"| cut -d'|' -f1 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g' |\
          tr -s " " |\
          sed 's/^ *//;s/ *$//'`"
        
        # replace tempate placeholder with extracted data and write json file
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
    
    # loop over all categories
    ccounter=0
    # pipe javascript definition into mozillas java script interpreter and get categories
    ccount="`echo 'print(WOMT_nThemen)' | js24 --shell "$jsfilename" | sed '1d;$d' | egrep -o '[0-9]'`"
    if [ "$ccount" -gt 1 ]
    then
        # write json header
        echo "[" > "$result_category"
        # pipe javascript definition into mozillas javascript interpreter and print statements
        echo 'for (var i=0, l=WOMT_aThemen.length; i<l; i++){WOMT_aThemen[i][0] = WOMT_aThemen[i][0]; lang=WOMT_aThemen[i].length; for (var j=1; j<lang; j++){WOMT_aThemen[i].splice(1, 1)}; print(WOMT_aThemen[i].join("\n"))}' |\
        js24 --shell "$jsfilename" | sed '1d;$d' |\
        while read line
        do
            if [ "$ccounter" -ne 0 ]
            then
                echo "," >> "$result_category"
            fi
            
            # extract category label and escape ampersand, quote, multiple whitespaces and trim
            clabel="`echo "$line"| cut -d'|' -f1 |\
              sed 's|"|\\\\\\\\"|g' |\
              sed 's|&|\\\\\\&|g' |\
              tr -s " " |\
              sed 's/^ *//;s/ *$//'`"
            
            # replace tempate placeholder with extracted data and write json file
            cat "$TEMPLATE_DIR/category.json" |\
            sed "s|T_CCOUNTER|$ccounter|g" |\
            sed "s|T_CLABEL|$clabel|g" |\
            tr -d '\n' \
            >> "$result_category"
            
            let ccounter++
        done
        # write json footer
        echo -e "\n]" >> "$result_category"
    fi
    
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
        
        if [ "$ccount" -gt 1 ]
        then
            scategory="`echo 'print(WOMT_aThesenThema['$scounter'])' | js24 --shell "$jsfilename" | sed '1d;$d' | egrep -o '[0-9]'`"
        else
            scategory="null"
        fi
        
        # extract statement text and escape ampersand and quote, multiple whitespaces and trim
        stext="`echo "$line"| cut -d'|' -f2 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g' |\
          tr -s " " |\
          sed 's/^ *//;s/ *$//'`"
        
        # extract statement label and escape ampersand and quote, multiple whitespaces and trim
        # also remove (BS)LZ character conversion artifacts
        slabel="`echo "$line"| cut -d'|' -f1 |\
          sed 's|"|\\\\\\\\"|g' |\
          sed 's|&|\\\\\\&|g' |\
          sed 's|\[BSLZ\]||g' |\
          sed 's|\[LZ\]||g' |\
          tr -s " " |\
          sed 's/^ *//;s/ *$//'`"
        
        # replace tempate placeholder with extracted data and write json file
        cat "$TEMPLATE_DIR/statement.json" |\
          sed "s|T_SCOUNTER|$scounter|g" |\
          sed "s|T_SCATEGORY|$scategory|g" |\
          sed "s|T_SLABEL|$slabel|g" |\
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
    echo "[" > "$result_comment"
    # pipe javascript definition into mozillas java script interpreter and print opinions
    opinions="`echo 'print(WOMT_aThesenParteien.join("\n"))' | js24 --shell "$jsfilename" | sed '1d;$d'`"
    # use correct data file for comments
    if [ -e "$jsfilename_offline" ]
    then
        use_file="$jsfilename_offline"
    else
        use_file="$jsfilename"
    fi
    # pipe javascript definition into mozillas java script interpreter and print comments
    comments="`echo 'for (var i=0, s=WOMT_aThesenParteienText.length; i<s; i++){for (var j=0, p=WOMT_aThesenParteienText[i].length; j<p; j++){ lang=WOMT_aThesenParteienText[i][j].length; for (var k=1; k<lang; k++){WOMT_aThesenParteienText[i][j].splice(1, 1)}}; print(WOMT_aThesenParteienText[i].join("|"))}' | js24 --shell "$use_file" | sed '1d;$d'`"
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
            echo "," >> "$result_comment"
        fi
        
        # loop over all statements
        for scounter in `seq 0 $((max_statements-1))`
        do
            if [ "$scounter" -ne 0 ]
            then
                echo "," >> "$result_opinion"
                echo "," >> "$result_comment"
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
            
            # extract comments
            comment="`echo "$comments"| cut -d'|' -f$((pcounter+1)) | sed -n "$((scounter+1))p"`"
            if [ -z "$comment" ]
            then
                # different "placeholder" for old versions if no party comment set
                if [ "$filebase" == "WahlomatOfflineBayern2003" ] ||\
                        [ "$filebase" == "WahlomatOfflineSaarland2004" ] ||\
                        [ "$filebase" == "WahlomatOfflineSachsen2004" ] ||\
                        [ "$filebase" == "WahlomatOfflineSachsen2004" ] ||\
                        [ "$filebase" == "WahlomatOfflineEuropawahl2004" ]
                then
                    comment="Die Begründung der Partei zu ihrem Abstimmverhalten wird nachgereicht, da noch nicht alle Begründungen vorliegen."
                else
                    comment="Zu dieser These hat die Partei keine Begründung vorgelegt."
                fi
            else
                # remove static html string with its representation
                comment="`echo $comment | sed 's|<a href=.*_blank>||g' | sed 's|</a>||g'`"
                # quote the comment and remove html line breaks / paragraphs / special chars + multiple whitespaces + trim
                comment="\\\\\"`echo $comment | sed "s|\\\"|'|g" | sed 's|&|\\\\\\&|g' | sed 's|<br>| |g' | sed 's|<p>| |g' | sed 's/\xc2\x92/’/g' | sed 's|<br/>| |g' | tr -s " " | sed 's/^ *//;s/ *$//'`\\\\\""
            fi
            
            # replace tempate placeholder with extracted data and write json file
            cat "$TEMPLATE_DIR/opinion.json" |\
            sed "s|T_OCOUNTER|$ocounter|g" |\
            sed "s|T_PARTY|$pcounter|g" |\
            sed "s|T_STATEMENT|$scounter|g" |\
            sed "s|T_ANSWER|$opinion|g" |\
            tr -d '\n' \
            >> "$result_opinion"
            
            # replace tempate placeholder with extracted data and write json file
            cat "$TEMPLATE_DIR/comment.json" |\
            sed "s|T_OCOUNTER|$ocounter|g" |\
            sed "s|T_COMMENT|$comment|g" |\
            tr -d '\n' \
            >> "$result_comment"
            
            let ocounter++
        done
    done
    # write json footer
    echo -e "\n]" >> "$result_opinion"
    echo -e "\n]" >> "$result_comment"
done
