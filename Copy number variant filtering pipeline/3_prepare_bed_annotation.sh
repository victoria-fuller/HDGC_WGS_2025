#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 3_prepare_bed_annotation.sh
# Description: Prepares a bed file with genes downloaded from Ensembl biomart for annotation of the CNV VCF file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount .txt file containing genomic coordinates of Human genes GRCh38
# Run: bash 3_prepare_bed_annotation.sh <txt input file>

set -euo pipefail

# Define the current step for file names
previous_step="filter_proband"
current_step="create_bed"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

txt_input_file="${1}"

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Extract base name for output file name
input_basename=$(basename "${txt_input_file}" .txt)
bed_file="${data_output_dir}/${input_basename}.bed"
sorted_bed_file="${data_output_dir}/${input_basename}.sorted.bed"
sorted_compressed_bed_file="${data_output_dir}/${input_basename}.sorted.bed.gz"

# Check the input file exists
if [[ ! -f "${txt_input_file}" ]]; then
  echo "ERROR: Input txt file not found at ${txt_input_file}"
  exit 1
fi

# Convert .txt file to .bed file
awk 'BEGIN{OFS="\t"} NR>1 {print $1, $2-1, $3, $5}' "${txt_input_file}" > "${bed_file}"

# Add chr to bed file to match VCF file 
sed -i '/^chr/! s/^/chr/' "${bed_file}"

# Sort bed file so it can be indexed correctly
sort -k1,1 -k2,2n "${bed_file}" > "${sorted_bed_file}"

# Compress and index bed file 
bgzip -c "${sorted_bed_file}" > "${sorted_compressed_bed_file}"
tabix -p bed "${sorted_compressed_bed_file}"

echo "Sorted and compressed bed file written to ${sorted_compressed_bed_file}"