#!/bin/bash
# Created by Victoria Fuller
# Date: 29/06/2025

# Script Name:
# 8d_optional_filter_tfbs.sh
# Description: Filters to keep variants affecting transcription factor binding sites
# Keeps MODIFIER variants affecting transcription factor binding sites

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session
# Mount joint_germline_recalibrated_VEP.ann.vcf.gz annotated vcf into session data
# Run: bash 8d_optional_filter_tfbs.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="filter_modifier"
current_step="filter_tfbs"

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
# Filter to keep regulatory regions and transcription factor binding sites
echo "Filtering for modifier variants..."
bcftools view "${vcf_input_file}" \
  --include '(INFO/vep_Consequence = "TFBS_ablation" || INFO/vep_Consequence = "TFBS_amplification" || INFO/vep_Consequence = "TF_binding_site_variant" || INFO/vep_Consequence = "regulatory_region_ablation" || INFO/vep_Consequence = "regulatory_region_amplification" || INFO/vep_Consequence = "regulatory_region_variant")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"