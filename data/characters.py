#!/usr/bin/env python
import os
import re
from collections import defaultdict
from operator import itemgetter

vivek_re = re.compile('(.*)###(.*)###(.*)###(.*)')	# WTF
vivek_dir = 'project2cs424/transcripts'

season_dirs = [os.path.join(vivek_dir, s) for s in os.listdir(vivek_dir)]

name_urls = defaultdict(set)
url_names = defaultdict(set)

for season_dir in season_dirs:
	ep_files = [os.path.join(season_dir, f) for f in os.listdir(season_dir)]
	for ep_file in ep_files:
		with open(ep_file) as f:
			for line in f:
				m = vivek_re.match(line)
				if not m: continue
				name = m.group(1)
				url = m.group(2)
				timestamp = m.group(3)
				dialogue = m.group(4)
				if url.strip() == "":
					url = "<missing>"
				name_urls[name].add(url)
				url_names[url].add(name)

print "*** Names with multiple URLs ***"
for name, urls in name_urls.items():
	if len(urls) != 1:
		print name
		for url in urls:
			print "	%s" % url
print
print "*** URLs with multiple names ***"
for url, names in url_names.items():
	if len(names) != 1:
		print url
		for name in names:
			print "	%s" % name
