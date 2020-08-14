#!/usr/bin/perl


#This is the wrapper script for running the introgression analsis.
#It will take all of the genera listed in the sample_type.txt file and test these one at a time as potential sources of introgression 
#The data analysis script identify_introgressions.pl is called for each genus in the final foreach loop below. 


$min = 1;

open(IN, "sample_type.txt");
$head = <IN>;
while(<IN>)
{
chomp;
($id, $type, @other) = split(/\t/, $_); 
$species = pop(@other);
$genus = pop(@other);
$type = "${genus}_$species";
print "$type\n";
if($type !~ /Triticum_aestivum/){$types{$type}++;}
}

foreach $type(sort keys %types){$n = $types{$type}; $type_by_count{$n}{$type}++;}
close IN;

foreach $n (sort {$b <=>$a} keys %type_by_count)
   {
   $ref = $type_by_count{$n};
   %hash = %$ref;
   foreach $type(sort keys %hash)
      {
      if($n >= $min)
         {
         print "$n\tRunning analysis for $type\n";
         if(-e $type){} else{`mkdir $type`;}
         
         #Introgression finding script is called here for the current genus (potential introgression donor)
         $out = `./identify_introgressions.pl $type`;
         print $out;
         }
      }

   }
