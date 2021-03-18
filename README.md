# Introgression
Scripts to find putative introgressions using wheat axiom array data

Download this script (script.pl) and identify_introgressions.pl and put in the same directory as the data files:
sample_type.txt, map_info.txt and genotyping_data.txt. These are all available as a zip file at http://www.cerealsdb.uk.net/introgression_data.tar.gz as they are too large to host here

Check that script.pl and identify_introgressions.pl are both executable and that the directory has RW permissions then run with:
nohup ./script.pl &

Once the job is complete, the output files can be processed with the use of the pipeline.pl script, with the shell script process_files.sh feeding all of the directories created by script.pl into the pipeline one at a time:
nohup ./process_files.sh &


