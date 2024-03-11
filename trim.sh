#!/bin/bash

#SBATCH --account=1
#SBATCH --job-name=trimfastq
#SBATCH --mail-type=NONE
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00

my_conda_env="trimmers"
eval "$(conda shell.bash hook)"
conda activate $my_conda_env

fastq_dir="/projects/WES/raw_data"
trimmed_dir=$fastq_dir/trimmed
mkdir -p $trimmed_dir >/dev/null

echo
which cutadapt
cutadapt --version
echo



rm -r $trimmed_dir/Sample_Ctrl_1_trimmed.fq 2>/dev/null
rm -r $trimmed_dir/Sample_Ctrl_2_trimmed.fq 2>/dev/null

echo Trimming Ctrl
cutadapt \
-a CCCTACACGACGCTCTTCCGATCTAATGATACGGCGACCACCGAGATCTACACTCTTT \
-A CCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTGGATCGGAAGAGCACACGTCTGAACT \
--report=full \
--pair-filter=any \
--discard-trimmed \
-e 0.1 \
--overlap 5 \
-q 11 \
--max-n 0.1 \
--cores=0 \
-o $trimmed_dir/Sample_Ctrl_1_trimmed.fq \
-p $trimmed_dir/Sample_Ctrl_2_trimmed.fq \


rm -r $trimmed_dir/Sample_Trt_1_trimmed.fq 2>/dev/null
rm -r $trimmed_dir/Sample_Trt_2_trimmed.fq 2>/dev/null

echo Trimming Trt
cutadapt \
-a CCCTACACGACGCTCTTCCGATCTAATGATACGGCGACCACCGAGATCTACACTCTTT \
-A CCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTGGATCGGAAGAGCACACGTCTGAACT \
--report=full \
--pair-filter=any \
--discard-trimmed \
-e 0.1 \
--overlap 5 \
-q 11 \
--max-n 0.1 \
--cores=0 \
-o $trimmed_dir/Sample_Trt_1_trimmed.fq \
-p $trimmed_dir/Sample_Trt_2_trimmed.fq \


rm -r $trimmed_dir/Sample_Ctrl_1_trimmed.fq 2>/dev/null
rm -r $trimmed_dir/Sample_Ctrl_2_trimmed.fq 2>/dev/null

echo CA Trimming Ctrl
cutadapt \
-a CCCTACACGACGCTCTTCCGATCTAATGATACGGCGACCACCGAGATCTACACTCTTT \
-A CCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTGGATCGGAAGAGCACACGTCTGAACT \
--report=full \
--pair-filter=any \
--discard-trimmed \
-e 0.1 \
--overlap 5 \
-q 11 \
--max-n 0.1 \
--cores=0 \
-o $trimmed_dir/Sample_Ctrl_1_trimmed.fq \
-p $trimmed_dir/Sample_Ctrl_2_trimmed.fq \
$fastq_dir/Ctrl_9854/Ctrl_9854_FKDN202471220-1A_HC35YDSXY_L24_1.fq.gz \
$fastq_dir/Ctrl_9854/Ctrl_9854_FKDN202471220-1A_HC35YDSXY_L24_2.fq.gz

samples="Ctrl Trt"

# touch $trimmed_dir/trimming_counts.txt
touch $trimmed_dir/trimming_counts.txt
echo -e "Sample\Trimmed_R1\Trimmed_R2" > $trimmed_dir/trimming_counts.txt

for sample in $samples
do
	echo Sample is $sample
	# r1_trimmed=`echo $(zcat $trimmed_dir/Sample_${sample}_1_trimmed.fq.gz | wc -l)/4|bc`
	# r2_trimmed=`echo $(zcat $trimmed_dir/Sample_${sample}_2_trimmed.fq.gz | wc -l)/4|bc`
	# r1_rejects=`echo $(zcat $trimmed_dir/Sample_${sample}_1_rejects.fq.gz | wc -l)/4|bc`
	# r2_rejects=`echo $(zcat $trimmed_dir/Sample_${sample}_2_rejects.fq.gz | wc -l)/4|bc`
	r1_trimmed=`echo $(cat $trimmed_dir/Sample_${sample}_1_trimmed.fq | wc -l)/4|bc`
	r2_trimmed=`echo $(cat $trimmed_dir/Sample_${sample}_2_trimmed.fq | wc -l)/4|bc`
	# r1_CAuntrimmed_noadapt=`echo $(cat $trimmed_dir/Sample_${sample}_1_untrimmed_noadapt.fq| wc -l)/4|bc`
	# r2_CAuntrimmed_noadapt=`echo $(cat $trimmed_dir/Sample_${sample}_2_untrimmed_noadapt.fq | wc -l)/4|bc`
	
	# echo -e "Sample_${sample}\t$r1_trimmed\t$r2_trimmed\t$r1_rejects\t$r2_rejects\t$r1_trimmed\t$r2_trimmed" >> $trimmed_dir/trimming_counts.txt
	echo -e "Sample_${sample}\t$r1_trimmed\t$r2_trimmed" >> $trimmed_dir/trimming_counts.txt

done

exit
