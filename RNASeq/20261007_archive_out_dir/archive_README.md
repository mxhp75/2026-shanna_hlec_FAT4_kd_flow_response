# Archive: original RNA-seq processing (superseded)

**Project:** hLEC FAT4 knockout × laminar/static flow (SAGC quote SAGCQA2280, MGI DNBSEQ-G400, PE100)
**Original processing:** 2026-09-30 · **Archived:** 2026-10-07 · **Author:** Melanie Smith

This folder holds the scripts and outputs from the first processing of the RNA-seq data. They are kept for the record. **Do not use them for downstream analysis.** They were superseded by the UMI-aware pipeline described below.

## Why the original processing did not handle UMIs

There was no sign at the time that the libraries contained UMIs:

- The SAGC quality report (SAGCQR2280) describes stranded mRNA libraries prepared with QIAseq FastSelect. It does not mention UMIs, and it does not name the library kit.
- SAGC's MultiQC report (sagc/fastqchecks v1.0.5) ran demultiplexing with `--max-umi-len 0` and reported no UMI information.

The data were therefore processed as a standard stranded paired-end library.

## Original steps

| Script | Step | Output |
|---|---|---|
| `01_fastqc.sh` | FastQC on raw FASTQs | `fastqc/` |
| `02_multiqc.sh` | MultiQC summary of FastQC | `multiqc/` |
| `03_star_index.sh` | STAR 2.7.11b index: `hg38_no_alt.fasta` + GENCODE v39 GTF | `index/` (**not archived**: still in place and reused) |
| `04_star_align.sh` | STAR alignment of the raw FASTQs, coordinate-sorted BAM, `--quantMode GeneCounts` | `star_align/<sample>/` |

All steps used the `rnaseq` conda environment (fastqc 0.12.1, multiqc 1.27, STAR 2.7.11b, samtools 1.24) on partition `sacgf`.

Gene counts came from column 4 (reverse-stranded) of each `ReadsPerGene.out.tab`.

> **Warning: `count_matrix.txt`, if present, is scrambled. Do not use it.**
> It was built with a separate `paste` command that interleaved the counts of consecutive genes. Counts were later rebuilt correctly in R directly from the `ReadsPerGene.out.tab` files.

## Why we moved to a new pipeline

A closer look at the per-base sequence content in FastQC, then at the raw reads, showed a fixed structure at the start of every read:

- **R2:** a fixed `A` + **10-nt random sequence (UMI)** + `GCAGGG` linker, with the insert starting at about base 18. Positions 2–11 are near-random (529k distinct 10-mers per 1M reads), as expected for a UMI.
- **R1:** a fixed `TTT`, then the insert. R1 has no UMI.

The original alignment soft-clipped this sequence, so mapping rates looked normal. However, the counts were **not UMI-deduplicated**, and the linker was never trimmed.

Separately, three libraries (FLMT16, FSMT17, CLMT17) show a strong GC-content bias. Proper UMI deduplication is the correct processing for this library type, and it also tests whether the bias is PCR-driven.

## New pipeline

The new pipeline uses the `hlec_umi` conda environment. Its scripts and `environment.yml` are in the project repository under `RNASeq/hpc_scripts/`.

1. `01_star_index.sh`: record only. The existing index is reused.
2. `02_umi_test_subset.sh`: tests the full chain on 1M read pairs from two samples.
3. `03_umi_extract.sh`: `umi_tools extract` takes the UMI from R2.
4. `04_trim.sh`: `cutadapt` removes the R1 `TTT`, adapters and low-quality ends.
5. `05_star_align_umi.sh`: STAR, with the same index and settings as before.
6. `06_umi_dedup.sh`: `umi_tools dedup --paired`.
7. `07_featurecounts.sh`: `featureCounts -p --countReadPairs -s 2`, run on the deduplicated BAMs.
8. `08_fastqc_multiqc_umi.sh`: QC across all steps.

**Still pending (as of 2026-10-07):** confirmation of the library kit used with QIAseq FastSelect, and its documented read structure.
