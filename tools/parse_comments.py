#!/usr/bin/env python3

import sys
import json
import bleach
from io import StringIO
from lxml import etree
from lxml import html

STATEMENTS = 38

# check for needed arguments
if len(sys.argv) < 3:
    print('Missing arguments: [script] opinion.json result.html')
    sys.exit(1)

# load "old" opinion json file into an object
with open(sys.argv[1], 'r') as json_file:
     opinions = json.load(json_file)

# load html result page (put all htmls in one file)
with open(sys.argv[2], 'r') as f:
    filecontent = f.read()

# remove newlines and tabs
filecontent = filecontent.replace('\n', ' ')
filecontent = filecontent.replace('\t', ' ')

# get html structure for using xpath
tree = html.parse(StringIO(filecontent))
# get all elements with party comment to statement
comments = tree.xpath('//ul[@class="wom_votum_list wom_on"]//div')
if len(comments) == 0:
    # different format in the past
    comments = tree.xpath('//ul[@class="votum_list on"]//div')

# check consistency and give some output for the user
print(str(len(comments)) + ' comments found.')
print(str(len(opinions)) + ' opinions found.')
if len(comments) != len(opinions):
    print('Something seems missing. Exit.')
    sys.exit(1)

comment_cnt = 0
for comment in comments:
    # calculate party id and statement id using current comment
    party = comment_cnt//STATEMENTS
    statement = comment_cnt%STATEMENTS
    # find correct part in new format
    quote = comment.xpath('./blockquote')
    if len(quote) == 0:
        text = etree.tostring(comment).decode()
    else:
        text = etree.tostring(quote[0]).decode()
    # just strip out text without html elements (+ convert html escapes to normal text)
    cleantext = bleach.clean(text, tags=[], attributes={}, styles=[], strip=True)
    # remove multiple whitespaces
    cleantext = ' '.join(cleantext.split())
    # replace double quotes with single quote
    cleantext = cleantext.replace('"', '\'')
    # replace german quotes with common quotes
    cleantext = cleantext.replace('„', '"')
    cleantext = cleantext.replace('”', '"')
    # concert html escape for & to normal &
    cleantext = cleantext.replace('&amp;', '&')
    # remove this part for old format
    cleantext = cleantext.replace('Begründung der Partei:', '')
    
    # match opinion and add comment key
    for opinion in opinions:
        if opinion['party'] == party and opinion['statement'] == statement:
            opinions[opinion['id']]['opinion'] = opinion['id']
            opinions[opinion['id']]['text'] = cleantext
    
    comment_cnt += 1

# remove keys we dont need anymore for comment.json
for opinion in opinions:
    opinions[opinion['id']].pop('party')
    opinions[opinion['id']].pop('statement')
    opinions[opinion['id']].pop('answer')

# save result into new comments json file
with open('comment.json','w') as json_file:
     json_file.write('[\n  %s\n]\n' % ',\n  '
            .join(json.dumps(opinion, ensure_ascii=False, separators=(', ', ':'))
                    for opinion in opinions))
