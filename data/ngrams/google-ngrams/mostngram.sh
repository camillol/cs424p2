thresh=$(echo "1000000 10 $1 ^ / p" | dc)
echo $thresh 1>&2
(
	for f in googlebooks-eng-fiction-all-${1}gram-20090715-*.csv.zip; do
		echo $f 1>&2
		unzip -p "$f" | awk 'BEGIN{FS="\t"} $2==2009 && $3 > '$thresh' {print}'
	done
) | sort -n -k 3 -r | awk 'BEGIN{FS="\t"} {print $3 "\t" $1}'
