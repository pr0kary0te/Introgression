#!/bin/sh

while read line
do
echo $line

perl pipeline.pl $line > "OUTPUT/"$line"_INTROGRESSIONS_TABBED.txt"

done < dir_names

