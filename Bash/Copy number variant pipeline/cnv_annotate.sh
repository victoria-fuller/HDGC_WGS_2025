#!/bin/bash
# Created by Victoria Fuller
# Date: 26/11/2025

# Script Name:
# cnv_annotate.sh
# Description: Annotates merged CNV VCF file using bed file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount copy number variant vcf files into session data
# Run: bash cnv_annotate.sh

set -euo pipefail

# Define the current step for file names
previous_step="prepare_annotation"
current_step="annotate"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input files
vcf_input_file="${1}"
bed_file="${2}"
gene_list="${3}"
biomart_tsv="${4}"

# Accept input of optional flanking region - default set to 0
flank="${5:-0}"

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

# Run annotation command
# Annotate genes
echo "Annotating variants..."
bcftools annotate "${vcf_input_file}" \
  --annotations "${bed_file}" \
  --columns CHROM,FROM,TO,INFO/GeneName \
  --header-lines <(echo '##INFO=<ID=GeneName,Number=1,Type=String,Description="Gene name from BED">') \
  --output "${vcf_output_file}" \
  --output-type z

# Index output VCF
tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"