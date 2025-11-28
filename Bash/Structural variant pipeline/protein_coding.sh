#!/bin/bash
# Created by Victoria Fuller
# Date: 30/10/2025

# Script Name:
# protein_coding.sh
# Description: Filters to keep protein coding variants

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated variant vcf files into session data
# Run: bash protein_coding.sh <vcf file> 

set -euo pipefail

# Define the current step for file names
previous_step="deletion"
current_step="protein_coding"

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
# Filter to keep protein coding variants
echo "Filtering for protein coding variants..."
bcftools view "${vcf_input_file}" \
  --include 'INFO/vep_BIOTYPE ~ "protein_coding"' \
  --output "${vcf_output_file}" \
  --output-type z 2>/dev/null

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"