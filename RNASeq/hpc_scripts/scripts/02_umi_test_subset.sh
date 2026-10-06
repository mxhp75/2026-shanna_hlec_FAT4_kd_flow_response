#!/bin/bash
#SBATCH -p sacgf

#SBATCH -o /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_test-%j.out
#SBATCH -e /scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/slurm_logs/umi_test-%j.err

#SBATCH --mail-type=all
#SBATCH --mail-user=melanie.smith@adelaide.edu.au
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=02:00:00
#SBATCH --mem=64GB

# Test the full UMI pipeline (scripts 03-07) on the first 1M read pairs of two samples before running on all libraries:
#   26-03807_S1_L03 (CSMT16, typical) and 26-03810_S4_L03 (FLMT16, GC-bias sample)
# Dedup rates on a 1M-pair subset will be much lower than on full libraries - this is a check that each step works, not a duplication estimate.

module load Anaconda3/2025.06-1
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate hlec_umi

# stop on any error, unset variable or failed pipe (set after conda activate, as the conda scripts are not -u safe)
set -euo pipefail

FASTQ_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/sequence_data
INDEX_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/index
GTF=/scratchdata1/groups/phoenix-hpc-sacgf/reference/hg38/General/Annotations/gencode.v39.annotation.gtf
TEST_DIR=/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/umi_test

mkdir -p "$TEST_DIR"

for SAMPLE in 26-03807_S1_L03 26-03810_S4_L03; do

    OUT="$TEST_DIR/$SAMPLE"
    mkdir -p "$OUT"

    echo "===== $SAMPLE"

    # 1M read pairs (4M lines per file)
    set +o pipefail   # head closes the pipe early; zcat's SIGPIPE is expected here
    zcat "$FASTQ_DIR/${SAMPLE}_R1_001.fastq.gz" | head -n 4000000 | gzip > "$OUT/sub_R1.fastq.gz"
    zcat "$FASTQ_DIR/${SAMPLE}_R2_001.fastq.gz" | head -n 4000000 | gzip > "$OUT/sub_R2.fastq.gz"
    set -o pipefail

    # UMI extraction (as 03_umi_extract.sh)
    umi_tools extract \
        --extract-method=regex \
        --bc-pattern2='^(?P<discard_1>.)(?P<umi_1>.{10})(?P<discard_2>GCAGGG){s<=1}' \
        --stdin="$OUT/sub_R1.fastq.gz" \
        --read2-in="$OUT/sub_R2.fastq.gz" \
        --stdout="$OUT/R1.umi.fastq.gz" \
        --read2-out="$OUT/R2.umi.fastq.gz" \
        --log="$OUT/umi_extract.log"

    # Trimming (as 04_trim.sh)
    cutadapt \
        -j 8 \
        -u 3 \
        -a AGATCGGAAGAGC -a AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA \
        -A AGATCGGAAGAGC -A AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG \
        -q 20 \
        --minimum-length 30 \
        -o "$OUT/R1.trimmed.fastq.gz" \
        -p "$OUT/R2.trimmed.fastq.gz" \
        "$OUT/R1.umi.fastq.gz" "$OUT/R2.umi.fastq.gz" > "$OUT/cutadapt.log"

    # Alignment (as 05_star_align_umi.sh)
    STAR --runMode alignReads \
         --genomeDir "$INDEX_DIR" \
         --readFilesIn "$OUT/R1.trimmed.fastq.gz" "$OUT/R2.trimmed.fastq.gz" \
         --readFilesCommand zcat \
         --outSAMtype BAM SortedByCoordinate \
         --outSAMattributes NH HI AS NM MD \
         --quantMode GeneCounts \
         --sjdbGTFfile "$GTF" \
         --outFileNamePrefix "$OUT/" \
         --runThreadN 8
    samtools index -@ 8 "$OUT/Aligned.sortedByCoord.out.bam"

    # Deduplication (as 06_umi_dedup.sh)
    umi_tools dedup \
        --stdin="$OUT/Aligned.sortedByCoord.out.bam" \
        --stdout="$OUT/dedup.bam" \
        --paired \
        --multimapping-detection-method=NH \
        --log="$OUT/dedup.log"
    samtools index "$OUT/dedup.bam"

    # Counting (as 07_featurecounts.sh)
    featureCounts -T 8 -p --countReadPairs -s 2 -a "$GTF" -o "$OUT/featurecounts.txt" "$OUT/dedup.bam"

done

# ---------- Summary ----------
set +e +o pipefail   # always print the full summary, even if a grep finds no match or head closes a pipe

for SAMPLE in 26-03807_S1_L03 26-03810_S4_L03; do

    OUT="$TEST_DIR/$SAMPLE"
    echo ""
    echo "################ $SAMPLE"

    echo "--- umi_tools extract"
    grep -E "Input Reads|regex does not match|Reads output" "$OUT/umi_extract.log"

    echo "--- First 3 R2 reads after extraction (linker should be gone, UMI in read name)"
    zcat "$OUT/R2.umi.fastq.gz" | head -n 12 | awk 'NR % 4 == 1 || NR % 4 == 2'

    echo "--- cutadapt"
    grep -E "Total read pairs processed|Read 1 with adapter|Read 2 with adapter|Pairs written" "$OUT/cutadapt.log"

    echo "--- STAR"
    grep -E "Number of input reads|Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads unmapped: too short" "$OUT/Log.final.out"

    echo "--- Strandedness (gene-assigned reads, col2 unstranded / col3 forward / col4 reverse; fracForward should be ~0.05-0.07)"
    awk 'NR > 4 {c2 += $2; c3 += $3; c4 += $4} END {printf "col2 %d  col3 %d  col4 %d  fracForward %.4f\n", c2, c3, c4, c3 / (c3 + c4)}' "$OUT/ReadsPerGene.out.tab"

    echo "--- umi_tools dedup"
    grep -E "Input Reads|Number of reads out|Mean number of unique UMIs per position" "$OUT/dedup.log"

    echo "--- featureCounts"
    cat "$OUT/featurecounts.txt.summary"

done
