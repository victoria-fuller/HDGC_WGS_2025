#!/bin/bash
# Created by Victoria Fuller
# Date: 29/06/2025

# Script Name:
# 7c_filter_high_moderate_impact.sh
# Description: Filters to remove variants that are not high or moderate impact
# Keeps HIGH impact variants or MODERATE impact variants with SIFT < 0.05, PolyPhen > 0.908

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session
# Mount joint_germline_recalibrated_VEP.ann.vcf.gz annotated vcf into session data
# Run: bash 7c_filter_high_moderate_impact.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="filter_genes"
current_step="filter_high_moderate_impact"

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
# Filter to keep moderate and high impact variants with deleterious computational predictor scores
echo "Filtering for high and moderate impact variants..."
bcftools view "${vcf_input_file}" \
  --include '(INFO/vep_IMPACT = "HIGH") || (INFO/vep_IMPACT = "MODERATE" && INFO/vep_SIFT ~ "deleterious" && INFO/vep_PolyPhen ~ "damaging")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"