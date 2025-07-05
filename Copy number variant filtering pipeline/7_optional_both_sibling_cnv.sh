#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 7_optional_both_sibling_cnv.sh
# Removes variants with missing genotypes (./.) or homozyogus reference for the proband and both siblings

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.manta.diploid_sv_VEP.ann.vcf.gz, sample252.manta.diploid_sv_VEP.ann.vcf.gz, 
# sample301.manta.diploid_sv_VEP.ann.vcf.gz, sample302.manta.diploid_sv_VEP.ann.vcf.gz, sample303.manta.diploid_sv_VEP.ann.vcf.gz
# Run: bash 7_optional_both_sibling_cnv.sh <vcf file path> 

set -euo pipefail

# Define the current step for file names
previous_step="filter_del"
current_step="both_siblings"

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
# Includes variants without missing (./.) or homozygous reference (0/0) genotypes in the proband and both siblings
echo "Filtering for variants in both siblings..."
bcftools filter "${vcf_input_file}" \
  --include '(FORMAT/GT[3]!="./." && FORMAT/GT[3]!="0/0") && (FORMAT/GT[4]!="./." && FORMAT/GT[4]!="0/0")' \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"