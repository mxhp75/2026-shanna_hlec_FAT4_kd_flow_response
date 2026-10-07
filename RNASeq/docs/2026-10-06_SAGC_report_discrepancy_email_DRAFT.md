# DRAFT: email to SAGC re NGS Quality Report SAGCQR2280

**Status:** Draft, not sent. To be discussed with the CI before sending.
**Drafted:** 2026-10-06

---

**To:** Ayla Orang <ayla.orang@sahmri.com>
**Cc:** Kelly Betterman
**Subject:** SAGCQA2280: quality report discrepancy (clusters passing filter)

Dear Ayla,

Thank you for the sequencing data for project SAGCQA2280 (quality report dated 16 September 2026). While running QC, we found that the "Total Clusters Passing Filter (Million)" column in the PDF report doesn't match the data we received.

The FASTQ files themselves are fine. The md5 checksums passed, and the read counts in the files match the MultiQC report you supplied exactly: mgikit "M Total Clusters", FastQC "Total Sequences", and our own FastQC and STAR runs. Only the PDF table differs:

| ULN      | Sample        | PDF report (M) | SAGC MultiQC / FASTQ (M) |
|----------|---------------|----------------|--------------------------|
| 26-03807 | CS16          | 29.6           | 35.45                    |
| 26-03808 | FS16          | 32.8           | 44.13                    |
| 26-03809 | CL16          | 37.2           | 30.06                    |
| 26-03810 | FL16          | 35.7           | 28.67                    |
| 26-03811 | CS17          | 35.0           | 35.00                    |
| 26-03812 | FS17          | 32.7           | 33.15                    |
| 26-03813 | CL17          | 29.7           | 36.71                    |
| 26-03814 | FL17          | 37.1           | 34.84                    |
| 26-03815 | CS18          | 44.9           | 44.30                    |
| 26-03816 | FS18          | 29.4           | 43.63                    |
| 26-03817 | CL18          | 18.2           | 47.38                    |
| 26-03818 | FL18          | 33.0           | 42.54                    |
| 26-03819 | SAGC_negative | 31.7           | 0.003 (2,690 reads)      |
|          | Undetermined  | —              | 65.55                    |
|          | **Total**     | **427**        | **~521**                 |

Could you please:

1. Confirm that the MultiQC / FASTQ values are correct, and issue a corrected quality report, since we'd like to cite accurate numbers in our methods.
2. Confirm that the other per-sample values in the PDF table (library concentration, index sequences and average fragment size) are correct, and that the ULN → sample name mapping is correct. The mapping does match the sample renaming in the MultiQC report.

Many thanks,
Melanie Smith
Adelaide University
melanie.smith@adelaide.edu.au

---

## Supporting evidence (internal, not for the email)

- **PDF report:** `RNASeq/raw_data/SAGCQR2280_KellyBetterman_18092026_NGSQualityReport.pdf`
- **SAGC MultiQC (v1.21):** `RNASeq/raw_data/qc/sagcQC/multiqc_report.html`. The General Statistics table has mgikit "M Total Clusters" and FastQC "Seqs", and the `mqc_config` `sample_names_rename` block has the ULN → sample name mapping.
- **Own FastQC/MultiQC:** `RNASeq/raw_data/qc/myQC/multiqc/multiqc_data/multiqc_fastqc.txt`, "Total Sequences".
- **STAR:** `RNASeq/raw_data/star_align/<ULN>/Log.final.out`, "Number of input reads".
- **Raw FASTQ line counts (HPC, S1–S3):** identical to the above, with R1 = R2.
- **md5 checksums:** all passed after download.
