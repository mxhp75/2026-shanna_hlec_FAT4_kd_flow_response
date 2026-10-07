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
- **Library prep:** stranded mRNA, QIAseq FastSelect protocol, 20 amplification cycles
- **Run:** 1 lane, 13 libraries (12 samples + SAGC negative control); ~521M clusters total (456M assigned to the 12 samples, 65.6M undetermined) per SAGC MultiQC; sequenced 10/09/2026
- **Counts:** built in R from STAR `RNASeq/raw_data/star_align/<ULN>/ReadsPerGene.out.tab` using column 4 (reverse-stranded; forward fraction ≈ 0.05). `GeneID` = versioned Ensembl IDs (GENCODE). `count_matrix.txt` was built with a `paste` bug that scrambled counts — do not use
- **Annotation:** GENCODE v39 (GRCh38) — `RNASeq/genomeFiles/gencode.v39.annotation.gtf`; gene IDs match the STAR counts exactly (61,533 genes)
- **Negative control:** `26-03819_S13_L03` (`SAGC_negative`, <0.1 ng/uL library, 2,690 read pairs) — dropped from analysis
- **SAGC PDF report error:** the "Total Clusters Passing Filter" column in SAGCQR2280 does not match SAGC's own MultiQC/demultiplexing or the FASTQs (e.g. CL18 reported 18.2M, actual 47.4M). Use the MultiQC values (`RNASeq/raw_data/qc/sagcQC/multiqc_report.html`). ULN → sample mapping is confirmed by SAGC MultiQC.
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
- **Not yet corrected.** Preferred approach: per-gene exonic GC content from the GRCh38 genome FASTA + GENCODE v39 GTF, then cqn offsets in edgeR. Alternatives: GC covariate in the design, or RUVSeq/svaseq

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
- **R2:** `N` (pos 1, no-call) + **10 nt random (UMI-like)** (pos 2–11) + fixed **`GCA`** (pos 12–14) + **`GGG`** (pos 15–17, template-switching signature) + insert from pos ~18. A minority of reads show a 1-base shift or lack the linker
- UMI evidence: 529,407 distinct pos 2–11 10-mers in 1M R2 reads (S1), most frequent seen 32 times — near-random, not transcript-derived. R2 deduplicated % (21–35%) is also much higher than R1 (5–11%)
- **R1:** `TTT` (pos 1–3, ~70–78% T, short fixed sequence — not oligo-dT) + insert; identical across samples. **Confirmed no UMI in R1:** pos 4–13 10-mers in 1M R1 reads (S1) — 280,936 distinct, most frequent seen 3,835× (vs 529,407 distinct / max 32× for R2 pos 2–11); top R1 sequences match the FastQC overrepresented sequences (abundant transcripts)
- Base composition from FastQC is binned in pairs after base 9; exact positions were confirmed from raw R2 reads
- **Current counts (STAR `ReadsPerGene`, column 4) are NOT UMI-deduplicated and the R2 linker/UMI was not trimmed** — STAR soft-clipped it (hence normal mapping rates)

**Pending (as of 2026-10-06):**
- Library kit used with QIAseq FastSelect — to be confirmed by Shanna (lab book) or SAGC. The kit manual should define the exact UMI length, linker and R1 leading bases. Do not finalise UMI extraction/trimming parameters until known
- Shanna is checking lab book notes for any processing differences in FLMT16, FSMT17, CLMT17
- Proposed re-processing once the kit is known: `umi_tools extract` (R2 regex: N + 10-nt UMI + `GCAGGG`) → adapter/leading-base trim → STAR (GRCh38 / GENCODE v39) → `umi_tools dedup --paired` → `featureCounts -p -s 2`. Then re-run 01/02 and check whether the GC-bias dim 1 split persists; if so, apply cqn GC correction

---

## Cell Model

- **Cell type:** Human lymphatic endothelial cells (hLECs)
- **Perturbation:** FAT4 knockdown/knockout
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
