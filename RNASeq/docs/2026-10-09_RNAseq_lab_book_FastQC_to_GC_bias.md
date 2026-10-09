---
title: "Lab book: hLEC FAT4 × flow RNA-seq: read QC to GC-bias analysis"
author: "Melanie Smith"
date: "2026-10-09"
output: html_document
---

**Project:** hLEC FAT4 knockdown × laminar/static flow (matched to proteomics)\
**PI:** Natasha Harvey · **CI:** Shanna Hosking · **Research assistant:** Kelly Betterman\
**Sequencing:** SAGC, quote SAGCQA2280, report SAGCQR2280\
**Project directory:** `/home/melanie-smith/workDir/natashaHarvey/2026-shanna_hlec_FAT4_kd_flow_response`\
**Period covered:** 2026-09-30 to 2026-10-09

## Summary and status

- The libraries contain a 10-nt UMI in R2. The SAGC report and MultiQC gave no sign of this, but the reads showed it, and SAGC confirmed it on 2026-10-08. The data were re-processed with UMI-aware deduplication.
- **The libraries have very low complexity.** Only 2.6–14.5% of mapped reads are unique molecules (85–97% PCR duplicates), which leaves 0.75–4.4M deduplicated fragments assigned to genes per sample.
- **Three libraries (FLMT16, FSMT17, CLMT17) carry a strong GC bias.** It is library-specific, survives deduplication and dominates the first MDS dimension.
- With those three removed, flow (Laminar vs Static) is the main biological axis. Genotype does not separate.
- The RNA supplied to SAGC was pure and plentiful, and its concentration does not explain either problem.
- **Decision (2026-10-09): analysis of this dataset is paused.** The data are too poor in quality to work with. We expect new libraries and new sequencing, after which the analysis will be re-run from scratch. GC correction (cqn) was planned but not started.

## 1. Samples and sequencing

**Design:** 2 × 2 factorial, n = 3 per group (12 samples). FAT4 esiRNA vs EGFP esiRNA (control) × laminar shear stress (LSS) vs static. hLEC batch B4, passage 4. Three experiments, T16, T17 and T18, each contribute one sample per group. In the scripts and figures, the knockdown samples are labelled "FAT4 KO".

**Library prep (SAGC):**
- QIAseq FastSelect RNA Library Kit: stranded, FastSelect rRNA removal, template-switching RT, 20 amplification cycles. Handbook: `RNASeq/docs/HB-3152-003_HB_QIAseq_FastSelect_RNA_Library_Kit_0325_WW.pdf`.
- The handbook's 20-cycle setting corresponds to 100 ng RNA input. The handbook recommends RIN ≥ 8 and DV200 ≥ 35%.
- QIAseq UX IL UDI indexes (10 + 10 bp). SAGC converted the libraries to MGI-compatible format.

**Sequencing:**
- MGI DNBSEQ-G400, PE100, one lane, 13 libraries (12 samples + the SAGC negative control), sequenced 2026-09-10.
- About 521M clusters in total: 456M assigned to the 12 samples and 65.6M undetermined, according to SAGC's MultiQC.

| ULN | Sample | ULN | Sample |
|---|---|---|---|
| 26-03807_S1_L03 | CSMT16 | 26-03813_S7_L03 | CLMT17 |
| 26-03808_S2_L03 | FSMT16 | 26-03814_S8_L03 | FLMT17 |
| 26-03809_S3_L03 | CLMT16 | 26-03815_S9_L03 | CSMT18 |
| 26-03810_S4_L03 | FLMT16 | 26-03816_S10_L03 | FSMT18 |
| 26-03811_S5_L03 | CSMT17 | 26-03817_S11_L03 | CLMT18 |
| 26-03812_S6_L03 | FSMT17 | 26-03818_S12_L03 | FLMT18 |

In sample names, C/F = Control/FAT4, L/S = Laminar/Static, MT16–18 = experiment. The negative control, `26-03819_S13_L03` (2,690 read pairs), was dropped.

**Error in the SAGC report:** the "Total Clusters Passing Filter" column in the PDF does not match SAGC's own MultiQC or the FASTQs. For example, CL18 is reported as 18.2M but actually has 47.4M. We used the MultiQC values (`RNASeq/raw_data/qc/sagcQC/multiqc_report.html`) and reported the error to SAGC on 2026-10-08. SAGC replied that a compilation error had occurred and sent an "updated" report. However, the saved file `RNASeq/raw_data/SAGCQR2280_CORRECTION_KellyBetterman_18092026_NGSQualityReport.pdf` is byte-identical to the original. The genuinely corrected report is still outstanding.

## 2. Raw read QC: FastQC and MultiQC (2026-09-30 to 2026-10-06)

FastQC 0.12.1 and MultiQC 1.27 were run on the raw FASTQs.
- **Outputs:** `RNASeq/20261007_archive_out_dir/myQC/fastqc/` and `RNASeq/20261007_archive_out_dir/myQC/multiqc/multiqc_report.html`.
- **For comparison:** SAGC's own FastQC/MultiQC report (sagc/fastqchecks v1.0.5) is at `RNASeq/raw_data/qc/sagcQC/multiqc_report.html`.

**Findings:**
- **Quality and contamination:** base quality is good throughout. Kraken classification (SAGC) is about 86% human in all libraries.
- **Duplication:** very high in every library. FastQC estimates only 5–11% of R1 sequences are distinct (R1 duplication 88.7–94.8%).
- **Unusual base composition at the 5′ end:** in all 12 libraries, R2 starts with a fixed base followed by a near-random stretch and then a fixed motif. R1 starts with `TTT`. This led to the discovery of the UMI (Section 3).
- **GC content:** FLMT16, FSMT17 and CLMT17 have a broad high-GC shoulder in per-read GC content. In these three, 20–24% of R2 reads (12–15% of R1) have ≥60% GC, against ≤1.7% in the other nine, and the GC SD is about 10 vs 6–7.
  - **An extra population, not a shift:** modal GC is normal.
  - **Not contamination:** the shoulder is smooth rather than a discrete peak, and mapping, Kraken and multimapping rates are normal.
  - **Origin:** the bias is present in the FASTQs before alignment, so it comes from the libraries.

> **[FIGURE 1: insert here]**\
> Source: MultiQC "Per Sequence GC Content" plot (R2), `RNASeq/20261007_archive_out_dir/myQC/multiqc/multiqc_report.html`\
> **Figure 1. Per-read GC content of the raw R2 reads.** FLMT16, FSMT17 and CLMT17 (S4, S6, S7) show a broad shoulder of high-GC reads (≥60% GC in 20–24% of reads) that is absent from the other nine libraries.

> **[FIGURE 2: insert here]**\
> Source: FastQC "Per base sequence content", R2 of CSMT16, `RNASeq/20261007_archive_out_dir/myQC/fastqc/26-03807_S1_L03_R2_001_fastqc.html`\
> **Figure 2. Per-base sequence content of raw R2 reads (CSMT16).** Position 1 is a fixed A, positions 2–11 have near-uniform base composition (the UMI), and positions 12–17 are the fixed linker `GCAGGG`. The insert starts at about base 18. The same pattern is seen in all 12 libraries.

## 3. Read structure and discovery of UMIs (2026-10-06 to 2026-10-08)

**No initial indication of UMIs:**
- The SAGC report describes stranded mRNA libraries prepared with QIAseq FastSelect and does not mention UMIs.
- SAGC's MultiQC demultiplexing was run with `--max-umi-len 0` and reports no UMI information.
- The data were therefore first processed as a standard stranded paired-end library: STAR alignment with `--quantMode GeneCounts`, not deduplicated. Those outputs were archived on 2026-10-07 in `RNASeq/20261007_archive_out_dir/` (see `archive_README.md`) and are not used further.

**Read structure, confirmed from the raw FASTQs (identical in all 12 libraries):**
- **R2:**
  - Position 1 is a fixed `A`: 99.8% of called bases in the full CS16 file (35.29M of 35.45M reads). An early note recorded `N` here because the first reads in each file start with `N`.
  - Positions 2–11 are 10 nt of random sequence: 529,407 distinct 10-mers in 1M reads, with the most frequent seen only 32 times.
  - Positions 12–17 are the fixed linker `GCAGGG`, ending in the template-switching `GGG`.
  - The insert follows.
- **R1:** `TTT` (positions 1–3), then the insert. **R1 has no UMI:** positions 4–13 give 280,936 distinct 10-mers, the most frequent seen 3,835 times, and the top sequences match abundant transcripts.

**Handbook vs data:** Figure 2 of the handbook shows the template-switching oligo as [adapter]–[10 bp]–GCAGGG, which matches the layout. The handbook calls the 10 bp a fixed per-well "sample ID" and does not mention UMIs. In the data, however, the sequence is random per molecule, and no fixed per-sample sequence appears anywhere in R2. Samples are demultiplexed by the UDI index reads, which appear in the FASTQ headers as reverse complements of the indexes in the report.

**Confirmation:** SAGC confirmed by email on 2026-10-08 that UMIs were included. The original counts were therefore not UMI-deduplicated, and the data were re-processed.

**Adapters:** in the cutadapt logs, 3′ read-through matches only the Illumina adapter core `AGATCGGAAGAGC` (S1: about 188k R1 and 175k R2 matches ≥13 nt). The MGI adapters gave only chance matches of ≤5 nt. Read-through affects less than 1% of reads.

## 4. UMI-aware re-processing on Phoenix HPC (2026-10-07 to 2026-10-08)

**Setup:**
- **Scripts:** `RNASeq/hpc_scripts/scripts/`.
- **Conda environment:** `hlec_umi` (`RNASeq/hpc_scripts/environment.yml` and `environment.lock.yml`). Versions: STAR 2.7.11b, samtools 1.24, FastQC 0.12.1, MultiQC 1.27.1, umi_tools 1.1.6, cutadapt 5.2, subread 2.1.1.
- **Reference:** UCSC hg38 (no alt contigs, `hg38_no_alt.fasta`) with GENCODE v39 annotation (61,533 genes). The original STAR index was reused.

| Script | Step | Key settings |
|---|---|---|
| `01_star_index.sh` | STAR index | Record only; not re-run |
| `02_umi_test_subset.sh` | Test of the full chain | 1M read pairs from CSMT16 and FLMT16 (job 16284909) |
| `03_umi_extract.sh` | `umi_tools extract` | R2 regex `^(?P<discard_1>.)(?P<umi_1>.{10})(?P<discard_2>GCAGGG){s<=1}`; UMI moved into both read names; non-matching pairs discarded |
| `04_trim.sh` | `cutadapt` | `-u 3` (R1 `TTT`), 3′ adapters, `-q 20`, `--minimum-length 30`* |
| `05_star_align_umi.sh` | STAR alignment | Original index and settings; coordinate-sorted BAM, `NH HI AS NM MD` tags |
| `06_umi_dedup.sh` | `umi_tools dedup` | `--paired`, directional method, `--multimapping-detection-method=NH` |
| `07_featurecounts.sh` | `featureCounts` | `-p --countReadPairs -s 2` (fragments, reverse-stranded) |
| `08_fastqc_multiqc_umi.sh` | QC | FastQC on trimmed reads; MultiQC across all steps |

\*The 2026-10-07 run trimmed both the Illumina core and the MGI R1/R2 adapters. Because the MGI adapters gave only chance matches (Section 3), they were removed from `04_trim.sh` afterwards. Including them had a negligible effect.

**Runs:**
- Full-run jobs 16285263–16285268 all completed.
- Job 03 hit a NODE_FAIL and was automatically requeued by SLURM. It completed, but restarted from the first sample. Future scripts should skip samples already completed (resume logic).

**Outputs:** copied to `RNASeq/raw_data/umi_processing/`. This contains per-step logs, the MultiQC report (`multiqc_umi/multiqc_report.html`) and the count matrix (`featurecounts/featurecounts_dedup.txt`).

**Results:**
- UMI extraction passed 97.0–97.3% of pairs.
- cutadapt kept about 97% of pairs.
- STAR uniquely mapped 94.8–96.7% of reads.
- Strandedness is reverse: the forward-strand fraction is 0.05–0.07.

| Sample | Input pairs (M) | Mapped reads (M) | Unique after dedup (M) | % kept | Mean UMIs/position | Fragments assigned to genes (M) |
|---|---:|---:|---:|---:|---:|---:|
| CSMT16 | 35.5 | 35.7 | 5.17 | 14.5 | 1.28 | 4.20 |
| FSMT16 | 44.1 | 44.4 | 3.54 | 8.0 | 1.24 | 2.87 |
| CLMT16 | 30.1 | 30.5 | 1.04 | **3.4** | 1.18 | **0.84** |
| FLMT16 | 28.7 | 29.8 | 4.12 | 13.8 | 1.19 | 3.25 |
| CSMT17 | 35.0 | 35.3 | 0.91 | **2.6** | 1.22 | **0.75** |
| FSMT17 | 33.2 | 34.4 | 4.38 | 12.7 | 1.22 | 3.59 |
| CLMT17 | 36.7 | 38.7 | 5.58 | 14.4 | 1.23 | 4.36 |
| FLMT17 | 34.8 | 35.8 | 1.26 | **3.5** | 1.27 | **1.04** |
| CSMT18 | 44.3 | 44.2 | 2.86 | 6.5 | 1.29 | 2.37 |
| FSMT18 | 43.6 | 44.0 | 2.35 | 5.3 | 1.27 | 1.95 |
| CLMT18 | 47.4 | 47.9 | 3.51 | 7.3 | 1.27 | 2.93 |
| FLMT18 | 42.5 | 42.8 | 2.39 | 5.6 | 1.25 | 1.97 |

"Mapped reads" counts individual reads, as reported by umi_tools, and includes multimappers. "% kept" is the proportion of mapped reads that are unique molecules.

**Interpretation:**
- **85–97% of mapped reads are PCR duplicates.** This is a property of the libraries, not an artefact of deduplication:
  - FastQC on R1 (no UMI) independently estimates only 5–11% distinct sequences;
  - the mean number of UMIs per position is about 1.2–1.3, so the 10-nt UMI is not saturated.
- For comparison, the handbook suggests about 15–20M reads per sample at 100 ng input.

> **[FIGURE 3: insert here]**\
> Source: IGV screenshot (not saved in the repository). BAMs: `RNASeq/raw_data/umi_processing/igv/26-03807_S1_L03.predup.bam` and `26-03807_S1_L03.dedup.bam`; hg38, chr12:6,735,962–6,738,843\
> **Figure 3. PCR duplication before and after UMI deduplication (CSMT16).** An intergenic region (no GENCODE v39 gene). Upper track: alignments before deduplication, showing tall stacks of read pairs with identical start and end positions. Lower track: after UMI deduplication, where each stack collapses to a single fragment.

> **[FIGURE 4: insert here]**\
> Source: `RNASeq/out_dir/01_library_sizes_before_after_dedup.png`\
> **Figure 4. Library size and gene detection before and after UMI deduplication.** Deduplication reduces each library from about 24–41M to 0.75–4.4M fragments assigned to genes, a roughly 6-fold range between samples. CSMT17, CLMT16 and FLMT17 are the least complex libraries.

## 5. Import and QC in R (`RNASeq/RScripts_rnaseq/01_data_import_and_QC.Rmd`, 2026-10-08)

**Steps:**
- Imported the deduplicated featureCounts matrix and built a per-sample pipeline QC table from the MultiQC and featureCounts summaries (`RNASeq/out_dir/01_pipeline_QC.csv`).
- Confirmed reverse strandedness from the STAR `ReadsPerGene.out.tab` files of the UMI run (forward fraction ≤ 0.1).
- Dropped the negative control and renamed libraries from ULN to sample ID.
- Built the sample metadata and the gene annotation from the GENCODE v39 GTF.

**Outputs:** `01_count_matrix.rds`, `01_sample_metadata.rds` and `01_gene_annotation.rds` in `RNASeq/out_dir/`.

> **[FIGURE 5: insert here]**\
> Source: `RNASeq/out_dir/01_library_sizes.png`\
> **Figure 5. Deduplicated library sizes.** Fragments assigned to genes per sample after UMI deduplication, coloured by group.

> **[FIGURE 6: insert here]**\
> Source: `RNASeq/out_dir/01_MDS_raw_logCPM.png`\
> **Figure 6. MDS of unfiltered, unnormalised log2 CPM.** An initial overview before filtering and normalisation.

## 6. Filtering, normalisation and MDS (`RNASeq/RScripts_rnaseq/02_filter_normalise_MDS.Rmd`, 2026-10-08)

**Methods:**
- **Filtering and normalisation:** edgeR `filterByExpr` (group-aware, smallest group n = 3) kept 11,491 genes. TMM normalisation (`normLibSizes`) gave factors of 0.92–1.13. MDS used `limma::plotMDS`, with the top 500 genes by leading log2 fold change between each pair of samples.
- **Genes driving dim 1:** ranked by correlation with the dim 1 coordinate.
- **QC correlations:** MDS dims were correlated with QC metrics:
  - read GC% and % of R2 reads ≥60% GC;
  - R1 duplication and forward-strand fraction;
  - % kept after deduplication;
  - rRNA, mitochondrial and histone read fractions;
  - library size.

**Results:**
- **12-sample MDS, dim 1 (61%):** this is the GC-bias trio. Dim 1 correlates with histone fraction (r = 0.98), R2 GC% (0.98) and % high-GC R2 reads (0.97). It correlates more weakly with complexity (% kept, 0.71) and library size (0.59).
  - **Not biological:** the split cuts across genotype, condition and experiment.
  - **Partly confounded with the design:** the trio has one sample each from Control_Laminar, FAT4 KO_Laminar and FAT4 KO_Static, and none from Control_Static.
- **Ruled out as explanations for dim 1:**
  - proliferation;
  - residual rRNA (the trio has the *lowest* rRNA fraction);
  - label swaps;
  - library complexity. CSMT16 is as complex as the trio (14.5% kept) but has no GC shoulder and sits with the other static samples.
- **9-sample MDS (trio removed), dim 1 (33%):** this is flow. All five Static samples separate completely from all four Laminar samples. Genotype does not separate on dims 1–2.
- **Dim 2 (26%):** depth and quality. The three least complex libraries (CLMT16, CSMT17, FLMT17) are the only samples below zero.
- **Marker genes confirm the labels:** FAT4 is lower in all knockdown samples than in all controls (5.46–6.87 vs 7.33–8.10 log2 CPM; a partial reduction, consistent with knockdown). KLF4 separates all Laminar (4.45–6.02) from all Static (0.60–2.21). KLF2 is highest within its group in all three GC-bias samples (KLF2 is on GC-rich chr19), so it is not a reliable flow marker while the GC bias is uncorrected.

> **[FIGURE 7: insert here]**\
> Source: `RNASeq/out_dir/02_density_logCPM_filtering.png`\
> **Figure 7. Distribution of log2 CPM per sample before and after `filterByExpr`.** Filtering removes the peak of low and zero counts.

> **[FIGURE 8: insert here]**\
> Source: `RNASeq/out_dir/02_MDS_TMM_logCPM_dim1-2.png`\
> **Figure 8. MDS of filtered, TMM-normalised log2 CPM, all 12 samples.** Dim 1 (61%) separates FLMT16, FSMT17 and CLMT17 from the other nine, cutting across genotype and condition.

> **[FIGURE 9: insert here]**\
> Source: `RNASeq/out_dir/02_MDS_TMM_logCPM_dim3-4.png`\
> **Figure 9. MDS dims 3 and 4, all 12 samples.** Individual-sample variation (CLMT16, FLMT17, CSMT17).

> **[FIGURE 10: insert here]**\
> Source: `RNASeq/out_dir/02_MDS_TMM_logCPM_noGCtrio_dim1-2.png`\
> **Figure 10. MDS without the three GC-bias libraries (9 samples).** Dim 1 (33%) separates all Static from all Laminar samples. Dim 2 (26%) reflects library depth and complexity, with the three least complex libraries below zero.

> **[FIGURE 11: insert here]**\
> Source: `RNASeq/out_dir/02_MDS_dim1_vs_QC.png`\
> **Figure 11. MDS dim 1 vs per-sample QC metrics (12 samples).** Dim 1 tracks read GC content, the high-GC read fraction and the histone read fraction, and does not track library size.

> **[FIGURE 12: insert here]**\
> Source: `RNASeq/out_dir/02_MDS_dim2_vs_QC.png`\
> **Figure 12. MDS dim 2 vs per-sample QC metrics (12 samples).** Dim 2 is associated with library size, rRNA fraction and library complexity.

> **[FIGURE 13: insert here]**\
> Source: `RNASeq/out_dir/02_marker_genes.png`\
> **Figure 13. Marker genes (log2 CPM, TMM).** FAT4 is reduced in all knockdown samples, and KLF4 is induced in all Laminar samples, confirming the sample labels. KLF2 is inflated in the GC-bias samples.

## 7. Gene GC content and length (`RNASeq/RScripts_rnaseq/03_gene_GC_length.Rmd`, 2026-10-09)

**Aim:** compute the per-gene exonic GC content and length needed for GC correction with cqn, and test whether dim 1 is a GC effect.

**Methods:**
- **Gene model:** exon records from the GENCODE v39 GTF (1,552,754) were merged per gene, using the union of all its transcripts' exons, giving 61,533 genes.
- **GC and length:** sequences were extracted from `BSgenome.Hsapiens.UCSC.hg38`, the same assembly and chromosome names as the STAR index. GC is the fraction of G and C among the called (non-N) bases.
- **Output:** `RNASeq/out_dir/03_gene_GC_length.rds`.

**Results:**
- **Validation:** gene lengths match the featureCounts `Length` column exactly for all 61,533 genes. The median length is 1,102 bp (range 8–347,964), and the median GC is 0.466 (range 0.16–0.93; the extremes are short genes).
- **GC by chromosome is as expected:** chr19, chr22, chr16 and chr17 are GC-rich, and chr4, chr13 and chr18 are AT-rich.
- **Dim 1 is a GC effect:** each gene's correlation with dim 1 rises with exonic GC (Spearman 0.76) in an S-shape, from r ≈ −0.7 below about 0.45 GC to r ≈ +0.95 above about 0.55. Gene length has almost no relationship (Spearman −0.14).
- **Per-sample GC curves:** FLMT16, FSMT17 and CLMT17 rise steeply, to about +2 log2 in the top GC bin.
  - **The other nine slope down at high GC.** This is partly an artefact of centring on a 12-sample mean that includes the trio.
  - **Even so, the nine differ among themselves:** in the top bin they range from about 0 (CLMT18) to −1.4 (CSMT17), and Static samples tend to sit lower than Laminar ones.
  - **Caution:** per-sample GC correction could therefore remove some real flow signal. This would need checking before cqn is applied.

> **[FIGURE 14: insert here]**\
> Source: `RNASeq/out_dir/03_gene_GC_by_chromosome.png`\
> **Figure 14. Exonic GC content of retained genes by chromosome.** chr19, chr22, chr16 and chr17 are GC-rich, and chr4, chr13 and chr18 AT-rich. This matches the chromosomes of the genes that are raised and lowered in the GC-bias samples.

> **[FIGURE 15: insert here]**\
> Source: `RNASeq/out_dir/03_dim1_correlation_vs_GC_length.png`\
> **Figure 15. Gene correlation with MDS dim 1 vs exonic GC content and length.** Each point is a gene; the red line is a loess fit. The correlation with dim 1 rises steeply with GC content (Spearman 0.76) but is almost unrelated to gene length (−0.14).

> **[FIGURE 16: insert here]**\
> Source: `RNASeq/out_dir/03_sample_logCPM_vs_GC.png`\
> **Figure 16. Per-sample expression vs gene GC content.** Median log2 CPM relative to each gene's 12-sample mean, in ten equal-sized bins of exonic GC. Solid lines are the GC-bias libraries, which rise by about 2 log2 at high GC. Dashed lines are the other nine samples.

## 8. RNA and library QC (received 2026-10-09)

**Wetlab RNA extraction QC (NanoDrop):**
- **Purity:** A260/A280 is 2.02–2.08 in all samples.
- **Concentration:** the stock concentration is 120.8–236.8 ng/µl. It is exactly 2× the NanoDrop reading because each sample was diluted 1:2 in TE buffer before measuring (confirmed by Kelly Betterman, 2026-10-09).
- **Plate positions:** A1–H1 and A2–D2, in the order T16, T17, T18.
- **RNA sent to SAGC:** each sample was diluted to 50 ng/µl, then split into 10 µl for SAGC QC (500 ng) and 30 µl for library prep (1.5 µg), with 5 µl spare (45 µl in total). The amount supplied was therefore not limiting: the handbook's input range is 1 ng–1 µg.
- **Inputs were equalised from NanoDrop readings.** If NanoDrop overestimated some samples (gDNA, contaminants), those samples would have had less RNA than intended. SAGC's Qubit values would show this.
- **Pending:** A260/A230 ratios, which Kelly will retrieve from the NanoDrop screenshots.

**Why the TE buffer may matter:**
- Standard TE contains 1 mM EDTA, which binds Mg²⁺.
- The kit fragments RNA with heat in a Mg²⁺-containing buffer. The handbook (p. 35) states: "The presence of Mg2+, EDTA, EGTA, other salts, and divalent ion chelators in the RNA sample will affect fragmentation times". Its times assume RNA in Buffer EB or nuclease-free water.
- Reverse transcription and PCR also need Mg²⁺.
- EDTA carry-over could therefore reduce fragmentation (longer fragments) and cDNA yield (fewer unique molecules, so lower complexity).
- All samples were diluted the same way, so if SAGC used equal volumes the EDTA dose was uniform. TE could explain a run-wide effect, but not the differences between samples or the GC trio.
- Still to confirm: whether the 50 ng/µl stocks were made in TE or water, and whether the TE was standard (1 mM EDTA) or low-EDTA (0.1 mM).

**Comparison with the sequencing problems:**
- **Complexity:** RNA concentration does not track library complexity (Spearman ρ ≈ 0.06). For example, CSMT17 (165.2 ng/µl) is the least complex library.
- **GC bias:** the GC-bias samples have unremarkable concentrations, span T16 and T17, and are not adjacent on the plate (D1, F1, G1).
- **Conclusion:** the amount and purity of the RNA explain neither problem. The TE diluent is a possible run-wide contributor (see above).

**SAGC library QC:**
- The "Conc." column in the SAGC report is the final library concentration, not the RNA concentration.
- The two lowest-yield libraries (CSMT17 1.8 ng/µl, CLMT16 2.1 ng/µl) are the two least complex, with FLMT17 (3.1) next. This was judged by eye and not tested. Low yield after a fixed 20 cycles is consistent with few usable input molecules (low effective input or degraded RNA).
- The GC-bias libraries have the three largest average fragment sizes (461–491 bp).
- SAGC QC'd the RNA by Qubit, but the values are not in the report.

## 9. Correspondence

- **2026-10-08, to SAGC:** reported the error in the PDF read counts. SAGC replied with an "updated" report, but the file received is identical to the original.
- **2026-10-08, from SAGC:** confirmed that UMIs were included.
- **2026-10-08, to SAGC (drafted):** high PCR duplication, read structure (UMI vs "sample ID"), adapter sequences, and library-prep details per sample (input, fragmentation, cycles, TapeStation). Draft: `RNASeq/docs/2026-10-08_SAGC_duplication_read_structure_email_DRAFT.md`.
- **2026-10-09, to Kelly Betterman (wetlab):** sent questions on the ×2 concentration, the amount and volume sent to SAGC, and A260/A230.
- **2026-10-09, from Kelly:** confirmed the 1:2 dilution in TE before the NanoDrop, and the 50 ng/µl stocks (10 µl QC, 30 µl library prep, 5 µl spare). A260/A230 ratios to follow. Kelly is running her own analysis of the GC bias.
- **2026-10-09, to Kelly (drafted):** asked about the diluent for the 50 ng/µl stocks (TE or water; EDTA concentration), DNase treatment and extraction method, and explained why TE matters.

## 10. Outstanding questions and recommendations for the new libraries

**Outstanding:**
- **From SAGC:** TapeStation RIN/DV200, Qubit values, the RNA input used per library, the corrected report, full adapter sequences, and whether the trio was processed differently.
- **From SAGC (additional):** the RNA amount and volume actually used per library.
- **From Kelly Betterman:** A260/A230 ratios; the diluent for the 50 ng/µl stocks; DNase treatment; extraction method; results of her GC-bias analysis.
- **From Shanna Hosking:** lab book notes on any processing differences for FLMT16, FSMT17 and CLMT17.

**Restart plan (2026-10-09):**
- It is not yet known whether the new libraries will use the same RNA or new extractions. Re-using the same RNA would test the GC trio directly: if the bias disappears, it came from library prep; if it persists, it is in the RNA.
- All current outputs will be archived before starting again.
- Script updates will be made once new sequencing is confirmed: the ULN mapping, the hand-typed QC metrics and GC-bias sample list in 02, resume logic in the HPC scripts.
- The proteomics data are unaffected.

**For the new libraries:**
- Confirm the read structure (UMI position and length) and adapter sequences with SAGC before sequencing.
- Request RNA integrity data (RIN/DV200) and the input amount per sample.
- Supply RNA in nuclease-free water or Buffer EB rather than TE, and blank the NanoDrop with the same diluent.
- If possible, quantify by Qubit as well as NanoDrop before equalising inputs.
- Process UMIs from the start: extract and deduplicate as in `RNASeq/hpc_scripts/scripts/`.
- Check per-read GC content and duplication in FastQC at the first QC step.
- Re-use scripts 01–03, which run on the deduplicated featureCounts output.

## Software

- **HPC:** see Section 4. Versions are recorded in `RNASeq/hpc_scripts/environment.lock.yml`.
- **R:** edgeR, limma, tidyverse, rtracklayer, GenomicRanges, Biostrings, BSgenome.Hsapiens.UCSC.hg38. Full versions are in the `sessionInfo()` output of each knitted Rmd.
- **Code:** in the project git repository. The Rmd scripts are in `RNASeq/RScripts_rnaseq/`, and the HPC scripts in `RNASeq/hpc_scripts/scripts/`.
