#!/bin/bash
# Created by Victoria Fuller
# Date: 10/06/2025

# Script Name:
# 3_remove_multiallelic.sh
# Description: Removes multiallelic sites to prvent issues with split VEP

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount joint_germline_recalibrated_VEP.ann.vcf.gz annotated vcf into session data
# Run: bash 3_remove_multiallelic.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="pass_filter"
current_step="remove_multiallelic"

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
# Includes variants with PASS in the filter column and without missing (./.) or homozygous reference (0/0) genotypes in the proband
echo "Filtering for biallelic sites..."
bcftools view "${vcf_input_file}" \
  --min-alleles 2 \
  --max-alleles 2 \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"