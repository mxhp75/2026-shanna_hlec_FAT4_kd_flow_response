#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/featurecounts-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/featurecounts-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=02:00:00
#SBATCH --mem=8GB

# Gene-level counts from the deduplicated BAMs (STAR GeneCounts cannot be applied after deduplication).
# -p --countReadPairs: count fragments (read pairs); -s 2: reverse-stranded; multi-mapping reads not counted (default, as for STAR GeneCounts)

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

DEDUP_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/umi_dedup
GTF=/scratchdata1/groups/phoenix-hpc-sacgf/reference/hg38/General/Annotations/gencode.v39.annotation.gtf
OUT_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/featurecounts

mkdir -p "$OUT_DIR"

featureCounts \
    -T 8 \
    -p --countReadPairs \
    -s 2 \
    -a "$GTF" \
    -o "$OUT_DIR/featurecounts_dedup.txt" \
    "$DEDUP_DIR"/*.dedup.bam
