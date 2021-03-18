#!/usr/bin/perl

@files = `ls -l |grep ^d`;
`mkdir OUTPUT`;

foreach $file(@files)
{
chomp $file;
@data = split(/\s+/, $file);
$file = pop @data;
print "$file\n";
`./pipeline.pl $file > OUTPUT/${file}_INTROGRESSIONS_TABBED.txt`;

}
