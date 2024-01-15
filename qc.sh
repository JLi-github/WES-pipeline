#!/bin/bash

#SBATCH --account=cdsc_project1
#SBATCH --job-name=fastqc
#SBATCH --mail-type=NONE
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1G
#SBATCH --time=03:00:00

which fastqc
fastqc --version

fastq_dir="/projects/WES/raw_data" 

cd $fastq_dir/ctrl

for i in $(ls *.fq.gz)
do
	echo $i
	sample_name=$(echo $i | xargs -n1 basename | awk '{gsub(".fq.gz",""); print}')
	echo $sample_name
	
	fastqc -f fastq --extract $i  --outdir=$fastq_dir/qc/fastqc/

done

cd $fastq_dir/trt

for i in $(ls *.fq.gz)
do
	echo $i
	sample_name=$(echo $i | xargs -n1 basename | awk '{gsub(".fq.gz",""); print}')
	echo $sample_name
	
	fastqc -f fastq --extract $i  --outdir=$fastq_dir/qc/fastqc/

done

# # Running multiqc
# # Activate conda environment
# conda activate mageck-vispr

# which multiqc
# multiqc --version

# multiqc -o $fastq_dir/qc/multiqc/ $fastq_dir/qc/fastqc/