#!/usr/bin/env python

import urllib2
import datetime
import re
import time
#html parser
from bs4 import BeautifulSoup

class aginator(object):
	def __init__(self):
		self.total_cast = 0
		self.total_age = 0
		self.age = 0
		self.today = datetime.datetime.now()
		
	def aginate(self):
		self.age = self.total_age/self.total_cast

	def calculate(self, birthdate):
		birthdate = datetime.datetime.strptime(birthdate, self.date_format)
		age = self.today.year - birthdate.year
		if ((self.today.month, self.today.day) < (birthdate.month, birthdate.day)):
			age -= 1
		self.total_age += age
		self.total_cast += 1

	def souper(self, url):
		#opens url, and parses the html for searching and extracting
		response = urllib2.urlopen(url)
		page_source = response.read()
		soup = BeautifulSoup(page_source)
		return soup


class imdb_aginator(aginator):
	def __init__(self, title):
		super(imdb_aginator, self).__init__()
		self.base_url = "http://www.imdb.com"
		self.date_format = "%Y-%m-%d"
		self.title = title

	def __str__(self):
		return "According to IMDB, the average age for the cast of the movie '%s' is %d" % (self.title, self.age) 
		
	#make a url-friendly title
	def sanitize(self):
		return self.title.replace(" ", "+")


def get_cast(movie):
	#find all members of the cast
	#adding the year in case of duplicate movie name/movie reboot
	print 'processing.....'
	aginator = imdb_aginator(movie)
	url = "%s/find?q=%s+%s&s=tt" % (aginator.base_url, aginator.sanitize(), str(aginator.today.year))
	imdb_soup = aginator.souper(url)
	titles_div = imdb_soup.find(class_="findList")
	movie_link = titles_div.find("a")["href"]
	matches = re.search('tt[0-9]+', movie_link)
	movie_id = matches.group(0)
	url = aginator.base_url + "/title/" + movie_id + "/fullcredits"
	imdb_soup = aginator.souper(url)
	cast_table = imdb_soup.find(class_="cast_list")
	cast_tds = cast_table.find_all("td", itemprop="actor")
	for td in cast_tds:
		#hitting the imdb servers too hard might cause temporary ip blocking
		#time.sleep(1)
		m = re.search('nm[0-9]+', td.a['href'])
		actor_id = m.group(0)
		url = aginator.base_url + "/name/" + actor_id
		imdb_soup = aginator.souper(url)
		try:
			birthdate = imdb_soup.find('time')['datetime']
			aginator.calculate(birthdate)
		except:
			#skip actor that has no birthday on file
			pass
	aginator.aginate()
	print aginator


def begin():
	blank_aginator = aginator()
	fandango_soup = blank_aginator.souper("http://www.fandango.com/moviesintheaters")
	movies_ul = fandango_soup.find(id="now_playing_np_div").find('ul')
	num_movies = len(movies_ul)
	counter = 0
	print "Total movies showing in theatres: %d" % (num_movies)
	for li in movies_ul.find_all('li', recursive=False):
		title = li.find(class_="visual-title").text.strip()
		get_cast(title)
		counter += 1
		if counter % 5 == 0:
			print "Finished %d/%d movies" % (counter, num_movies)



if __name__ == "__main__":
	begin()
	print "Complete"
