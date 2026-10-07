#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_extract-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_extract-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --time=12:00:00
#SBATCH --mem=8GB

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

FASTQ_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/sequence_data
OUT_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/umi_extract

mkdir -p "$OUT_DIR"

for R1 in "$FASTQ_DIR"/*_R1_001.fastq.gz; do

    # Get sample name, e.g. 26-03807_S1_L03
    SAMPLE=$(basename "$R1" _R1_001.fastq.gz)

    # Corresponding R2 file
    R2="$FASTQ_DIR/${SAMPLE}_R2_001.fastq.gz"

    # Check that R2 exists
    if [[ ! -f "$R2" ]]; then
        echo "ERROR: Missing R2 file for $SAMPLE"
        exit 1
    fi

    echo "Extracting UMI for $SAMPLE"

    # R2 structure: N (pos 1) + 10-nt UMI (pos 2-11) + GCAGGG linker (pos 12-17, 1 mismatch allowed); R1 has no UMI.
    # The UMI is moved into both read names; the N, UMI and linker are removed from R2.
    # Read pairs whose R2 does not match the pattern (e.g. 1-base shift, missing linker) are discarded.
    umi_tools extract \
        --extract-method=regex \
        --bc-pattern2='^(?P<discard_1>.)(?P<umi_1>.{10})(?P<discard_2>GCAGGG){s<=1}' \
        --stdin="$R1" \
        --read2-in="$R2" \
        --stdout="$OUT_DIR/${SAMPLE}_R1.umi.fastq.gz" \
        --read2-out="$OUT_DIR/${SAMPLE}_R2.umi.fastq.gz" \
        --log="$OUT_DIR/${SAMPLE}.umi_extract.log"

done
