#!/bin/bash
# Created by Victoria Fuller
# Date: 14/06/2025

# Script Name:
# 5_optional_filter_genes_sv.sh
# Description: Filters to keep variants in or near to CDH1 CTNNA1 or genes physically interacting with them

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.manta.diploid_sv_VEP.ann.vcf.gz, sample252.manta.diploid_sv_VEP.ann.vcf.gz, 
# sample301.manta.diploid_sv_VEP.ann.vcf.gz, sample302.manta.diploid_sv_VEP.ann.vcf.gz, sample303.manta.diploid_sv_VEP.ann.vcf.gz
# Run: bash 5_optional_filter_genes_sv.sh <vcf file path> 

set -euo pipefail

# Define the current step for file names
previous_step="split_vep"
current_step="filter_genes"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input file as argument or use default
vcf_input_file="${1}"

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Extract base name for output file name
input_basename=$(basename "${vcf_input_file}" .vcf.gz)
vcf_output_file="${data_output_dir}/${input_basename}_${current_step}.vcf.gz"

# Check the input file exists
if [[ ! -f "${vcf_input_file}" ]]; then
  echo "ERROR: Input VCF file not found at ${vcf_input_file}"
  exit 1
fi

# Log tool version
echo "Using bcftools version:"
bcftools --version

# Run filtering command
# Filter to keep all variants in or near to CDH1 or CTNNA1
echo "Filtering for variants in CDH1 or CTNNA1..."
bcftools view "${vcf_input_file}" \
  --include '(INFO/vep_SYMBOL = "CDH1" || INFO/vep_SYMBOL = "CTNNA1" || INFO/vep_SYMBOL = "KLRG1" || INFO/vep_SYMBOL = "EGFR" || INFO/vep_SYMBOL = "JUP" || INFO/vep_SYMBOL = "CTNND1" || INFO/vep_SYMBOL = "CTNNB1" || INFO/vep_SYMBOL = "ITGAE" || INFO/vep_SYMBOL = "IQGAP1" || INFO/vep_SYMBOL = "VCL" || INFO/vep_SYMBOL = "CDH2" || INFO/vep_SYMBOL = "TJP1" || INFO/vep_SYMBOL = "AFDN" || INFO/vep_SYMBOL = "CDH17" || INFO/vep_SYMBOL = "CTNNA2") || (INFO/vep_NEAREST = "CDH1" || INFO/vep_NEAREST = "CTNNA1" || INFO/vep_NEAREST = "KLRG1" || INFO/vep_NEAREST = "EGFR" || INFO/vep_NEAREST = "JUP" || INFO/vep_NEAREST = "CTNND1" || INFO/vep_NEAREST = "CTNNB1" || INFO/vep_NEAREST = "ITGAE" || INFO/vep_NEAREST = "IQGAP1" || INFO/vep_NEAREST = "VCL" || INFO/vep_NEAREST = "CDH2" || INFO/vep_NEAREST = "TJP1" || INFO/vep_NEAREST = "AFDN" || INFO/vep_NEAREST = "CDH17" || INFO/vep_NEAREST = "CTNNA2")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"