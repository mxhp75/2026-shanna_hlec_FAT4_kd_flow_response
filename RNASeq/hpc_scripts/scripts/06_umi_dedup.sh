#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_dedup-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_dedup-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --time=48:00:00
#SBATCH --mem=32GB

# Paired-end UMI deduplication (directional method, the umi_tools default).
# Runtime is the main uncertainty: check the per-sample time on the first sample and adjust --time, or switch to a job array.

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

ALIGN_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/star_align_umi
OUT_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/umi_dedup

mkdir -p "$OUT_DIR"

for BAM in "$ALIGN_DIR"/*/Aligned.sortedByCoord.out.bam; do

    # Get sample name from the sample sub-directory, e.g. 26-03807_S1_L03
    SAMPLE=$(basename "$(dirname "$BAM")")

    echo "Deduplicating $SAMPLE"

    # --multimapping-detection-method=NH: use STAR's NH tag to handle multi-mapped reads
    umi_tools dedup \
        --stdin="$BAM" \
        --stdout="$OUT_DIR/${SAMPLE}.dedup.bam" \
        --paired \
        --multimapping-detection-method=NH \
        --log="$OUT_DIR/${SAMPLE}.dedup.log"

    samtools index "$OUT_DIR/${SAMPLE}.dedup.bam"

done
