#!/usr/bin/env python
import fileinput
import re
from collections import defaultdict
from operator import itemgetter

line_re = re.compile('\((\d\d:\d\d)\)([^:]+): (.*)')

# TODO: remove punctuation
# remove case

class NgramCounter(object):
	def __init__(self):
		self.ngram_counts = defaultdict(int)
	
	def process(self, text):
		words = text.split()
		for n in xrange(2, len(words) + 1):
			for i in xrange(len(words) + 1 - n):
				self.ngram_counts[tuple(words[i:i+n])] += 1
	
	def report(self):
		ngram_list = [(len(w), n, w) for w, n in self.ngram_counts.items()]
		ngram_list.sort(key=itemgetter(0), reverse=True)
		ngram_list.sort(key=itemgetter(1), reverse=True)
		for l,n,w in ngram_list:
			print l, n, w

ngram = NgramCounter()
for line in fileinput.input():
	m = line_re.match(line)
	if not m: continue
	timestamp = m.group(1)
	character = m.group(2)
	dialogue = m.group(3)
	
	dialogue = re.sub('\[[^]]+\]', '', dialogue)
	ngram.process(dialogue)
ngram.report()
