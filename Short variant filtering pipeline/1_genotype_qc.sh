#!/bin/bash
# Created by Victoria Fuller
# Date: 10/06/2025

# Script Name:
# 1_genotype_qc.sh
# Description: Performs per-sample genotype filtering and assigns missing (./.) to the genotypes that fail the filter
# For SNPs: DP >=7 and GQ >=20
# For INDELs: DP >= 10 and GQ >=20 

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount joint_germline_recalibrated_VEP.ann.vcf.gz annotated vcf into session data
# Run: bash 1_genotype_qc.sh <vcf file>

set -euo pipefail

# Define the previous and current step for file names
current_step="genotype_qc"

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
# Set genotypes of failed samples to missing value (.) and adds FAIL to filter column
bcftools filter "${vcf_input_file}" \
    --set-GTs . \
    --include '(TYPE="snp" && FMT/DP >= 7 && FMT/GQ >= 20) || (TYPE="indel" && FMT/DP >= 10 && FMT/GQ >= 20)' \
    --soft-filter "FAIL" \
    --mode + \
    --output "${vcf_output_file}" \
    --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"