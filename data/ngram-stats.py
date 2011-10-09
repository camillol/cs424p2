#!/usr/bin/env python
import fileinput
import re
from collections import defaultdict
from operator import itemgetter
import os
from math import sqrt
from scipy.special import stdtr

transcript_dir = 'transcripts'
ngram_dir = 'ngrams'

def welch(mean1, var1, size1, mean2, var2, size2):
	t = (mean1 - mean2) / sqrt(var1/size1 + var2/size2)
	nu = (var1/size1 + var2/size2)**2 / ( var1**2/( size1**2 * (size1-1) ) + var2**2/( size2**2 * (size2-1) ) )
	return nu, t

def size1special(mean1, mean2, var2, size2):
	t = (mean1 - mean2) / sqrt(var2/size2)
	nu = size2 - 1
	return nu, t

class NgramDetails(object):
	def __init__(self):
		self.loadNgrams()
		self.character_ngrams = {}
		self.character_ngram_totals = {}
	
	def loadNgrams(self):
		self.ngrams = {}
		self.ngram_totals = {}
		for file_name in os.listdir(ngram_dir):
			m = re.match("futurama-(\\d+)-grams.txt", file_name)
			if not m: continue
			n = int(m.group(1))
			file_path = os.path.join(ngram_dir, file_name)
			with open(file_path) as f:
				total_count = 0
				self.ngrams[n] = {}
				for line in f:
					if total_count == 0:
						total_count = int(line)
						continue
					count, text = line.split('\t')
					words = tuple(text.split())
					assert len(words) == n
					self.ngrams[n][words] = {'count':int(count), 'occurrences':[]}
				self.ngram_totals[n] = total_count
	
	def process_line(self, season, episode, lineno, characters, text):
#		words = [w.strip('.!?,;:').lower() for w in text.split()]
		words = tuple([w.strip('.!?,;:').lower() for w in re.split('[\s,\.!?;:"]+', text) if w != ''])
		characters = characters.split(';')
		for n in xrange(1, len(words) + 1):
			for i in xrange(len(words) + 1 - n):
				for c in characters:
					if c not in self.character_ngrams:
						self.character_ngrams[c] = defaultdict(lambda:{'count':0, 'occurrences':[]})
						self.character_ngram_totals[c] = defaultdict(int)
					self.character_ngram_totals[c][n] += 1
				w = tuple(words[i:i+n])
				try:
					ng = self.ngrams[n][w]
				except KeyError:
					continue	# it is not one of the chosen
				ng['occurrences'].append((season, episode, lineno))
				for c in characters:
					cn = self.character_ngrams[c][w]
					cn['count'] += 1
					cn['occurrences'].append((season, episode, lineno))

	def character_stats(self):
		for char, cngr in self.character_ngrams.items():
			for words, ng in cngr.items():
				n = len(words)
				count_all = self.ngrams[n][words]['count']
				count_char = ng['count']
				
				# bernoulli!
				char_total = float(self.character_ngram_totals[char][n])
				char_p = count_char / char_total
				other_total = self.ngram_totals[n] - char_total
				other_p = (count_all - count_char) / other_total
				if count_all == count_char:
					p_value = 0.0		# only this character ever says it! (also would cause /0)
				else:
					if char_total == 1.0:	# special case to avoid divide by zero
						nu, t = size1special(char_p, other_p, other_p*(1.0-other_p), other_total)
					else:
						nu, t = welch(char_p, char_p*(1.0-char_p), char_total, other_p, other_p*(1.0-other_p), other_total)
					p_value = 1.0 - stdtr(nu, t)
				print char, words, "count:", count_char, "total:",char_total, "char_freq:", char_p, "others_count:", count_all-count_char, "others_total:", other_total, "others_freq:", other_p, "df:", nu, "t:", t, "pval:", p_value

if __name__ == "__main__":
	ngrams = NgramDetails()
	for season_name in os.listdir(transcript_dir):
		m = re.match("S(\\d+)", season_name)
		if not m: continue
		season = int(m.group(1))
		season_dir = os.path.join(transcript_dir, season_name)
		for ep_file_name in os.listdir(season_dir):
			m = re.match("S\\d+E(\\d+)", ep_file_name)
			if not m: continue
			episode = int(m.group(1))
			ep_file_path = os.path.join(season_dir, ep_file_name)
			print ep_file_name
			with open(ep_file_path) as f:
				for lineno, line in enumerate(f):
					timestamp, character, dialogue = line.split("\t")
					
					dialogue = re.sub('\[[^]]+\]', '', dialogue)
					ngrams.process_line(season, episode, lineno, character, dialogue)
	
	ngrams.character_stats()

print ngrams.character_ngrams['Bender'][('bite', 'my', 'shiny', 'metal', 'ass')]
