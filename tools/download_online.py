#!/usr/bin/env python3

import os
import sys
from selenium import webdriver

# max parties possible to select per results page
MAX_SELECT_PARTY = 8
# directory to save files
PROCESSING_DIR = 'online'
PARTY_FILE_SUFFIX = '_party.html'
RESULT_FILE_SUFFIX = '_result.html'

# current wahlomats available online
wom = [
    "https://www.wahl-o-mat.de/bayern2013/",
    "https://www.wahl-o-mat.de/europawahl2014/",
    "https://www.wahl-o-mat.de/sachsen2014/",
    "https://www.wahl-o-mat.de/thueringen2014/",
    "https://www.wahl-o-mat.de/brandenburg2014/",
    "https://www.wahl-o-mat.de/hamburg2015/",
    "https://www.wahl-o-mat.de/bremen2015/",
    "https://www.wahl-o-mat.de/bw2016/",
    "https://www.wahl-o-mat.de/rlp2016/",
    "https://www.wahl-o-mat.de/sachsenanhalt2016/",
    "https://www.wahl-o-mat.de/berlin2016/",
    "https://www.wahl-o-mat.de/saarland2017/",
    "https://www.wahl-o-mat.de/schleswigholstein2017/",
    "https://www.wahl-o-mat.de/nrw2017/",
    "https://www.wahl-o-mat.de/bundestagswahl2017/"
]


def get_parties():
    return driver.find_elements_by_xpath('//ul[contains(@class, "parteien_list")]/li')


def select_parties(i):
    parties = get_parties()
    # select different parties (MAX_SELECT_PARTY) per iteration (e.g. 1-8 / 9-16 ...)
    for party in parties[i*MAX_SELECT_PARTY:(i+1)*MAX_SELECT_PARTY]:
        party.click()


def next_page():
    driver.find_element_by_xpath('//*[contains(@class, "next")]').click()


def save_page(filename):
    with open(filename,'a') as html:
        html.write(driver.page_source)


def previous_page():
    driver.find_element_by_xpath('//*[contains(@class, "skip")]/*[contains(@class, "previous")]').click()


# check for arguments
if len(sys.argv) == 2:
    if sys.argv[1] == '--last-only':
        wom = [wom[-1]]
    else:
        wom = [sys.argv[1]]

# go into processing dir
dirname = os.path.dirname(os.path.realpath(__file__))
os.chdir(os.path.join(dirname, PROCESSING_DIR))

# initialze selenium and start firefox
driver = webdriver.Firefox()
# general wait in seconds for find_element() to complain
driver.implicitly_wait(3)

for url in wom:
    # get last string from url
    fileprefix = url.strip("/").split("/")[-1]
    # check if files are already there and skip
    if os.path.isfile(fileprefix + PARTY_FILE_SUFFIX) or \
            os.path.isfile(fileprefix + RESULT_FILE_SUFFIX):
        print('File already exists ... skipping ' + fileprefix)
        continue
    
    # open url
    driver.get(url)
    # find start button and click
    driver.find_element_by_xpath('//*[@id="bnwelcome"]/a[contains(text(), "Start")]').click()
    
    # click skip button as long as there is the skip button
    statement_count = 0
    while True:
        try:
            statement_count += 1
            driver.find_element_by_xpath('//*[contains(@class, "skipper")]').click()
        except:
            break
    
    driver.find_element_by_xpath('//*[contains(@class, "next")]').click()
    # save party select page to process later
    save_page(fileprefix + PARTY_FILE_SUFFIX)
    party_count = len(get_parties())
    
    # max rounds = math.ceil(parties/max allowed)
    for i in range(-(-party_count//MAX_SELECT_PARTY)):
        select_parties(i)
        next_page()
        next_page()
        # save result page per 8 parties and append to one single file
        save_page(fileprefix + RESULT_FILE_SUFFIX)
        previous_page()
        previous_page()
        select_parties(i)

# close firefox
driver.close()
