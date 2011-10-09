#!/usr/bin/env python
import fileinput
import re
from collections import defaultdict
from operator import itemgetter
import os

transcript_dir = 'transcripts'
out_dir = 'ngrams'

try: os.mkdir(out_dir)
except os.error: pass

# NOTE: this is hideously inefficient. I know how to make it efficient,
# but I don't wanna.

class NgramCounter(object):
	def __init__(self):
		self.ngram_counts = defaultdict(int)	# ('a','tuple') -> # of occurrences
		self.ngram_totals = defaultdict(int)	# n -> total # of n-grams
	
	def process(self, text):
#		words = [w.strip('.!?,;:').lower() for w in text.split()]
		words = [w.strip('.!?,;:').lower() for w in re.split('[\s,\.!?;:"]+', text) if w != '']
		for n in xrange(1, len(words) + 1):
			for i in xrange(len(words) + 1 - n):
				self.ngram_counts[tuple(words[i:i+n])] += 1
				self.ngram_totals[n] += 1
	
	def prune(self):
		print len(self.ngram_counts)
		print "pruning..."
		for w, n in self.ngram_counts.items():
			# prevent iterator from resurrecting deleted items
			if w not in self.ngram_counts:
				continue
			# filter singletons
			if n < 2:
				del self.ngram_counts[w]
				continue
			# remove non-maximal ngrams
			for sublen in xrange(2, len(w)):
				for j in xrange(len(w) - sublen + 1):
					subw = w[j:j+sublen]
					if subw in self.ngram_counts and self.ngram_counts[subw] == n:
						del self.ngram_counts[subw]
		print len(self.ngram_counts)
	
	def report(self, out_prefix):
		# maxn = max(len(w) for w in self.ngram_counts.keys())
		ngram_lists = defaultdict(list)
		for w, count in self.ngram_counts.items():
			ngram_lists[len(w)].append((w, count))
		print "sorting..."
		for n, ngram_list in ngram_lists.items():
			ngram_list.sort(key=itemgetter(1), reverse=True)
		print "writing..."
		for n, ngram_list in ngram_lists.items():
			out_name = out_prefix + "-%d-grams.txt" % n
			print out_name
			with open(out_name, "w") as out:
				out.write("%d\n" % self.ngram_totals[n])
				for w, count in ngram_list:
					out.write("%d\t%s\n" % (count, " ".join(w)))

if __name__ == "__main__":
	ngram = NgramCounter()
	for season_name in os.listdir(transcript_dir):
		if not re.match("S\\d+", season_name): continue
		season_dir = os.path.join(transcript_dir, season_name)
		for ep_file_name in os.listdir(season_dir):
			if not re.match("S\\d+E\\d+", ep_file_name): continue
			ep_file_path = os.path.join(season_dir, ep_file_name)
			print ep_file_name
			with open(ep_file_path) as f:
				for line in f:
					timestamp, character, dialogue = line.split("\t")
					
					dialogue = re.sub('\[[^]]+\]', '', dialogue)
					ngram.process(dialogue)
	print "summary..."
	ngram.prune()
	ngram.report(os.path.join(out_dir,"futurama"))
