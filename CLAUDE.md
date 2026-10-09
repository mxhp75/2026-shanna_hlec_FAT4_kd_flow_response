# CLAUDE.md — FAT4 KO Flow Response in hLECs: Proteomics and RNA-seq Project

## Behaviour Rules — Read Before Acting

- **Always read a file in full before editing it**
- **Do not make changes to any file without first describing what you plan to change and waiting for confirmation**
- When in doubt about intent, ask — do not guess and proceed
- Prefer minimal, targeted edits over rewrites
- Do not add new functionality, parameters, or restructure code unless explicitly asked

---

## Project Overview

**Project:** Human lymphatic endothelial cells (hLEC) analysis: FAT4 knock out
**Researcher:** Melanie Smith — melanie.smith@adelaide.edu.au
**PI/Collaborator:** Natasha Harvey
**CI/Collaborator:** Shanna Hosking
**Project directory:** `/home/melanie-smith/workDir/natashaHarvey/2026-shanna_hlec_FAT4_kd_flow_response`

This project analyses hLEC cells exposed to Laminar or Static flow in the context of a FAT4 knockout. We are asking the question "What is the response to flow in the absence of FAT4?" We have protein abundence (mass spec) and matched RNASeq.
Mass spectrometry-based protein abundance profiling of human lymphatic endothelial cells (hLECs) to investigate the role of FAT4 in the cellular response to fluid flow. Cells were cultured under either laminar flow or static media conditions, in a control or FAT4 knockout background, yielding a 2×2 factorial design with three biological replicates per group (n=12 total samples).
RNASeq matched samples. RNA-seq data: paired-end FASTQ files, reverse-stranded library preparation. STAR-generated ReadsPerGene.out.tab files are used for read-count QC.

---

## Project Directory

```
/home/melanie-smith/workDir/natashaHarvey/2026-shanna_hlec_FAT4_kd_flow_response
```

---

## Experimental Design

| Sample ID     | Genotype | Condition |
|---------------|----------|-----------|
| CLMT16_S2     | Control  | Laminar   |
| CLMT17_S2     | Control  | Laminar   |
| CLMT18_S2     | Control  | Laminar   |
| CSMT16_S2     | Control  | Static    |
| CSMT17_S2     | Control  | Static    |
| CSMT18_S2     | Control  | Static    |
| FLMT16_S2     | FAT4 KO  | Laminar   |
| FLMT17_S2     | FAT4 KO  | Laminar   |
| FLMT18_S2     | FAT4 KO  | Laminar   |
| FSMT16_S2     | FAT4 KO  | Static    |
| FSMT17_S2     | FAT4 KO  | Static    |
| FSMT18_S2     | FAT4 KO  | Static    |

**Factors:**
- **Genotype:** Control vs FAT4 KO
- **Condition:** Laminar flow vs Static media
- **Replicates:** 3 biological replicates per group

**Key comparisons of interest:**
- Flow response in control cells: Laminar vs Static (Control)
- Flow response in FAT4 KO cells: Laminar vs Static (FAT4 KO)
- FAT4 effect under static conditions: Control vs FAT4 KO (Static)
- FAT4 effect under flow conditions: Control vs FAT4 KO (Laminar)
- Interaction: does FAT4 loss alter the flow response?

---

## Sequencing chemistry

- 100bp PE sequencing using MGI DNBSEQ-G400 chemistry, run at R1: 100bp, R2: 100bp,
Barcode: 10bp, Dual Barcode: 10bp
- **Provider:** South Australian Genomics Centre (SAGC); quality report `RNASeq/raw_data/SAGCQR2280_KellyBetterman_18092026_NGSQualityReport.pdf` (quote SAGCQA2280)
- **Library prep:** QIAseq FastSelect RNA Library Kit (stranded, rRNA removal with FastSelect, template-switching RT), 20 amplification cycles. Handbook HB-3152-003 (03/2025): `RNASeq/docs/HB-3152-003_HB_QIAseq_FastSelect_RNA_Library_Kit_0325_WW.pdf`. SAGC confirmed by email (2026-10-08) that UMIs were included
  - **Adapters:** Illumina-style adapters with 10-bp UDIs (QIAseq UX Index Kit IL UDI); SAGC converted the pooled libraries to MGI-compatible (report comment 3; conversion kit not named). In the cutadapt logs of the UMI run, 3' read-through matches only the Illumina adapter core `AGATCGGAAGAGC` (S1: ~188k R1 / ~175k R2 matches ≥13 nt) — the MGI R1/R2 adapters gave only chance ≤5-nt matches (≤80 matches ≥13 nt), because read-through stops at the Illumina adapter. Read-through is <1% of reads (long fragments). MGI adapters removed from `04_trim.sh` for future runs; their inclusion in the 2026-10-07 run had negligible effect
  - 20 cycles is the handbook's setting for **100 ng total RNA input** (Table 12: 1 ng = 27, 10 ng = 23, 100 ng = 20, 1 µg = 17 cycles). Handbook recommends RIN ≥ 8 and DV200 ≥ 35%, and ~15–20M reads per sample at 100 ng input (Table 3)
- **Run:** 1 lane, 13 libraries (12 samples + SAGC negative control); ~521M clusters total (456M assigned to the 12 samples, 65.6M undetermined) per SAGC MultiQC; sequenced 10/09/2026
- **Counts (current, from 2026-10-08):** UMI-deduplicated featureCounts matrix `RNASeq/raw_data/umi_processing/featurecounts/featurecounts_dedup.txt` (`-p --countReadPairs -s 2`; fragments). `GeneID` = versioned Ensembl IDs (GENCODE). Produced by the UMI pipeline in `RNASeq/hpc_scripts/scripts/`; per-step logs and MultiQC in `RNASeq/raw_data/umi_processing/`
- **Counts (superseded):** STAR `ReadsPerGene.out.tab` column 4 from the original alignment of untrimmed reads, not UMI-deduplicated — archived in `RNASeq/20261007_archive_out_dir/star_align/`. `count_matrix.txt` was built with a `paste` bug that scrambled counts — do not use
- **Annotation:** GENCODE v39 (GRCh38) — `RNASeq/genomeFiles/gencode.v39.annotation.gtf`; gene IDs match the STAR counts exactly (61,533 genes)
- **Negative control:** `26-03819_S13_L03` (`SAGC_negative`, <0.1 ng/uL library, 2,690 read pairs) — dropped from analysis
- **SAGC PDF report error:** the "Total Clusters Passing Filter" column in SAGCQR2280 does not match SAGC's own MultiQC/demultiplexing or the FASTQs (e.g. CL18 reported 18.2M, actual 47.4M). Use the MultiQC values (`RNASeq/raw_data/qc/sagcQC/multiqc_report.html`). ULN → sample mapping is confirmed by SAGC MultiQC. Correction requested from SAGC by email, 2026-10-08. SAGC replied (2026-10-08) that an error occurred compiling the read data and sent an "updated report, with all read counts verified against the FASTQ files. All other details are correct." However, the saved file `RNASeq/raw_data/SAGCQR2280_CORRECTION_KellyBetterman_18092026_NGSQualityReport.pdf` is byte-identical to the original (MD5 `104e28a286dd591c3ab76e7f7cdfeca2`; same values, e.g. CL18 18.2M, total 427M) — the old report was attached or saved by mistake. Pending: check the email attachment / request the corrected file. SAGC's statement means the other report columns (library conc., index, fragment size) can be treated as correct
- **ULN → sample ID mapping** (report short name in brackets):

| ULN              | Sample ID     | ULN              | Sample ID     |
|------------------|---------------|------------------|---------------|
| 26-03807_S1_L03  | CSMT16 (CS16) | 26-03813_S7_L03  | CLMT17 (CL17) |
| 26-03808_S2_L03  | FSMT16 (FS16) | 26-03814_S8_L03  | FLMT17 (FL17) |
| 26-03809_S3_L03  | CLMT16 (CL16) | 26-03815_S9_L03  | CSMT18 (CS18) |
| 26-03810_S4_L03  | FLMT16 (FL16) | 26-03816_S10_L03 | FSMT18 (FS18) |
| 26-03811_S5_L03  | CSMT17 (CS17) | 26-03817_S11_L03 | CLMT18 (CL18) |
| 26-03812_S6_L03  | FSMT17 (FS17) | 26-03818_S12_L03 | FLMT18 (FL18) |

- **Acknowledgement (required in publications):** "The authors acknowledge the South Australian Genomics Centre which provided {list services provided}. The SAGC is supported by the National Collaborative Research Infrastructure Strategy (NCRIS) via BioPlatforms Australia and by the SAGC partner institutes."

---

## RNA-seq QC findings

**GC-content bias in three libraries: FLMT16 (S4), FSMT17 (S6), CLMT17 (S7)** — identified 2026-10-06 in `02_filter_normalise_MDS.Rmd`

- These three samples separate from the other nine on MDS dim 1 (~42% of variance), before and after filtering/TMM. The split cuts across genotype, condition and replicate, so it is technical, not biological
- Dim 1 correlates with read GC% (R2 r = 0.98, R1 r = 0.93), histone-gene read fraction (r = 0.98), forward-strand fraction (r = 0.93), and negatively with R1 duplication (r = −0.89) and mitochondrial fraction (r = −0.69). Not related to library size
- Gene-level signature: genes higher in the three are on GC-rich chromosomes (chr22, 19, 16, 17, 20); genes lower are on AT-rich chromosomes (chr13, 4, 18, 5) and chrM. ~1,450 genes have r > 0.9 and ~360 have r < −0.9 with dim 1 (of 15,710 retained) — genome-wide effect
- Ruled out: proliferation (MKI67, TOP2A, CDK1, CCNA2 do not track dim 1), residual rRNA (the three have the *lowest* rRNA fraction), sample label swaps (marker genes are consistent with labels)
- Likely source: library prep (PCR amplification, 20 cycles, or fragmentation). Not yet confirmed with the lab/SAGC whether S4, S6, S7 were processed differently
- Partially confounded with design: one sample each from Control_Laminar, FAT4 KO_Laminar, FAT4 KO_Static; none from Control_Static
- **Not yet corrected; persists after UMI deduplication.** Agreed approach (2026-10-08): per-gene exonic GC content and length from `BSgenome.Hsapiens.UCSC.hg38` (same UCSC hg38 assembly as the STAR index FASTA `hg38_no_alt.fasta`; matching chromosome names) + GENCODE v39 GTF, then cqn offsets in edgeR, plus sample quality weights for the depth/complexity differences. Alternatives considered: GC covariate or trio indicator in the design (assumes a uniform effect across genes), RUVSeq/svaseq

**Interpretation cautions while uncorrected:**
- Per-sample values for GC-rich genes are inflated, and AT-rich genes deflated, in the three samples. Check gene GC/chromosome before interpreting any gene-level pattern that is driven by these samples
- KLF2 (chr19, GC-rich) is highest within its group in all three samples (CLMT17, FSMT17, FLMT16) — likely partly GC bias
- FAT4 (chr4, AT-rich) is lowest or near-lowest within its group in all three — the KO reduction may be slightly overstated in those samples, but Control vs KO still separates without them
- Endothelial genes FLT4, CDH5, NOS3 correlate strongly with dim 1 (r 0.92–0.99), probably via GC content

**Marker genes confirm labels:** FAT4 is ~1–1.5 log2 lower in all KO vs all Control samples (partial reduction, knockdown-like); KLF4 separates all Laminar from all Static.

**Other individual-sample variation:** CLMT16 and FLMT17 (MDS dims 2 and 4) and CSMT17 (dim 3; also very low KLF2).

**Read-level evidence for the GC bias (FastQC, `RNASeq/raw_data/qc/myQC/fastqc/`):**
- The three samples have a broad high-GC shoulder in per-read GC content: 20–24% of R2 reads (12–15% of R1) are ≥60% GC vs ≤1.7% in the other nine; GC SD ~10 vs 6–7. Modal GC is normal — it is an extra population, not a shift
- Not contamination: smooth shoulder rather than a discrete peak, and mapping (95–96% unique), Kraken (~86% human), unassigned and multimapping rates are all normal for these samples
- The bias is present in the FASTQ before alignment, so it originates in the libraries, not in STAR/counting
- The three have *lower* duplication than the others (R1 88.7–89.9% vs 90.6–94.8%), so the extra high-GC reads are probably not simply PCR duplicates

**Read structure (confirmed from FASTQ, 2026-10-06; same in all 12 samples):**
- **R2:** fixed **`A`** (pos 1; full-file count in CS16: A 35,286,356 / N 83,076 / C 17,695 / T 34,223 / G 33,040 of 35,454,390 reads = 99.8% A of called bases; FastQC: N 0.21–0.23% at pos 1 in all 12 libraries. An earlier note recorded `N` here because the first reads in each FASTQ start with `N`) + **10 nt random (UMI-like)** (pos 2–11) + fixed **`GCA`** (pos 12–14) + **`GGG`** (pos 15–17, template-switching signature) + insert from pos ~18. A minority of reads show a 1-base shift or lack the linker
- **Handbook vs data:** handbook Figure 2 shows the template-switching oligo as `[adapter]–[10 bp]–GCAGGG`, confirming the linker and layout. The handbook labels the 10 bp a fixed per-well "sample ID" and never mentions UMIs, but the data show it is random per molecule, with no fixed per-sample sequence anywhere in R2; together with SAGC's confirmation that UMIs were included, it is treated as the UMI. Samples are demultiplexed by the UDI index reads. The R1 leading `TTT` is not documented in the handbook
- UMI evidence: 529,407 distinct pos 2–11 10-mers in 1M R2 reads (S1), most frequent seen 32 times — near-random, not transcript-derived. R2 deduplicated % (21–35%) is also much higher than R1 (5–11%)
- **R1:** `TTT` (pos 1–3, ~70–78% T, short fixed sequence — not oligo-dT) + insert; identical across samples. **Confirmed no UMI in R1:** pos 4–13 10-mers in 1M R1 reads (S1) — 280,936 distinct, most frequent seen 3,835× (vs 529,407 distinct / max 32× for R2 pos 2–11); top R1 sequences match the FastQC overrepresented sequences (abundant transcripts)
- Base composition from FastQC is binned in pairs after base 9; exact positions were confirmed from raw R2 reads
- **Original counts (STAR `ReadsPerGene`, column 4, untrimmed reads) were NOT UMI-deduplicated** — STAR soft-clipped the R2 linker/UMI (hence normal mapping rates). Superseded 2026-10-08 by the UMI-deduplicated counts below

**Pending (as of 2026-10-09):**
- Shanna is checking lab book notes for any processing differences in FLMT16, FSMT17, CLMT17
- From Kelly Betterman (wetlab; extraction and dilutions): A260/A230 ratios (from NanoDrop screenshots); whether the 50 ng/µl stocks sent to SAGC were made in TE (standard 1 mM or low 0.1 mM EDTA) or water; DNase treatment; extraction method. Kelly is also running her own analysis of the GC bias
- From SAGC: TapeStation/RIN/DV200 traces, Qubit values, and the RNA amount and volume actually used per library
- Per-gene exonic GC content and length: done in `03_gene_GC_length.Rmd` (2026-10-09). **cqn GC correction not started — analysis of this dataset paused (2026-10-09):** the data are too poor quality to work with (very low complexity, GC bias in three libraries); expect new libraries and new sequencing, and to re-run the analysis from scratch. Restart plan (2026-10-09): not yet known whether new libraries will use the same RNA or new extractions; archive all current outputs before starting again; script updates (ULN mapping, hand-typed `qcMetrics` and `gcBiasSamples` in 02, resume logic, `03_umi_extract.sh` comment) deferred until new sequencing is confirmed; proteomics unaffected

**RNA extraction QC from the wetlab (received 2026-10-09; hLEC B4 P4; NanoDrop):**

| Experiment | Sample | Treatment | Well | NanoDrop (ng/µl) | A260/A280 | Concentration (ng/µl) |
|---|---|---|---|---:|---:|---:|
| T16 | CS16 | EGFP esiRNA static | A1 | 88.9 | 2.06 | 177.8 |
| T16 | FS16 | FAT4 esiRNA static | B1 | 68.7 | 2.05 | 137.4 |
| T16 | CL16 | EGFP esiRNA LSS | C1 | 60.4 | 2.03 | 120.8 |
| T16 | FL16 | FAT4 esiRNA LSS | D1 | 69.0 | 2.08 | 138.0 |
| T17 | CS17 | EGFP esiRNA static | E1 | 82.6 | 2.04 | 165.2 |
| T17 | FS17 | FAT4 esiRNA static | F1 | 68.2 | 2.02 | 136.4 |
| T17 | CL17 | EGFP esiRNA LSS | G1 | 96.2 | 2.04 | 192.4 |
| T17 | FL17 | FAT4 esiRNA LSS | H1 | 82.8 | 2.03 | 165.6 |
| T18 | CS18 | EGFP esiRNA static | A2 | 89.3 | 2.05 | 178.6 |
| T18 | FS18 | FAT4 esiRNA static | B2 | 99.4 | 2.04 | 198.8 |
| T18 | CL18 | EGFP esiRNA LSS | C2 | 118.4 | 2.06 | 236.8 |
| T18 | FL18 | FAT4 esiRNA LSS | D2 | 94.4 | 2.04 | 188.8 |

- "Concentration" = stock concentration: Kelly confirmed (2026-10-09) that samples were diluted 1:2 in TE buffer before the NanoDrop. Each sample was then diluted to 50 ng/µl and split into 10 µl for SAGC QC (500 ng) and 30 µl for library prep (1.5 µg), plus 5 µl spare (45 µl total) — so RNA amount supplied was not limiting (handbook range 1 ng–1 µg). Inputs were equalised from NanoDrop, so any sample-specific NanoDrop overestimate (gDNA, contaminants) would mean less RNA than intended — SAGC's Qubit values would show this
- **TE/EDTA:** standard TE contains 1 mM EDTA, which chelates Mg²⁺. The kit fragments RNA with heat in a Mg²⁺-containing buffer, and the handbook (p. 35) states "The presence of Mg2+, EDTA, EGTA, other salts, and divalent ion chelators in the RNA sample will affect fragmentation times" (times assume RNA in Buffer EB or water); RT and PCR also need Mg²⁺. EDTA carry-over could reduce fragmentation (longer fragments) and cDNA yield (lower complexity). Uniform dilution means a uniform dose if SAGC used equal volumes, so it would explain a run-wide effect rather than the sample differences. Not yet known whether the 50 ng/µl stocks were in TE or water. For new libraries: RNA in nuclease-free water or Buffer EB LSS = laminar shear stress. T16/T17/T18 = the three experiments (replicates); well = position on the plate sent to SAGC
- All samples are pure by A260/A280 (2.02–2.08) and well above the amount needed for a 100 ng input. No A260/A230 or RIN in this sheet
- **No relationship with library complexity:** Spearman rho ≈ 0.06 between concentration and dedup % kept; e.g. CSMT17 (165.2 ng/µl) is the least complex library (2.6% kept)
- **No relationship with the GC-bias trio:** FL16, FS17, CL17 have unremarkable concentrations (136–192), span T16 and T17, and are not adjacent on the plate (D1, F1, G1; CS17 at E1 between them)
- So the RNA as supplied does not explain the low complexity or the GC bias; RNA integrity (TapeStation) and SAGC's input/library steps remain the open questions

**UMI re-processing results (completed 2026-10-08; HPC jobs 16285263–16285268, all COMPLETED):**
- Pipeline: `umi_tools extract` (R2: any base at pos 1 (fixed `A`) + 10-nt UMI + `GCAGGG`, 1 mismatch) → `cutadapt` (R1 `-u 3`, Illumina + MGI adapters, `-q 20`, min length 30) → STAR 2.7.11b (original index/settings) → `umi_tools dedup --paired` (NH multimapping detection) → `featureCounts -p --countReadPairs -s 2`
- Extraction 97.0–97.3% pass; cutadapt keeps ~97% of pairs; STAR 94.8–96.7% uniquely mapped; strandedness unchanged (reverse)
- **Libraries are extremely duplicated (low complexity): only 2.6–14.5% of mapped reads are unique molecules (85–97% PCR duplicates).** Not a dedup artefact: FastQC R1 sequence-level dedup (no UMIs) was also only 5–11%, and mean UMIs per position is ~1.2–1.3 (10-nt UMI not saturated)
- Deduplicated fragments assigned to genes per sample (vs ~24–41M before dedup): CSMT16 4.20M (14.5% kept), FSMT16 2.87M (8.0%), CLMT16 **0.84M** (3.4%), FLMT16 3.25M (13.8%), CSMT17 **0.75M** (2.6%), FSMT17 3.59M (12.7%), CLMT17 4.36M (14.4%), FLMT17 **1.04M** (3.5%), CSMT18 2.37M (6.4%), FSMT18 1.95M (5.3%), CLMT18 2.93M (7.3%), FLMT18 1.97M (5.6%). ~6-fold range; CSMT17, CLMT16 and FLMT17 are very low depth
- **Use the deduplicated counts** for analysis: non-deduplicated counts count PCR copies of the same molecule, inflating evidence and distorting variance
- **Hypothesis tested and ruled out (2026-10-08):** that the GC-bias samples are simply the less over-amplified (more complex) libraries. CSMT16 is equally complex (14.5% kept) but has no GC shoulder (0.3% of R2 reads ≥60% GC) and sits with the other static samples; MDS dim 1 correlates far more with GC (gcHighR2 r = 0.97) than with complexity (dedupKept r = 0.71). The GC signature is library-specific, not a consequence of complexity or PCR duplicates

**Analysis on UMI-deduplicated counts (`02_filter_normalise_MDS.Rmd`, 2026-10-08):**
- 11,491 genes pass `filterByExpr` (vs 15,710 before deduplication; mostly lncRNAs lost, 2,246 → 484). TMM factors 0.92–1.13; deduplicated library sizes 0.75–4.3M
- **12-sample MDS:** dim 1 (61%) = the GC-bias trio. Correlations with dim 1: histone fraction 0.98, gcR2 0.98, gcHighR2 0.97, fracForward 0.96, dupR1 −0.84, dedupKept 0.71, libSize 0.59. The trio still have the lowest rRNA/mitochondrial and highest histone fractions — **GC bias persists after deduplication**
- **9-sample MDS (trio removed):** dim 1 (33%) = **flow** — all five Static (−1.30 to −0.09) separate completely from all four Laminar (+0.22 to +1.32). Genotype does not separate on dims 1–2
- **Dim 2 = depth/quality:** in the 9-sample MDS (26%), the three least complex libraries (CLMT16 3.4%, CSMT17 2.6%, FLMT17 3.5% kept) are the only samples below zero; in the 12-sample MDS dim 2 correlates with libSize (+0.56), rRNA fraction (−0.54) and dedupKept (+0.40). FLMT17 also has the highest rRNA (2.3%) and mitochondrial (11%) fractions
- **Markers (deduplicated counts):** FAT4 Control 7.33–8.10 vs KO 5.46–6.87 log2 CPM (complete separation); KLF4 Static 0.60–2.21 vs Laminar 4.45–6.02 (complete separation). KLF2 is still highest within group in all three GC-bias samples — not a reliable flow marker until GC is corrected
- **Implications for DE:** correct GC with cqn; use sample quality weights to down-weight the low-depth libraries (CLMT16, CSMT17, FLMT17); expect limited power for genotype and interaction effects (n = 3, 0.75–4.3M fragments per sample)
- Likely cause of low complexity: low RNA input and/or over-amplification (20 PCR cycles). The SAGC report's "Conc." column is the final *library* concentration (not RNA); the two lowest-yield libraries (CSMT17 1.8, CLMT16 2.1 ng/µl) are the two least complex, FLMT17 (3.1) next — by eye, not tested; the GC-bias libraries CLMT17 and FLMT16 have low yields but high complexity. SAGC QC'd the RNA by Qubit (report comment 1) but the values are not reported. RNA concentrations supplied to SAGC were high and do not track complexity (see RNA extraction QC above) — if SAGC used a fixed input, the cause is more likely RNA integrity or a library-prep step; awaiting SAGC's TapeStation data and input amounts

**Gene GC content and length (`03_gene_GC_length.Rmd`, 2026-10-09):**
- Per-gene exonic length and GC from the union of GENCODE v39 exons per gene (1,552,754 exon records → 61,533 genes) and `BSgenome.Hsapiens.UCSC.hg38`; GC = fraction of non-N bases. Saved as `out_dir/03_gene_GC_length.rds` (all genes, count-matrix order)
- Lengths match the featureCounts `Length` column exactly for all 61,533 genes. Length median 1,102 bp (8–347,964); GC median 0.466 (0.16–0.93; extremes are short genes)
- GC by chromosome as expected: chr19 (median ~0.57), chr22, chr16, chr17 GC-rich; chr4, chr13, chr18 AT-rich (~0.42)
- **Dim 1 (12-sample MDS) is a GC effect:** gene correlation with dim 1 vs exonic GC, Spearman 0.76 (S-shaped: r ≈ −0.7 below ~0.45 GC, ≈ +0.95 above ~0.55); vs log10 length only −0.14
- **Per-sample GC curves** (log2 CPM relative to the 12-sample gene mean, 10 GC bins): FLMT16, FSMT17, CLMT17 rise steeply to ~+2 log2 in the top GC bin. The other nine slope down at high GC — partly an artefact of centring on a mean that includes the trio — but range from ~0 (CLMT18) to −1.4 (CSMT17) in the top bin; Static samples tend to be more negative than Laminar (CLMT16 is the exception). If revisited: check whether this ordering reflects flow biology before applying cqn, as per-sample GC correction could remove real flow signal (compare 9-sample MDS before/after cqn; re-centre on the nine-sample mean)

---

## Cell Model

- **Cell type:** Human lymphatic endothelial cells (hLECs)
- **Perturbation:** FAT4 knockdown by esiRNA (FAT4 esiRNA vs EGFP esiRNA control), per the wetlab extraction sheet (2026-10-09). Consistent with the partial (~1–1.5 log2) FAT4 reduction in the RNA-seq. "FAT4 KO" labels in this file and the scripts are retained for now
- **Cells:** hLEC batch B4, passage 4
- **Mechanobiological stimulus:** Laminar fluid flow vs static culture
- **Readout:** Protein abundance by mass spectrometry and transcript quantification by RNASeq

---

## RMarkdown Style

All R scripts are RMarkdown (`.Rmd`). Reference example: `Protein/RScripts_protein/01_data_import_and_PCA.Rmd`.

**File naming:**
- Two-digit numeric prefix + snake_case description, e.g. `01_data_import_and_PCA.Rmd`
- Scripts live in `Protein/RScripts_protein/` or `RNASeq/RScripts_rnaseq/`

**YAML header:**
- `title:` matches the file name (without `.Rmd`)
- `author: "Melanie Smith"`
- `date:` in `YYYY-MM-DD` format
- `output: html_document`

**Fixed opening sections, in order:**
1. `setup` chunk (`include=FALSE`) with `knitr::opts_chunk$set(echo = TRUE)`
2. `# Clean-up environment` — `rm(list = ls(all.names = TRUE))`, `gc()`, `options(max.print = .Machine$integer.max, scipen = 999, stringsAsFactors = FALSE, dplyr.summarise.inform = FALSE)`, `set.seed(42)`, each with an inline comment
3. `# Load Libraries` — grouped under comment headers (e.g. `# Core tidyverse`)
4. `# Set paths` — `projectDir` as the absolute project path; input files built with `file.path(projectDir, ...)`

**Body:**
- `#` level headers for each step, with a short prose explanation before the chunk
- Chunks unnamed (except `setup`); plot chunks set `fig.width` / `fig.height`

**Code idioms:**
- camelCase object names (e.g. `rawData`, `sampleMeta`, `log2Mat`)
- tidyverse with `%>%`; namespace `dplyr::select`
- `stopifnot()` for sanity checks
- Sample metadata derived from sample ID letters (C/F = Control/FAT4 KO; L/S = Laminar/Static), with factor levels `Control`, `FAT4 KO` and `Static`, `Laminar`
- Group colour palette: `Control_Static = "#6BAED6"`, `Control_Laminar = "#08519C"`, `FAT4 KO_Static = "#FD8D3C"`, `FAT4 KO_Laminar = "#A63603"`
- `theme_bw()` for ggplot

**Closing section:**
- `# Session information` with `sessionInfo()`

---

## HPC Script Style

Bash/SLURM scripts for the Phoenix HPC (University of Adelaide). Reference examples: `RNASeq/hpc_scripts/scripts/`.

**File naming and location:**
- Two-digit numeric prefix + snake_case description, e.g. `03_umi_extract.sh`; numbered in run order
- Local copies in `RNASeq/hpc_scripts/scripts/`, tracked in git; conda environment files in `RNASeq/hpc_scripts/`
- HPC project scratch: `/scratchdata1/users/a1627211/scratch/2026-shanna_hlec_FAT4_kd_flow_response/`

**SLURM header:**
- `#SBATCH -p sacgf`; `-o`/`-e` to `<project scratch>/slurm_logs/<step>-%j.out/.err` (SLURM does not create this folder — it must exist)
- `--mail-type=all`, `--mail-user=melanie.smith@adelaide.edu.au`, `-N 1`, then `-n`, `--time`, `--mem` sized per step

**Environment:**
- `module load Anaconda3/2025.06-1` → `source "$(conda info --base)/etc/profile.d/conda.sh"` → `conda activate <env>`; all tools from one conda environment
- `set -euo pipefail` immediately **after** `conda activate` (conda scripts are not `-u` safe). Turn `pipefail` off around `zcat | head` pipes, and `-e` off for summary/report sections that grep logs
- Conda environment files list `nodefaults` in `channels:` — the Anaconda3 module's default channels (e.g. `intel`) return 403. For `conda create`, use `--override-channels -c conda-forge -c bioconda`

**Body:**
- Uppercase full-path variables (e.g. `FASTQ_DIR`, `OUT_DIR`); `mkdir -p` output directories
- Loop over samples via `*_R1*.fastq.gz`, derive `SAMPLE` with `basename`, check the R2 file exists, one output per sample
- Write to new output folders; never overwrite raw data or earlier pipeline outputs
- **Resume logic:** inside per-sample loops, skip samples already completed, keyed on an end-of-run marker in that sample's log (e.g. umi_tools extract "Reads output", cutadapt "Pairs written", STAR `Log.final.out` present, umi_tools dedup "Number of reads out"). A sample cut off mid-run has no marker and is re-run. Reason: a NODE_FAIL on 2026-10-07 caused SLURM to requeue `03_umi_extract.sh`, which restarted from the first sample
- Test new pipelines on a small read subset (e.g. 1M pairs from 2 samples) before full runs
- Submit multi-step chains with `sbatch --parsable` and `--dependency=afterok:<jobid>`
