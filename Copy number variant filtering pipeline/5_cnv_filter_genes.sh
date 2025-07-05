#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 5_cnv_filter_genes.sh
# Description: Filters to keep variants in CDH1, CTNNA1 or genes physically interacting with them

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.cnvcall.vcf, sample252.cnvcall.vcf, sample301.cnvcall.vcf, sample302.cnvcall.vcf, sample303.cnvcall.vcf
# Run: bash 5_cnv_filter_genes.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="annotate"
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
# Filter to keep all variants in or near to genes of interest
echo "Filtering for variants in CDH1 or CTNNA1..."
bcftools view "${vcf_input_file}" \
  --include '(INFO/GeneName = "CDH1" || INFO/GeneName = "CTNNA1" || INFO/GeneName = "KLRG1" || INFO/GeneName = "EGFR" || INFO/GeneName = "JUP" || INFO/GeneName = "CTNND1" || INFO/GeneName = "CTNNB1" || INFO/GeneName = "ITGAE" || INFO/GeneName = "IQGAP1" || INFO/GeneName = "VCL" || INFO/GeneName = "CDH2" || INFO/GeneName = "TJP1" || INFO/GeneName = "AFDN" || INFO/GeneName = "CDH17" || INFO/GeneName = "CTNNA2")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"