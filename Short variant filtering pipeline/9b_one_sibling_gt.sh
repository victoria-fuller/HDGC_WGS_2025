#!/bin/bash
# Created by Victoria Fuller
# Date: 29/06/2025

# Script Name:
# 9b_one_sibling_gt.sh
# Removes variants with missing genotypes (./.) or homozyogus reference for the proband and one sibling

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount joint_germline_recalibrated_VEP.ann.vcf.gz annotated vcf into session data
# Run: bash 9b_one_sibling_gt.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="filter_high_moderate_impact","filter_modifier","filter_tfbs"
current_step="one_sibling"

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
# Includes variants without missing (./.) or homozygous reference (0/0) genotypes in the proband and one sibling
echo "Filtering for variants that PASS the filter..."
bcftools filter "${vcf_input_file}" \
  --include '(FORMAT/GT[3]!="./." && FORMAT/GT[3]!="0/0") || (FORMAT/GT[4]!="./." && FORMAT/GT[4]!="0/0")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"