# CLAUDE.md — FAT4 KD Flow Response Proteomics Project

## Behaviour Rules — Read Before Acting

- **Always read a file in full before editing it**
- **Do not make changes to any file without first describing what you plan to change and waiting for confirmation**
- When in doubt about intent, ask — do not guess and proceed
- Prefer minimal, targeted edits over rewrites
- Do not add new functionality, parameters, or restructure code unless explicitly asked

---

## Project Overview

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

## Cell Model

- **Cell type:** Human lymphatic endothelial cells (hLECs)
- **Perturbation:** FAT4 knockdown/knockout
- **Mechanobiological stimulus:** Laminar fluid flow vs static culture
- **Readout:** Protein abundance by mass spectrometry
