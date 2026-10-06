#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/fastqc_multiqc_umi-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/fastqc_multiqc_umi-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=02:00:00
#SBATCH --mem=8GB

# FastQC on the trimmed reads, then one MultiQC report across all UMI re-processing steps
# (umi_tools extract/dedup logs, cutadapt, STAR, featureCounts, FastQC).

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

PROJ_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response
FASTQC_DIR=$PROJ_DIR/fastqc_trimmed
MULTIQC_DIR=$PROJ_DIR/multiqc_umi

mkdir -p $FASTQC_DIR $MULTIQC_DIR

fastqc -t 8 -o $FASTQC_DIR $PROJ_DIR/trimmed/*.trimmed.fastq.gz

multiqc \
    $PROJ_DIR/umi_extract \
    $PROJ_DIR/trimmed \
    $PROJ_DIR/star_align_umi \
    $PROJ_DIR/umi_dedup \
    $PROJ_DIR/featurecounts \
    $FASTQC_DIR \
    -o $MULTIQC_DIR
