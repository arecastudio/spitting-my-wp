#!/bin/bash
source .env
#echo 'hello world'

#filter out content
#grep 'content\"' -m1|sed 's/<[^>]*>//g;s/&#[0-9]\{4\};//g;s/\\n\|&lt;\|&gt;\|\/p//g'

#jubi=$(rss2json 'https://jubi.id/feed'|jq -r .''|gron|grep -E 'items\[[0-9]{1,}\]\.link\ =')
#rss2json 'https://jubi.id/feed' > jubi.json
jubi=$(cat ./jubi.json|gron|grep -E '\.items\[[0-9]{1,}\]\.'|grep -E '\.title|\.guid|\.link|\.published|\.content'|gron -u)
jubiTitle_=$(jq -r '.' ./jubi.json|grep -m1 -i -E '"title"'|awk -F'"' '{print $4}')
#echo $AI_PROMPT
jq -c '.items[]' ./jubi.json|while read -r item
do
	guid_=$(echo "$item"|jq -c '.guid'|sed 's/\"//g'|md5sum|awk '{print $1}')
	title_=$(echo "$item"|jq -c '.title'|sed 's/\"//g')
	link_=$(echo "$item"|jq -c '.link'|sed 's/\"//g')
	filename_=$(echo "$item"|jq -c '.link'|sed 's/\"//g;s/\/$//g'|awk -F '\/' '{print int(rand()*2026)"_"$NF}')
	published_=$(echo "$item"|jq -c '.publishedParsed'|sed 's/\"//g'|grep -Eo '[0-9]{4}\-[0-9]{2}\-[0-9]{2}')
	content_=$(echo "$item"|jq -c '.content'|sed 's/\"//g'|sed 's/<[^>]*>//g;s/&#[0-9]\{4\};//g;s/\\n\|&lt;\|&gt;\|\/p//g;s/[jJ]ubi\.id//g;s/[jJ]ubi//g')
	photo_=$(curl -q -s $link_|grep -Eo -m1 'https://jubi.id/wp-content/uploads/[0-9]{4}/[0-9]{2}/.*\.[a-zA-Z0-9]{2,}')
	#if [[ -z $photo_ ]]; then
	convert $photo_ -background '#00000080' -pointsize 30 -fill white -gravity South -splice 0x40 -annotate +0+10 "$title_" -thumbnail 600x400! -strip ./tmps/pictures/$filename_.jpg 2>/dev/null
	#fi
	echo $guid_
	echo $title_
	echo $link_
	echo $published_
	echo $photo_
	echo "Judul:[$title_] Berita:[$content_] . Sumber:[$jubiTitle_ - $published_]"|ollama run gemma3:4b "$AI_PROMPT" 2>/dev/null|tee -a ./tmps/scripts/newsgenerated_$filename_.txt
done
