#!/usr/local/bin/perl

use strict;
use warnings;
use List::Util qw(sum);
my %hash;
my @LineTotalsArray;
my @output;
my $i = 1;
my $header;
my @values;

my @criteria;
my @previous_split;
my $previous_outline;
my @final_array;
my $match = 0;



         my $dir=$ARGV[0] || die ("Please give me an INPUT directory eg Ae_Bicornis/  \n");

my $path = `pwd`;
chomp $path;
my $pathname = $path."/".$dir;
my @dirlist = `ls $pathname`;
chomp @dirlist;

foreach (@dirlist){

my $chr = substr($_, 0, 2);

my $inputfile = $pathname."/".$_;

open my $fh, '<', $inputfile or die $!;

my @array = `sort -k1g -k3,3 -k4,4n $inputfile`;

$header = $array[0];

### Remove flag field from header ###
$header =~ s/^Flag\t//;


shift @array;


#### push header onto @values array ###
push (@values,  $header);


foreach(@array){

my $line = $_;
chomp $line;

my ($flag,$axiom,$chr,$pos,$rest) = split(/\t/, $line, 5);
#my ($axiom, $pos, $chr, $rest) = split(/\t/, $line, 4);


   my $index=0;
   for my $val ( split /\t/, $rest ) {

	if ($val ne "-"){
        $LineTotalsArray[ $index++ ] += $val;
	}
	else {$LineTotalsArray[ $index++ ] = $val;}

   }


	if($i == 10){

	$LineTotalsArray[ $index++ ];
		
		foreach my $x (@LineTotalsArray){
	               	if ($x ne  "-"){
        	       	$x = $x / $i;
                	}
			else{ $x = 0;}

		}
#print $axiom."\t".$pos."\t".$chr."\t";
#print $axiom."\t";
#print join("\t", @LineTotalsArray), "\n";

my $line = join("\t", @LineTotalsArray);

#### Remove Gary's flag ###
#my $outline = $flag."\t".$axiom."\t".$chr."\t".$pos."\t".$line;
my $outline = $axiom."\t".$chr."\t".$pos."\t".$line;


push (@output, $outline);

	$i = 0;
	undef @LineTotalsArray;
	}

$i ++;
}

}

### Add Chr field to header ###

#my ($fld1, $fld2, $fld3, $fld4) = split(/\t/, $header, 4);

#$header = $fld1."\t".$fld2."\tChromosome\t".$fld3."\t".$fld4;

### Print out all files ###
foreach (@output){

push(@values, $_);

}


#####################################################
### Next part of pipeliine
#####################################################


my $header2 = shift(@values); 
chomp $header2;
print $header2;

@values = grep(!/Axiom/, @values);


foreach(@values){

my $line = $_;
chomp $line;

#print "LINE = $line \n";

#my ($garyflag, $axiom, $chr, $pos, $rest) = split(/\t/, $line, 5);
my ($axiom, $chr, $pos, $rest) = split(/\t/, $line, 4);

#print $rest."\n";

my @scores = split(/\t/,$rest);

	### Check if array contains an element with score greater than 0.4 ###
	if (grep {$_ >= 0.1} @scores) {
#    	print "Yes, at least one in $axiom is bigger than 0.4\n";
		push (@criteria, $line);

		if ($match == 1) {	

			foreach (@criteria){
				my $outline = $_;
				my ($out_axiom, $out_pos, $out_chr, $out_rest) = split(/\t/, $outline, 4);	

					my @split_rest = split(/\t/, $out_rest);					
					
						my $new_string;
						my $checkpoint;

							#my @slice = @split_rest[0..405];
						
							

							### Create a string for output
							foreach(@split_rest){
								if ($_ >= 0.4 ){
								
								$new_string = $new_string."$_\t";	

								#print "[@split_rest] and [@previous] Match!!!!!\n"  if elementwise_eq( \(@split_rest, @previous) );	
								}
								
								else{
								$new_string = $new_string."_\t";
								}
							}



								### Initialize fla variables ###
								my $flag = 0;
								my $i = 3; 

			### check that current and previous variables were both greater than the 0.4 cutoff ###
			for my $i (1 .. $#split_rest) {
   if ($split_rest[$i] >= 0.4 &&  $previous_split[$i]  >= 0.4) {
      $flag = 1;
   }   
}
								### Check if there is a preceeding bin using $flag variable ###
								if ($flag == 1){ 
									
								
									my ($pout_axiom, $pout_pos, $pout_chr, $pout_rest) = split(/\t/, $previous_outline, 4);
									my @p_split_rest = split(/\t/, $pout_rest);

								my $p_new_string;

                                                        foreach(@p_split_rest){
                                                                if ($_ >= 0.4 ){
                                                                $p_new_string = $p_new_string."$_\t";
								}
                                                                else{
                                                                $p_new_string = $p_new_string."_\t";
                                                                }
                                                       	}

									### Assign output string to variable ###
									my $p_final =  $pout_axiom."\t".$pout_pos."\t".$pout_chr."\t".$p_new_string."\n";
									my $final = $out_axiom."\t".$out_pos."\t".$out_chr."\t".$new_string."\n";
									#print $pout_axiom."\t".$pout_pos."\t".$pout_chr."\t".$p_new_string."\n";
									#print  $out_axiom."\t".$out_pos."\t".$out_chr."\t".$new_string."\n";
									
									push (@final_array, $p_final);
									push (@final_array, $final);								
									
									}
								

								else{ 
									
								
									my ($pout_axiom, $pout_pos, $pout_chr, $pout_rest) = split(/\t/, $previous_outline, 4);
									my @p_split_rest = split(/\t/, $pout_rest);

								my $p_new_string;

                                                        foreach(@p_split_rest){
                                                                if ($_ >= 0.4 ){
                                                                $p_new_string = $p_new_string."$_\t";
								}
                                                                else{
                                                                $p_new_string = $p_new_string."_\t";
                                                                }
                                                       	}

									### Assign output string to variable ###
									my $p_final =  $pout_axiom."\t".$pout_pos."\t".$pout_chr."\t".$p_new_string."\n";
									my $final = $out_axiom."\t".$out_pos."\t".$out_chr."\t".$new_string."\n";
									#print $pout_axiom."\t".$pout_pos."\t".$pout_chr."\t".$p_new_string."\n";
									#print  $out_axiom."\t".$out_pos."\t".$out_chr."\t".$new_string."\n";
									
									push (@final_array, $p_final);
									push (@final_array, $final);								
									

									
									}






			@previous_split = @split_rest;
			$previous_outline = $outline;			
			}

		
		undef  @criteria;
	
		}
	
	$match = 1;
	}


	## If array contains an element < 0.4 ####
	else{
	$match = 0;
#	my $number_of_tabs = 100;
#	my $tabbed_line = "_\t" x $number_of_tabs;
#	my $blank_line  = $axiom."\t".$pos."\t".$chr."\t".$tabbed_line;
	my $blank_line  = $line;	
	push (@final_array, $blank_line);
	undef @criteria;
	undef @previous_split;
	undef $previous_outline;
	}


	



undef @scores;



}



#########   Print out final data ###########


my @filtered = uniq(@final_array);

### remove trailing tabs ###
s{\t+$}{}g foreach @filtered;
foreach(@filtered){
	print $_;
	}



### Subroutine to remove duplicates from array ###
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

