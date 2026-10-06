#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/trim-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/trim-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=04:00:00
#SBATCH --mem=8GB

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

IN_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/umi_extract
OUT_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/trimmed

mkdir -p "$OUT_DIR"

for R1 in "$IN_DIR"/*_R1.umi.fastq.gz; do

    # Get sample name, e.g. 26-03807_S1_L03
    SAMPLE=$(basename "$R1" _R1.umi.fastq.gz)

    # Corresponding R2 file
    R2="$IN_DIR/${SAMPLE}_R2.umi.fastq.gz"

    # Check that R2 exists
    if [[ ! -f "$R2" ]]; then
        echo "ERROR: Missing R2 file for $SAMPLE"
        exit 1
    fi

    echo "Trimming $SAMPLE"

    # -u 3: remove the fixed TTT at the 5' end of R1 (the R2 N/UMI/linker were already removed by umi_tools extract)
    # -a/-A: 3' adapter read-through - Illumina universal (AGATCGGAAGAGC) and MGI R1/R2 adapters, as the kit is not yet confirmed
    # -q 20: 3' quality trimming; --minimum-length 30: discard the pair if either read is shorter than 30 nt after trimming
    cutadapt \
        -j 8 \
        -u 3 \
        -a AGATCGGAAGAGC -a AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA \
        -A AGATCGGAAGAGC -A AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG \
        -q 20 \
        --minimum-length 30 \
        -o "$OUT_DIR/${SAMPLE}_R1.trimmed.fastq.gz" \
        -p "$OUT_DIR/${SAMPLE}_R2.trimmed.fastq.gz" \
        "$R1" "$R2" > "$OUT_DIR/${SAMPLE}.cutadapt.log"

done
