#!/usr/bin/env python
import os
import re
from collections import defaultdict
from operator import itemgetter

vivek_re = re.compile('(.*)###(.*)###(.*)###:? ?(.*)')
vivek_dir = 'project2cs424/transcripts'

season_name_re = re.compile('Season_(\d+)')
ep_name_re = re.compile('(\d+)\.Transcript:(.*)')

transcript_dir = 'transcripts'
character_file_name = 'characters.txt'

name_urls = defaultdict(set)
url_names = defaultdict(set)

name_map = {
	'Morris': 'Turanga Morris',
	'Munda': 'Turanga Munda',
	'Hawking': 'Stephen Hawking',
	'Panucci': 'Mr. Panucci',
	'Hutch': 'Hutch Waterfall',
	'H.G. Blob': 'Horrible Gelatinous Blob',
	'H. G. Blob': 'Horrible Gelatinous Blob',
	'Poopenmeyer': 'Mayor Poopenmeyer',
	'Beeler': 'Ben Beeler',
	'Takei': 'George Takei',
	'Small Glurmo #1': 'Glurmo',
	'Small Glurmo #2': 'Glurmo',
	'Nixon': 'Richard Nixon',
	'NIxon': 'Richard Nixon',
	'Farnsworth': 'Prof. Farnsworth',
	'Professor Farnsworth': 'Prof. Farnsworth',
	'Clinton': 'Bill Clinton',
	'All': 'ALL',
	'Female Voice': 'Female voice',
	'Labarbara': 'LaBarbara',
	'Old Man': 'Old man',
	'Bender Doll': 'Bender doll',
	'Security Woman': 'Security woman',
	'Hedonism bot': 'Hedonism Bot',
	'Underwater House Salesman': 'Underwater house salesman',
	'Suicide Booth': 'Suicide booth',
	'Hydroponic Farmer': 'Hydroponic farmer',
	'YIVO': 'Yivo',
	'Thubanian Leader': 'Thubanian leader',
}

# what about Lucy Liu? we don't want the Liubots to count as her, do we?
# what about the orphans? and other groups?
# what about "Bender duplicate #2" or "Amy 420"?
# also the Grunka Lunkas. and all chars ending with #1 etc.

url_name_map = {
	'http://theinfosphere.org/Al_Gore%27s_head': 'Al Gore',
	'http://theinfosphere.org/Glurmo': 'Glurmo',
	'http://theinfosphere.org/Warden_Vogel': 'Warden Vogel',
	'http://theinfosphere.org/%22Fishy%22_Joseph_Gilman': 'Fishy Joe',
	'http://theinfosphere.org/Professor_Hubert_Farnsworth': 'Prof. Farnsworth',
	'http://theinfosphere.org/Professor_Hubert_J._Farnsworth': 'Prof. Farnsworth',
	'http://theinfosphere.org/The_Big_Brain': 'The Big Brain',
	'http://theinfosphere.org/Dr._Ben_Beeler': 'Ben Beeler',
	'http://theinfosphere.org/Reverend_Lionel_Preacherbot': 'Preacherbot',
	'http://theinfosphere.org/Amy_Wong': 'Amy',
	'http://theinfosphere.org/Yancy_Fry,_Jr.': 'Yancy Fry, Jr.',
	'http://theinfosphere.org/Randy_Munchnik': 'Randy Munchnik',
	'http://theinfosphere.org/Galactic_Entity': 'Galactic Entity',
	'http://theinfosphere.org/Zapp_Brannigan': 'Zapp',
	'http://theinfosphere.org/Yellow_and_red_lawyer': 'Yellow and red lawyer'
}

char_extra = {
	'Fry' : ['EB491D', 'fry.png'],
	'Bender' : ['6C8486', 'bender.png'],
	'Leela' : ['462252', 'leela.png'],
	'Prof. Farnsworth' : ['E1B675', 'farnsworth.png'],
	'Zoidberg' : ['EA504C', 'zoidberg.png'],
	'Amy' : ['EF8598', 'wong.png'],
	'Hermes' : ['435F27', 'hermes.png'],
	'Zapp' : ['7F172D', 'zapp.png']

}

def uni_name(name, url):
	name = re.sub("'s [Hh]ead$", '', name)
	if url in url_name_map: return url_name_map[url]
	if name in name_map: return name_map[name]
	return name

characters = defaultdict(lambda:[0,0])

try: os.mkdir(transcript_dir)
except os.error: pass

for season_name in os.listdir(vivek_dir):
	m = season_name_re.match(season_name)
	season = int(m.group(1))
	season_dir = os.path.join(vivek_dir, season_name)
	out_season_dir = os.path.join(transcript_dir, "S%02d" % season)
	try: os.mkdir(out_season_dir)
	except os.error: pass
	for ep_file_name in os.listdir(season_dir):
		m = ep_name_re.match(ep_file_name)
		epnum = int(m.group(1))
		eptitle = m.group(2)
		ep_file_path = os.path.join(season_dir, ep_file_name)
		out_file_name = "S%02dE%02d %s.txt" % (season, epnum, eptitle)
		out_file_path = os.path.join(out_season_dir, out_file_name)
		with open(ep_file_path) as f:
			with open(out_file_path, "w") as out:
				charsinep = set()
				for line in f:
					m = vivek_re.match(line)
					if not m:
					#	print "SKIPPING LINE:", line.rstrip()
						continue
					name = m.group(1)
					url = m.group(2).strip()
					timestamp = m.group(3).strip('() ')
					dialogue = m.group(4)
					
					names = re.split(', and |, (?!Jr)| and (?!red )', name)
					charnames = [uni_name(name, url) for name in names]
					for charname in charnames:
						characters[charname][0] += 1
						charsinep.add(charname)
						if charname.startswith('(') or charname.startswith('.') or charname.endswith("'"):
							print "BAD NAME", season, epnum, dialogue
					
#					if len(charnames) > 1: print charnames
					
					if '' in charnames:
						print "NO NAME", season, epnum, dialogue
					
					out.write("%s	%s	%s\n" % (timestamp, ';'.join(charnames), dialogue))
				for charname in charsinep:
					characters[charname][1] += 1

# check for case differences
lcnames = defaultdict(set)
for charname in characters.keys():
	s = lcnames[charname.lower()]
	s.add(charname)
	if len(s) > 1:
		print "CASE AMBIGUITY", s

print "%d unique characters" % len(characters)
with open(character_file_name, "w") as out:
	for name, counts in sorted(characters.items(), key=itemgetter(1), reverse=True):
		if name in char_extra:
			color, img = char_extra[name]
		else:
			color, img = '', ''
		out.write("%s	%d	%d	%s	%s\n" % (name, counts[0], counts[1], color, img))
