#!/bin/bash
# Created by Victoria Fuller
# Date: 26/11/2025

# Script Name:
# prepare_annotation.sh
# Description: Prepares a bed file with genes downloaded from Ensembl biomart for annotation of the CNV VCF file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount .txt file containing genomic coordinates of Human genes GRCh38
# Run: bash prepare_annotation.sh

set -euo pipefail

# Define the current step for file names
previous_step="combine_cnv"
current_step="prepare_annotation"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input files
vcf_input_file="${1}"
gene_list="${2}"
biomart_tsv="${3}"

# Accept input of optional flanking region - default set to 0
flank="${4:-0}"

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Extract base name for output file name
input_basename=$(basename "${biomart_tsv}" .txt)
bed_file="${data_output_dir}/${input_basename}.bed"
sorted_bed_file="${data_output_dir}/${input_basename}.sorted.bed"
sorted_compressed_bed_file="${data_output_dir}/${input_basename}.sorted.bed.gz"

# Check the input file exists
if [[ ! -f "${biomart_tsv}" ]]; then
  echo "ERROR: Input txt file not found at ${biomart_tsv}"
  exit 1
fi

# Convert .txt file to .bed file
awk 'BEGIN{OFS="\t"} NR>1 {print $1, $2-1, $3, $5}' "${biomart_tsv}" > "${bed_file}"

# Add chr to bed file to match VCF file 
sed -i '/^chr/! s/^/chr/' "${bed_file}"

# Sort bed file so it can be indexed correctly
sort -k1,1 -k2,2n "${bed_file}" > "${sorted_bed_file}"

# Compress and index bed file 
bgzip -c "${sorted_bed_file}" > "${sorted_compressed_bed_file}"
tabix -p bed "${sorted_compressed_bed_file}"

echo "Sorted and compressed bed file written to ${sorted_compressed_bed_file}"