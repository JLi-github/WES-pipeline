#!/bin/bash

#SBATCH --account=1
#SBATCH --job-name=bwa
#SBATCH --mail-type=NONE
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00

# This script does bwa mem alignment (Ctrl, Trt samples)
 

GRC_GENOME="GRCm38" #GRCm38.p6
RELEASE="M25"
SPECIES="mouse"
GENOME="mm10"

main_dir="C:/projects/WES"
working_dir=$main_dir/alignment
MY_TMP_DIR=$working_dir/tmp
mkdir -p $TMP_DIR
trimmed_dir="C:/WES/raw_data/trimmed/"
bwa_fasta_dir="C:/WES/annotation/gencode.M25/aligner-indeces/bwa"

ml restore
ml list

samples="Ctrl Trt"

for mysample in $samples
do
	# Run alignment and flagstat
	start=`date +%s`
	echo Start time is $start
	echo Sample is $mysample
	echo
	read1_fastq=$(ls $trimmed_dir | grep Sample_${mysample}_1_trimmed.fq.gz)
	read2_fastq=$(ls $trimmed_dir | grep Sample_${mysample}_2_trimmed.fq.gz)
	echo Running bwa mem
	echo
	cmd="bwa mem -t 16 -M -R \"@RG\tID:${mysample}\tSM:Sample_${mysample}\" $bwa_fasta_dir/$GRCm38.p6.genome.fa \
	$trimmed_dir/$read1_fastq $trimmed_dir/$read2_fastq | samtools view -bh -@ 16 - | samtools sort -@ 16 -m 4G -O bam -o ${working_dir}/Sample_${mysample}_sorted.bam - "
	echo $cmd
	eval $cmd
	
	echo
	echo Indexing bam file 
	echo
	cmd="samtools index ${working_dir}/Sample_${mysample}_sorted.bam"
	echo $cmd
	eval $cmd
	
	
	echo
	echo Running first samtools flagstat 
	echo
	cmd="samtools flagstat ${working_dir}/Sample_${mysample}_sorted.bam > ${working_d
ir}/Sample_${mysample}_flagstat1.log"
	echo $cmd
	eval $cmd
	
	end=`date +%s`
	echo End time is $end
	runtime=$((end-start))
	echo Runtime is $runtime
	echo
	
	# Run markduplicates and flagstat
	start=`date +%s`
	echo Start time is $start
	echo
	echo Running GATK MarkDuplicates
	echo
	cmd="gatk MarkDuplicates -I $working_dir/Sample_${mysample}_sorted.bam -M $working_dir/Sample_${mysample}_sorted_metrics.txt -O $working_dir/Sample_${mysample}_sorted_dups.bam --ASSUME_SORT_ORDER coordinate --REMOVE_DUPLICATES false --TMP_DIR $MY_TMP_DIR --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 --VALIDATION_STRINGENCY SILENT --MAX_RECORDS_IN_RAM 4000000 --CREATE_INDEX true --MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP 50000 --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 8000 --SORTING_COLLECTION_SIZE_RATIO 0.25 --TAG_DUPLICATE_SET_MEMBERS false --REMOVE_SEQUENCING_DUPLICATES false --TAGGING_POLICY DontTag --CLEAR_DT true --ADD_PG_TAG_TO_READS true --DUPLICATE_SCORING_STRATEGY SUM_OF_BASE_QUALITIES --PROGRAM_RECORD_ID MarkDuplicates --PROGRAM_GROUP_NAME MarkDuplicates --READ_NAME_REGEX \<optimized\ capture\ of\ last\ three\ \'\:\'\ separated\ fields\ as\ numeric\ values\> --MAX_OPTICAL_DUPLICATE_SET_SIZE 300000 --VERBOSITY INFO --QUIET false --COMPRESSION_LEVEL 5 --CREATE_MD5_FILE false --GA4GH_CLIENT_SECRETS client_secrets.json --USE_JDK_DEFLATER false --USE_JDK_INFLATER false"

	echo $cmd
	eval $cmd
	
	echo
	echo Running second samtools flagstat 
	echo
	cmd="samtools flagstat ${working_dir}/Sample_${mysample}_sorted_dups.bam > ${working_dir}/Sample_${mysample}_flagstat2.log"
	echo $cmd
	eval $cmd
	
	end=`date +%s`
	echo End time is $end
	runtime=$((end-start))
	echo Runtime is $runtime
	echo -e "\n\n"
	echo "============================================================"
	echo -e "\n\n"

done




