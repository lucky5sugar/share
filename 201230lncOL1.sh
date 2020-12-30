#!/bin/bash
## dependencies: sratoolkit, STAR, samtools, deeptools

## 1. load essential modules
module load sratoolkit
module load STAR
module load samtools
mkdir ~/lncOL1

## 2. download and extract fastq from sra
## Ctrl
prefetch SRR3623488
## lncOL1 KO
prefetch SRR3623490
fastq-dump -O ~/lncOL1/fastq ~/ncbi/public/sra/SRR3623488.sra
fastq-dump -O ~/lncOL1/fastq ~/ncbi/public/sra/SRR3623490.sra

## 3. Trimming 
fastp -i ~/lncOL1/fastq/SRR3623488.fastq -o ~/lncOL1/fastq/SRR3623488.clean.fastq -w 10 -h ~/lncOL1/fastq/SRR3623488.fastp.html
fastp -i ~/lncOL1/fastq/SRR3623490.fastq -o ~/lncOL1/fastq/SRR3623490.clean.fastq -w 10 -h ~/lncOL1/fastq/SRR3623490.fastp.html

## 2. STAR mapping
STAR runMode alignReads --runThreadN 10 --genomeDir ~/Mus_musculus/NCBI/GRCm38/Sequence/STARIndex/ \
--readFilesIn ~/lncOL1/fastq/SRR3623488.clean.fastq \
--outFileNamePrefix ~/lncOL1/STAR_results/control.bam \
--outStd BAM_Unsorted --outSAMtype BAM Unsorted \
> ~/lncOL1/STAR_results/control.bam

STAR runMode alignReads --runThreadN 10 --genomeDir ~/Mus_musculus/NCBI/GRCm38/Sequence/STARIndex/ \
--readFilesIn ~/lncOL1/fastq/SRR3623490.clean.fastq \
--outFileNamePrefix ~/lncOL1/STAR_results/lncOL1KO.bam \
--outStd BAM_Unsorted --outSAMtype BAM Unsorted \
> ~/lncOL1/STAR_results/lncOL1KO.bam

## 3. clean bam files and make it visualise at IGV
cd ~/lncOL1/STAR_results/
samtools sort -o control.sort.bam control.bam
samtools index control.sort.bam
samtools sort -o lncOL1KO.sort.bam lncOL1KO.bam
samtools index lncOL1KO.sort.bam

bamCoverage -p 10 --bam control.sort.bam \
-o control.bw \
--normalizeUsing CPM --effectiveGenomeSize 2652783500

bamCoverage -p 10 --bam lncOL1KO.sort.bam \
-o lncOL1KO.bw \
--normalizeUsing CPM --effectiveGenomeSize 2652783500