#!/usr/bin/env python

import urllib2
import datetime
import re
#html parser
from bs4 import BeautifulSoup

#constants
TODAY = datetime.datetime.now()
IMDB_BASE_URL = "http://www.imdb.com"
FANDANGO_BASE_URL = "http://www.fandango.com"
IMDB_DATE_FORMAT = "%Y-%m-%d"


def souper(url):
	#opens url, and parses the html for searching and extracting
	response = urllib2.urlopen(url)
	page_source = response.read()
	soup = BeautifulSoup(page_source)
	return soup

def find_age(birthdate):
	birthdate = datetime.datetime.strptime(birthdate, IMDB_DATE_FORMAT)
	age = TODAY.year - birthdate.year
	if ((TODAY.month, TODAY.day) < (birthdate.month, birthdate.day)):
		age -= 1
	return age

def get_cast(movie):
	#find all members of the cast
	#adding the year in case of duplicate movie name/movie reboot
	url = IMDB_BASE_URL + "/find?q=" + movie + "+" + str(TODAY.year) + "&s=tt"
	imdb_soup = souper(url)
	titles_div = imdb_soup.find(class_="findList")
	movie_link = titles_div.find("a")["href"]
	matches = re.search('tt[0-9]+', movie_link)
	movie_id = matches.group(0)
	url = IMDB_BASE_URL + "/title/" + movie_id + "/fullcredits"
	imdb_soup = souper(url)
	cast_table = imdb_soup.find(class_="cast_list")
	cast_tds = cast_table.find_all("td", itemprop="actor")
	total_age = 0
	cast_members = 0
	for td in cast_tds:
		m = re.search('nm[0-9]+', td.a['href'])
		actor_id = m.group(0)
		url = IMDB_BASE_URL + "/name/" + actor_id
		imdb_soup = souper(url)
		try:
			birthdate = imdb_soup.find('time')['datetime']
			total_age += find_age(birthdate)
			cast_members += 1
		except:
			print "Error: no birthdate on file, skipping cast member"
	average_age = total_age/cast_members
	print "The average age for the movie %s is %f" % (movie, average_age)  



def begin():
	fandango_soup = souper("http://www.fandango.com/moviesintheaters")
	movies_ul = fandango_soup.find(id="now_playing_np_div").find('ul')
	movie_list = []
	for li in movies_ul.find_all('li', recursive=False):
		title = li.find(class_="visual-title").text.strip()
		get_cast(title)
		break
	print "done"


if __name__ == "__main__":
	begin()
