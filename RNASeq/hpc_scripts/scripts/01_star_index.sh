#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/star_index-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/star_index-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=02:00:00
#SBATCH --mem=64GB

# For the record only - NOT re-run for the UMI re-processing.
# The existing index (built 2026-09-30, STAR 2.7.11b in the 'rnaseq' environment, versionGenome 2.7.4a) is reused by 05_star_align_umi.sh.

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate rnaseq

GENOME_FASTA=/hpcfs/groups/phoenix-hpc-sacgf/reference/hg38/Curated/hg38_analysis_sets/no_alt/hg38_no_alt.fasta
GTF=/scratchdata1/groups/phoenix-hpc-sacgf/reference/hg38/General/Annotations/gencode.v39.annotation.gtf
INDEX_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/index

mkdir -p $INDEX_DIR

STAR --runMode genomeGenerate \
     --genomeDir $INDEX_DIR \
     --genomeFastaFiles $GENOME_FASTA \
     --sjdbGTFfile $GTF \
     --runThreadN 8
