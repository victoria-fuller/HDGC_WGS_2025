# HDGC_WGS_2025
Automation and improvement of WGS HDGC MPhil pipeline with versions in Python and Bash to identify SNVs, SVs and CNVs from WGS data.
## Process output from nf-core/sarek
Analysis of whole genome sequencing data from a family with unsolved hereditary diffuse gastric cancer.
Includes filtering pipelines for short variants (shorter than 50 base pairs), structural variants and copy number variants.
## Pipeline description
This repository contains scripts and input files for downstream processing and filtering output from germline WGS analysis using nf-core/sarek.  

## Study Abstract
## Background
Hereditary diffuse gastric cancer exhibits a significant genetic predisposition, with CDH1 identified as the major susceptibility gene. Germline pathogenic variants in CDH1 are found in approximately 40% of HDGC families and guide clinical management. Families without this variant may encounter difficulties making informed clinical decisions regarding surveillance and surgery. This study aimed to suggest new potential candidate genes that may predispose to HDGC in the absence of a pathogenic CDH1 or CTNNA1 variant.
### Methods
DNA was extracted from blood and whole genome sequencing was performed on five individuals in a hereditary diffuse gastric cancer family without a pathogenic CDH1 variant. Single nucleotide variants, insertions and deletions, structural variants and copy number variations were considered, and variants were prioritised according to predicted functional interactions with CDH1 or CTNNA1 to identify genes that could be involved in hereditary diffuse gastric cancer. Analysis also considered high impact variants across the whole genome.
### Findings
Four protein-affecting germline variants were identified in DNA-repair genes in individuals with diffuse gastric cancer that may have an association with hereditary diffuse gastric cancer. Candidate variants included a stop-gain variant in ATR present in all affected individuals, a splice donor variant in NBN present in the proband and both siblings, a frameshift variant in CKAP2 present in all affected individuals and a frameshift variant in TNKS1BP present in the proband and both siblings.
### Interpretation
The results from this study suggest an involvement of DNA damage repair genes in the development of hereditary diffuse gastric cancer in the absence of a pathogenic germline variant identified in CDH1 or CTNNA1, highlighting the need for further studies to investigate the role of these genes in pathogenesis of hereditary diffuse gastric cancer.

# Pipelines
## Python
1. Short variant filtering pipeline  
*Note: short variants were defined as shorter than 50bp*
2. Structural variant filtering pipeline
3. Copy number variant filtering pipeline
## Bash
1. Short variant filtering pipeline
2. Structural variant filtering pipeline
3. Copy number variant filtering pipeline
