#!/bin/bash

#SBATCH --account=1
#SBATCH --job-name=StrelkaSOMindel
#SBATCH --output=logs/vcSOM/output-%x-%j.log
#SBATCH --error=logs/vcSOM/error-%x-%j.log
#SBATCH --mail-type=NONE
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00


# Strelka v2.9.10 installed in strelka2910 conda environment is used to call Somatic INDELs

conda_env="strelka2910"
echo Activating $my_conda_env conda environment
source activate_conda.sh $my_conda_env

conda info
echo

GRC_GENOME="GRCm38" #GRCm38.p6
RELEASE="M25"
SPECIES="mouse"
GENOME="mm10"
annot_DB="refGene"

main_annotations_dir="/annotation/annotDB"
annot_dir=$main_annotations_dir/$SPECIES/$GENOME/$annot_DB

main_dir="//WES_mm10"
working_dir=$main_dir/variant_calling

out_dir_somatic=$working_dir/Somatic
mkdir -p $out_dir_somatic

out_dir_indel=$working_dir/Somatic/INDEL
mkdir -p $out_dir_indel

MY_TMP_DIR=$working_dir/tmp
mkdir -p $MY_TMP_DIR
bam_dir="//WES_mm10/alignment"
bwa_fasta_dir="/annotation/gencode.M25/fasta"

samples="Ctrl_vs_Trt"

for mysample in $samples
do
	# Run Strelka
	start=`date +%s`
	normal_sample=$(echo $mysample | echo $mysample | awk -F '_vs_' '{print $2}')
	tumor_sample=$(echo $mysample | echo $mysample | awk -F '_vs_' '{print $1}')
	echo Start time is $start
	echo Sample is $mysample
	mkdir -p $out_dir_indel/${mysample}_scripts
	echo
	
	which configureStrelkaSomaticWorkflow.py
	echo
	echo Running Strelka configureStrelkaSomaticWorkflow.py
	echo
	cmd="configureStrelkaSomaticWorkflow.py --tumorBam=$bam_dir/Sample_${tumor_sample}_sorted_dups.bam --normalBam=$bam_dir/Sample_${normal_sample}_sorted_dups.bam --runDir=$out_dir_indel/${mysample}_scripts --referenceFasta=$bwa_fasta_dir/$GRC_GENOME.primary_assembly.genome.fa"
		
	echo $cmd
	eval $cmd
	
	sleep 5s
	
	echo
	echo Executing Strelka runWorkflow.py
	echo
	cmd="$out_dir_indel/${mysample}_scripts/runWorkflow.py -m local -j 16"
		
	echo $cmd
	eval $cmd
	
	echo
	echo Unzipping $mysample output vfc file
	echo
	cmd="gzip -dk $out_dir_indel/${mysample}_scripts/results/variants/somatic.indels.vcf.gz"
		
	echo $cmd
	eval $cmd
	
	# Only keeping rows with FILTER=PASS 
	echo
	cmd="cat $out_dir_indel/${mysample}_scripts/results/variants/somatic.indels.vcf | grep -E \"^#|PASS\" > $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.vcf"
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

# Deactivate conda environment
conda deactivate

# Restore modules
ml restore
ml load annovar/9.2019
ml list

for mysample in $samples
do
	# Run annovar
	start=`date +%s`

	# VCF file created by strelka needs to be modified before using as input to annovar
	# Specifically, we need to ad GT: to FORMAT column and 0/1: to both samples columns
	cmd="cat <(cat $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.vcf | grep \"^#\") <(cat $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.vcf | grep -v \"^#\" | gawk 'BEGIN {FS=OFS=\"\t\"}{gsub(\"SGT=\",\"GT=\",\$8); \$9=\"GT:\"\$9; \$10=\"0/1:\"\$10; \$11=\"0/1:\"\$11; print \$0}') > $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.mod.vcf"
	echo $cmd
	eval $cmd
	
	
	# Running annovar on modified PASSED ($out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.vcf) INDEL files
	echo
	echo Annotating PASSED INDEL variants with $GENOME $annot_DB
	echo
	cmd="table_annovar.pl $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.mod.vcf $annot_dir/ -buildver $GENOME --outfile $out_dir_indel/${mysample}.Strelka.somatic.indel.PASS.mod -remove -protocol $annot_DB -operation g -nastring . -polish -vcfinput"
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