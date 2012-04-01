#!/bin/sh

names="http://purl.org/ontology/bibo/Book http://purl.org/ontology/bibo/Proceedings	http://vivoweb.org/ontology/core#ConferencePaper	http://purl.org/ontology/bibo/AcademicArticle	http://purl.org/ontology/bibo/Patent	http://purl.org/ontology/bibo/Report	http://vivoweb.org/ontology/core#Software	http://purl.org/ontology/bibo/Performance	http://vivoweb.org/ontology/core#Score			http://vivoweb.org/ontology/core#Exhibit		http://purl.org/ontology/bibo/Webpage	http://purl.org/ontology/bibo/Article	http://vivoweb.org/ontology/core#ConferencePoster	http://purl.org/ontology/bibo/Thesis	http://purl.org/ontology/bibo/Film"

for i in $names
do
   echo $i
   matches=`grep "$i" data/translated-records/* | cut -f1 -d':' | sort -u`
   if [[ "a$matches" != "a" ]]
   then 
     echo Tags
     perl -pe  's/.*?[\/<](.*?)[ \/>].*/XX\1XX/g' $matches  | grep XX | sort -u | sed 's/XX//g'
     echo Files
     for m in $matches
     do
        echo $m
     done
   fi
done
