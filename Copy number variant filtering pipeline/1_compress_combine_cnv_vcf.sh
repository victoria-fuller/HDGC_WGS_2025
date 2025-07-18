#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 1_compress_combine_cnv_vcf.sh
# Description: Combines copy number VCF files generated by cnvkit

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.cnvcall.vcf, sample252.cnvcall.vcf, sample301.cnvcall.vcf, sample302.cnvcall.vcf, sample303.cnvcall.vcf
# Run: bash 1_compress_combine_cnv_vcf.sh

set -euo pipefail

# Define step name
current_step="compress_combine_cnv"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Define VCF files
unaffected_f_relative="sample202.cnvcall.vcf"
father="sample252.cnvcall.vcf"
proband="sample301.cnvcall.vcf"
f_sibling="sample302.cnvcall.vcf"
m_sibling="sample303.cnvcall.vcf"

# Create full paths
vcf_input_files=(
  "${data_input_dir}/${unaffected_f_relative}"
  "${data_input_dir}/${father}"
  "${data_input_dir}/${proband}"
  "${data_input_dir}/${f_sibling}"
  "${data_input_dir}/${m_sibling}"
)

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Check all input files exist
for file in "${vcf_input_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: File not found: $file"
    exit 1
  fi
done

# Compress and index each file
compressed_files=()
for file in "${vcf_input_files[@]}"; do
  base=$(basename "$file")
  compressed="${data_output_dir}/${base}.gz"

  echo "Compressing and indexing $file..."
  bgzip -c "$file" > "$compressed"
  tabix -p vcf "$compressed"

  compressed_files+=("$compressed")
done

# Extract base name for output file name
vcf_output_file="${data_output_dir}/merged.cnvcall.vcf.gz"

# Log tool version
echo "Using bcftools version:"
bcftools --version

# Merge the compressed VCFs
echo "Merging structural variant VCF files..."
bcftools merge "${compressed_files[@]}" \
  --output "${vcf_output_file}" \
  --output-type z

# Index the merged file
tabix -p vcf "${vcf_output_file}"

echo "Merged VCF written to: ${vcf_output_file}"