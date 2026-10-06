#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/star_align_umi-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/star_align_umi-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=08:00:00
#SBATCH --mem=64GB

# Same index and STAR settings as the original alignment, on UMI-extracted, trimmed reads.
# ReadsPerGene.out.tab here = trimmed but NOT deduplicated counts (useful for comparison with the original and deduplicated counts).

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

FASTQ_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/trimmed
INDEX_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/index
GTF=/scratchdata1/groups/phoenix-hpc-sacgf/reference/hg38/General/Annotations/gencode.v39.annotation.gtf
ALIGN_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/star_align_umi

mkdir -p "$ALIGN_DIR"

for R1 in "$FASTQ_DIR"/*_R1.trimmed.fastq.gz; do

    # Get sample name, e.g. 26-03807_S1_L03
    SAMPLE=$(basename "$R1" _R1.trimmed.fastq.gz)

    # Corresponding R2 file
    R2="$FASTQ_DIR/${SAMPLE}_R2.trimmed.fastq.gz"

    # Check that R2 exists
    if [[ ! -f "$R2" ]]; then
        echo "ERROR: Missing R2 file for $SAMPLE"
        exit 1
    fi

    OUT="$ALIGN_DIR/$SAMPLE"
    mkdir -p "$OUT"

    echo "Aligning $SAMPLE"
    echo "  R1: $R1"
    echo "  R2: $R2"

    STAR --runMode alignReads \
         --genomeDir "$INDEX_DIR" \
         --readFilesIn "$R1" "$R2" \
         --readFilesCommand zcat \
         --outSAMtype BAM SortedByCoordinate \
         --outSAMattributes NH HI AS NM MD \
         --quantMode GeneCounts \
         --sjdbGTFfile "$GTF" \
         --outFileNamePrefix "$OUT/" \
         --runThreadN 8

    # index for umi_tools dedup
    samtools index -@ 8 "$OUT/Aligned.sortedByCoord.out.bam"

done
