#!/bin/bash
# Created by Victoria Fuller
# Date: 04/07/2025

# Script Name:
# 8_cnv_vcf_to_tsv.sh
# Description: Converts the filtered VCF file to a TSV file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.cnvcall.vcf, sample252.cnvcall.vcf, sample301.cnvcall.vcf, sample302.cnvcall.vcf, sample303.cnvcall.vcf
# Run: bash 8_cnv_vcf_to_tsv.sh <vcf file path>

set -euo pipefail

# Define the current step for file names
previous_step="filter_genes","annotate","filter_del"
current_step="cnv_vcf_to_tsv"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Accept input file as argument or use default
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

# Create header line
echo "Creating header line..."
header="CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tsample202.germline.call\tsample252.germline.call\tsample301.germline.call\tsample302.germline.call\tsample303.germline.call\tIMPRECISE\tSVTYPE\tEND\tSVLEN\tFOLD_CHANGE\tFOLD_CHANGE_LOG\tPROBES\tGeneName"

# Write header to file
echo -e "${header}" > "${tsv_output_file}"

# Run query command and extract fields
echo "Querying the vcf..."
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER[\t%GT]\t%INFO/IMPRECISE\t%INFO/SVTYPE\t%INFO/END\t%INFO/SVLEN\t%INFO/FOLD_CHANGE\t%INFO/FOLD_CHANGE_LOG\t%INFO/PROBES\t%INFO/GeneName\n' ${vcf_input_file} >> ${tsv_output_file}

echo "TSV file written to ${tsv_output_file}"