#!/usr/bin/env python

import urllib2
#html parser
from bs4 import BeautifulSoup

def souper(url):
	#opens url, and parses the html for searching and extracting
	response = urllib2.urlopen(url)
	page_source = response.read()
	soup = BeautifulSoup(page_source)
	return soup

def aginator():
	#assuming a class is less susceptible to change than a url
	fandango_soup = souper('http://www.fandango.com/')
	tag = fandango_soup.find(class_="movie-tickets-all")
	movies_link = tag['href']
	
	fandango_soup = souper(movies_link)
	movie_list = fandango_soup.find(id="now_playing_np_div").find('ul')
	for li in movie_list.find_all('li', recursive=False):
		print li.find(class_="visual-title").text.strip()

if __name__ == "__main__":
	aginator()
