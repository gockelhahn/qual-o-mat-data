#!/usr/bin/env python3

import json
import bleach
from io import StringIO
from lxml import etree
from lxml import html

# load "old" opinion json file into an object
with open('../2017/deutschland/opinion.json', 'r') as json_file:
     opinions = json.load(json_file)

def fill_opinion(html_file):
    with open(html_file, 'r') as f:
        filecontent = f.read()
        
        # remove newlines and tabs
        filecontent = filecontent.replace('\n', ' ')
        filecontent = filecontent.replace('\t', ' ')
        
        # get html structure for using xpath
        tree = html.parse(StringIO(filecontent))
        # get all divs with party comment to statement
        divs = tree.xpath('//ul[@class="wom_votum_list wom_on"]//div')
        
        # manual check if comments match party*statements
        print(len(divs))
        
        for div in divs:
            # get div class and thus party id and statement id
            divid = div.get('id')
            party = int(divid.split('-')[2].split('partei')[1])
            statement = int(divid.split('-')[3]) - 1
            # just strip out text without html elements
            blockquote = div.xpath('./blockquote')
            text = etree.tostring(blockquote[0]).decode()
            cleantext = bleach.clean(text, tags=[], attributes={}, styles=[], strip=True)
            # remove multiple whitespaces
            cleantext = ' '.join(cleantext.split())
            # replace double quotes with single quote
            cleantext = cleantext.replace('"', '\'')
            # replace german quotes with common quotes
            cleantext = cleantext.replace('„', '"')
            cleantext = cleantext.replace('”', '"')
            
            # match opinion and add comment key
            for opinion in opinions:
                if opinion['party'] == party and opinion['statement'] == statement:
                    opinions[opinion['id']]['opinion'] = opinion['id']
                    opinions[opinion['id']]['text'] = cleantext

# read all result pages
fill_opinion('b2017_1.html')
fill_opinion('b2017_2.html')
fill_opinion('b2017_3.html')
fill_opinion('b2017_4.html')

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
