#!/usr/bin/env python
import fileinput
import re
from collections import defaultdict
from operator import itemgetter
import os

# TODO: remove punctuation
# remove case

transcript_dir = 'transcripts'

class NgramCounter(object):
	def __init__(self):
		self.ngram_counts = defaultdict(int)
	
	def process(self, text):
		words = [w.strip('.!?,;:').lower() for w in text.split()]
		for n in xrange(2, len(words) + 1):
			for i in xrange(len(words) + 1 - n):
				self.ngram_counts[tuple(words[i:i+n])] += 1
	
	def report(self):
		ngram_list = [(len(w), n, w) for w, n in self.ngram_counts.items() if n > 1]
		ngram_list.sort(key=itemgetter(1), reverse=True)
		ngram_list.sort(key=itemgetter(0), reverse=True)
		for l,n,w in ngram_list:
			print l, n, w

ngram = NgramCounter()
for season_name in os.listdir(transcript_dir):
	season_dir = os.path.join(transcript_dir, season_name)
	for ep_file_name in os.listdir(season_dir):
		ep_file_path = os.path.join(season_dir, ep_file_name)
		print ep_file_name
		with open(ep_file_path) as f:
			for line in f:
				timestamp, character, dialogue = line.split("\t")
				
				dialogue = re.sub('\[[^]]+\]', '', dialogue)
				ngram.process(dialogue)
print "summary..."
ngram.report()
