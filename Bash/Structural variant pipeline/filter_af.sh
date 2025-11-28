#!/bin/bash
# Created by Victoria Fuller
# Date: 20/10/2025

# Script Name:
# filter_af.sh
# Description: Keeps variants that have an allele frequency < 0.01 or missing in gnomAD

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session
# Mount annotated vcf file into session data
# Run: bash filter_af.sh <vcf file>

set -euo pipefail

# Define the current step for file names
previous_step="split_vep"
current_step="filter_af"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input file as argument
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
# Removes any common variants by filtering for allele frequency of < 0.01 in any population in gnomAD
#echo "Filtering for allele frequency..."
#bcftools view "${vcf_input_file}" \
#  --include '(INFO/vep_MAX_AF < 0.01 || INFO/vep_MAX_AF = ".")' \
#  --output "${vcf_output_file}" \
#  --output-type z


# Check if vep_MAX_AF exists in header
if bcftools view -h "${vcf_input_file}" | grep -q "vep_MAX_AF"; then
    echo "Filtering variants for allele frequency..."
    bcftools view "${vcf_input_file}" \
        --include '(INFO/vep_MAX_AF < 0.01 || INFO/vep_MAX_AF = ".")' \
        --output "${vcf_output_file}" \
        --output-type z
else
    echo "INFO: vep_MAX_AF not found in header, copying file without filtering..."
    cp "${vcf_input_file}" "${vcf_output_file}"
fi

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"