#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 6_optional_filter_del.sh
# Description: Filters to keep deletions

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.cnvcall.vcf, sample252.cnvcall.vcf, sample301.cnvcall.vcf, sample302.cnvcall.vcf, sample303.cnvcall.vcf
# Run: bash 6_optional_filter_del.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="filter_genes"
current_step="filter_del"

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
# Filter to keep all deletions
echo "Filtering for deletions..."
bcftools view "${vcf_input_file}" \
  --include 'SVTYPE = "DEL"' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"