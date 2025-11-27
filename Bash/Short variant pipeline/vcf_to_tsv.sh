#!/bin/bash
# Created by Victoria Fuller
# Date: 23/10/2025

# Script Name:
# vcf_to_tsv.sh
# Description: Converts the filtered VCF file to a TSV file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated vcf file into session data
# Run: bash vcf_to_tsv.sh <vcf file>

set -euo pipefail

# Define the current step for file names
previous_step="filter_high_moderate","filter_modifier","filter_tfbs"
current_step="vcf_to_tsv"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input file as argument
vcf_input_file="${1}"

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Extract base name for output file name
input_basename=$(basename "${vcf_input_file}" .vcf.gz)
tsv_output_file="${data_output_dir}/${input_basename}.tsv"

# Check the input file exists
if [[ ! -f "${vcf_input_file}" ]]; then
  echo "ERROR: Input VCF file not found at ${vcf_input_file}"
  exit 1
fi

# Log bcftools version
echo "Using bcftools version:"
bcftools --version

# Extract INFO fields from VCF file
echo "Extracting INFO fields..."
fields=$(bcftools view -h "${vcf_input_file}" | grep '##INFO' | cut -d'=' -f3 | cut -d',' -f1)

if [ -z "${fields}" ]; then
  echo "ERROR: No INFO fields found in ${vcf_input_file}"
  exit 1
fi

# Build format string for bcftools query
echo "Building format string..."
format_string=$(awk '{printf "%%INFO/%s\\t", $1}' <<< "${fields}")

# Build header line
echo "Building header line..."
header="CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER"

# Extract sample genotypes
samples=$(bcftools query -l "${vcf_input_file}")
for s in ${samples}; do
  header="${header}\t${s}_GT"
done

# Add sample genotypes to header line
header="${header}\t$(echo "${fields}" | paste -sd '\t' -)"

# Run bcftools query and write output to TSV
echo "Converting vcf to tsv..."

{
echo -e "${header}"
bcftools query -f "%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER[\t%GT]\t${format_string}\n" "${vcf_input_file}"
} > "${tsv_output_file}"

echo "TSV file written to ${tsv_output_file}"