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
- **Run:** 1 lane, 13 libraries (12 samples + SAGC negative control), 427M PF reads total; sequenced 10/09/2026
- **Counts:** built in R from STAR `RNASeq/raw_data/star_align/<ULN>/ReadsPerGene.out.tab` using column 4 (reverse-stranded; forward fraction ≈ 0.05). `GeneID` = versioned Ensembl IDs (GENCODE). `count_matrix.txt` was built with a `paste` bug that scrambled counts — do not use
- **Negative control:** `26-03819_S13_L03` (`SAGC_negative`, <0.1 ng/uL library, 31.7M clusters PF) — dropped from analysis
- **Low-depth sample:** CL18 / CLMT18 (S11) had 18.2M clusters PF vs ~30–45M for the others
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
