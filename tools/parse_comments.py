#!/usr/bin/env python3

import os
import sys
import json
from io import StringIO
from lxml import html

# max parties possible to select per results page
MAX_SELECT_PARTY = 8
# directory to save files
PROCESSING_DIR = 'online'
PARTY_FILE_SUFFIX = '_party.html'
RESULT_FILE_SUFFIX = '_result.html'


def clean(text, replace_quotes=False):
    # remove multiple whitespaces
    text = ' '.join(text.split())
    if replace_quotes:
        # replace double quotes with single quote
        text = text.replace('"', '\'')
    # replace german quotes with common quotes
    text = text.replace('„', '"')
    text = text.replace('”', '"')
    # concert html escape for & to normal &
    text = text.replace('&amp;', '&')
    
    return text


def open_result(filename):
    # load html result page
    with open(filename, 'r') as f:
        filecontent = f.read()
    
    # remove newlines and tabs
    filecontent = filecontent.replace('\n', ' ')
    filecontent = filecontent.replace('\t', ' ')
    
    # return html structure
    return html.parse(StringIO(filecontent))


def save_json(filename, jsonobject):
    with open(filename,'w') as json_file:
        json_file.write('[\n  %s\n]\n' % ',\n  '
            .join(json.dumps(item, ensure_ascii=False, separators=(', ', ':'))
                    for item in jsonobject))


# go into processing dir
dirname = os.path.dirname(os.path.realpath(__file__))
os.chdir(os.path.join(dirname, PROCESSING_DIR))

# check for needed files and add to array
found_wom = []
files = (f for f in os.listdir(os.getcwd()) if os.path.isfile(f))
for f in files:
    prefix = f.split('_')[0]
    if os.path.isfile(prefix + PARTY_FILE_SUFFIX) and \
            os.path.isfile(prefix + RESULT_FILE_SUFFIX):
        if prefix not in found_wom:
            found_wom += [prefix]

for online in found_wom:
    # json objects to fill
    parties = []
    statements = []
    opinions = []
    comments = []
    
    # get html structure for using xpath
    party_tree = open_result(online + PARTY_FILE_SUFFIX)
    comment_tree = open_result(online + RESULT_FILE_SUFFIX)
    # get all needed elements
    result_pages = len(comment_tree.xpath('//html'))
    result_parties = party_tree.xpath('//ul[contains(@class, "parteien_list")]/li')
    result_comments = comment_tree.xpath('//ul[contains(@class, "votum_list") and contains(@class, "on")]//li')
    result_statements = comment_tree.xpath('//ul[contains(@class, "thesen_box")]//li')
    result_statements = result_statements[:len(result_statements)//result_pages]
    
    # give some output to the user
    print('=== ' + online + ' ===')
    print(str(len(result_statements)) + ' statements found.')
    print(str(len(result_comments)) + ' comments found.')
    print('Thus ' + str(len(result_comments)//len(result_statements)) + ' parties calculated.')
    print(str(len(result_parties)) + ' parties found.')
    
    #check consistency
    if len(result_comments)%len(result_statements) != 0 or \
            len(result_comments)//(len(result_statements)*result_pages) > MAX_SELECT_PARTY or \
            len(result_comments)//len(result_statements) != len(result_parties):
        print('Something seems missing. Exit.')
        sys.exit(1)
    
    party_cnt = 0
    for party in result_parties:
        name = party.xpath('.//img[@title]/@alt')
        name = clean(name[0])
        name = name.replace('Logo von: ', '')
        longname = party.xpath('.//img[@title]/@title')
        longname = clean(longname[0])
        
        parties += [{'id':party_cnt, 'name': name, 'longname': longname}]
        
        party_cnt += 1
    
    statement_cnt = 0
    for statement in result_statements:
        label = statement.xpath(".//h2/text()")
        label = clean(label[0])
        text = statement.xpath(".//p/text()")
        text = clean(text[0])
        
        statements += [{'id':statement_cnt, 'category':None, 'label': label, 'text': text}]
        
        statement_cnt += 1
    
    comment_cnt = 0
    for comment in result_comments:
        # calculate party id and statement id using current comment
        party = comment_cnt//len(result_statements)
        statement = comment_cnt%len(result_statements)
        # find comment
        text = comment.xpath(".//div//p/text()")
        if len(text) == 0:
            text = comment.xpath(".//div//blockquote/text()")
        # there can be multiple p blocks with comments, so join them before
        text = clean(' '.join(text), True)
        # get opinion by matching class
        if len(comment.xpath('.//*[contains(@class, "approved")]')) != 0:
            answer = 0
        elif len(comment.xpath('.//*[contains(@class, "negative")]')) != 0:
            answer = 1
        elif len(comment.xpath('.//*[contains(@class, "neutral")]')) != 0:
            answer = 2
        
        opinions += [{'id':comment_cnt, 'party': party, 'statement': statement, 'answer': answer, 'comment': comment_cnt}]
        comments += [{'id':comment_cnt, 'text': text}]
        
        comment_cnt += 1
    
    # create folder per election
    if not os.path.isfile(online) and not os.path.isdir(online):
        os.mkdir(online)
    os.chdir(online)
    save_json('party.json', parties)
    save_json('statement.json', statements)
    save_json('opinion.json', opinions)
    save_json('comment.json', comments)
    os.chdir('..')
