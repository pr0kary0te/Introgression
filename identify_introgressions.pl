#!/usr/bin/perl


#Anything following a # symbol is a comment

#Set the maximum allele frequency cutoff for a putative introgression: 
$max_hex_prop = 0.2;

#Set $string to be the relative you want to compare against, e.g. "S_cereale" for Rye or "Ae_"
#to all Aegilops species:



$string = $ARGV[0];
chomp $string;
#$string = "S_cereale";

#Don't change anything beneath this line
#_________________________________________________________________________________________


#First load the lookup data linking axiom IDs to popseq and consensus map positions
open(MAP, "map_info.txt" || die "Can't open mapinfo.txt");
$head = <MAP>;
%chrs =();

while(<MAP>)
{
chomp;
($axiom, $chr, $pos)= split(/\t/, $_);
if($chr =~ /\d/){$axiom2chr{$axiom} = $chr; $chrs{$chr}++;}
if($pos =~ /\d/){$pos =~ s/[^0-9\.]//g; $axiom2cM{$axiom} = $pos; 
#print "$axiom x $axiom2chr{$axiom} x $axiom2cM{$axiom}\n";
}

}

$n = keys %axiom2chr;
print "Loaded $n axiom probes with a chromosome location in mapinfo.txt\n";
close MAP;

#foreach $axiom(keys %axiom2chr){print "Axiom $axiom Chr $axiom2chr{$axiom} Cm $axiom2cM{$axiom}\n";}

if(-e $string){}else{`mkdir $string`;}




#Now load the lookup data classifying varieties as either hexaploid or relative
open(TYPE, "sample_type.txt" || die "Couldn't open the sampletype.txt file\n");
$head = <TYPE>;
chomp $head;
while (<TYPE>)
{
chomp;
($sample,$type, @other) = split(/\t/, $_);
$sample =~ s/[^A-Za-z0-9_-]//g;
$case_samples{$sample}++;
$species = pop(@other);
$genus = pop(@other);
$species = "${genus}_$species";
$sample2species{$sample} = $species;
#$sample = lc($sample);
#$no_case_samples{$sample}++;
#if($no_case{$samples} > 1){print "Duplicate found in sample_type file when lower cased: $sample\n";}

 if($sample =~ /\D/ && $type =~ /hex/i)
 {
 $type{$sample}= "wheat";
 #print "$sample is $type{$sample}\n";
 }
 else{$type{$sample} = "relative";  
 #print "$sample is $type{$sample}\n";
 }
}
foreach $case(keys %case_samples){$n = $case_samples{$case}; if($n >1){print "$case had $n entries in sample_type.txt\n";}}
$n = keys %type; print "Loaded hex/relative classification for $n samples\n";

#if(keys %case_samples != keys %no_case_samples){die "Unique sample names compromised by loss of case sensitivity: check names!\n";}

open(DATA, "genotyping_data.txt"||die "Couldn't open genotyping_data.txt\n");
$head = <DATA>;
#$head = lc($head);

chomp $head;
($id,@head) = split(/\t/, $head);
$head2 = join("\t", @head); chomp $head2;
foreach $chr(keys %chrs)
 {open($chr, ">$string/$chr.data.txt"); 
 #print "Created output file $string\/$chr\n"; 
 print $chr "Flag\taxiom\tchr\tpos\t$head2\n"; 
 }

$i = 0;
foreach $variety(@head)
 {
 $variety =~ s/[^A-Za-z0-9_-]//g;
 $type = $type{$variety};
 $types[$i] = $type;
 if($type !~ /wheat|relative/){print "\nBAD Variety $variety is unknown type\n";die;}
 #else{print "\nVariety $variety = $type\n"}
 $i++;
 }

while(<DATA>)
{
%relative = ();
%hex =();
chomp;
($axiom, @data) = split(/\t/, $_);

$chr = $axiom2chr{$axiom};
$pos = $axiom2cM{$axiom};

if($chr =~ /[1-7]/ && $pos =~ /\d/)
{
#print "Axiom $axiom Chr $chr pos $pos\n";
$i = 0;

#loop through first to identify calls found in relatives

foreach $datum(@data)
 {
 $type = $types[$i];
 $variety = $head[$i];
 $species = $sample2species{$variety};
 if   ($datum =~ /[AB]+/ && $type =~ /relative/ && $species =~ /$string/i){$relative{$datum}++; }

 #if   ($datum =~ /[AB]+/ && $type =~ /relative/ && $variety =~ /$string/i){$relative{$datum}++; }



 elsif($datum =~ /[AB]+/ && $type =~ /wheat/){$hex{$datum}++;  }
 $i++;
 }


$intro = 0; $wheat = 0;
foreach $datum(keys %hex){if($relative{$datum}>0) {$intro += $hex{$datum};} else{$wheat+= $hex{$datum} ;}}
$prop = 1;
if($intro >0 && $wheat>0){$prop = $intro/($intro + $wheat);}

if(keys %relative == 1 && $prop <0.2)
{
$flag = 1;
#print "introgression: $axiom\t$chr\t$pos\n";
}
else{$flag =0;}

#Change the line below to $flag >=0 to include non-candidate rows
if($flag >= 0)
{
print $chr "$flag\t$axiom\t$chr\t$pos";


 $i = 0;
 foreach $datum(@data)
  {
  $type = $types[$i]; $i++;
  if   ($type =~ /relative/){print $chr "\t-";}
  elsif ($type =~ /wheat/)
     { 
     if($relative{$datum} >0){print $chr "\t1";}
     else {print $chr "\t0";}
     }
else {print $chr "x";}  
}
 print $chr "\n";
 }
}
}

foreach $chr (keys %chr){close $chr;}
