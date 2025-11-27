#!/bin/bash
# Created by Victoria Fuller
# Date: 23/10/2025

# Script Name:
# filter_genes.sh
# Description: Filters to keep variants in or near to genes of interest

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session
# Mount annotated vcf file into session data
# Mount .txt file containing genomic coordinates of Human genes GRCh38
# Mount .txt file containing gene list into session data
# Run: bash filter_genes.sh <vcf file>

# Usage: bash filter_genes.sh vcf_input_file.vcf.gz gene_list.txt biomart_tsv_file.tsv [flank_bp]
# Run: bash vcf_to_tsv.sh <vcf file>

set -euo pipefail

# Define the current step for file names
previous_step="filter_af"
current_step="filter_genes"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Ensure the output directory exists
mkdir -p "${data_output_dir}"

# Usage check
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <vcf_input_file.vcf.gz> <gene_list.txt> <biomart_tsv_file> [flank_bp]"
    exit 1
fi

# Accept input files
vcf_input_file="${1}"
gene_list="${2}"
biomart_tsv="${3}"

# Accept input of optional flanking region - default set to 0
flank="${4:-0}"

# Check input files
for file in "$vcf_input_file" "$gene_list" "$biomart_tsv"; do
    [[ -f "$file" ]] || { echo "ERROR: $file not found"; exit 1; }
done

# Extract base names
gene_list_basename=$(basename "$gene_list" .txt)
vcf_basename=$(basename "$vcf_input_file" .vcf.gz)

bed_file="${data_output_dir}/${gene_list_basename}.bed"
sorted_bed_file="${data_output_dir}/${gene_list_basename}.sorted.bed"
compressed_bed_file="${data_output_dir}/${gene_list_basename}.sorted.bed.gz"
vcf_output_file="${data_output_dir}/${vcf_basename}_filtered.vcf.gz"

echo "Building BED file from BioMart TSV (${biomart_tsv}) for genes in ${gene_list} ..."

# Force BioMart file to have tabs
echo "Cleaning BioMart TSV..."
cleaned_biomart_tsv="${data_output_dir}/$(basename "${biomart_tsv}").cleaned"
tr -s ' ' '\t' < "${biomart_tsv}" | sed 's/\r//g' > "${cleaned_biomart_tsv}"

# Reassign the cleaned TSV to original variable
biomart_tsv="${cleaned_biomart_tsv}"

# Assume BioMart TSV has columns: chromosome start end gene_name ...
# Adjust columns as needed
echo "Creating BED file..."
awk -F'\t' -v OFS='\t' -v flank="${flank}" 'NR>1 {start=($2-flank>0?$2-flank:0); end=$3+flank; print $1, start, end, $5}' \
    "${biomart_tsv}" | grep -wFf "${gene_list}" > "${bed_file}"

# Check if bed file has been created
if [[ ! -s "${bed_file}" ]]; then
    echo "ERROR: No genes matched. Check gene names."
    exit 1
fi

# Add chr to bed file to match VCF file 
echo "Adding chr prefix..."
sed -i '/^chr/! s/^/chr/' "${bed_file}"

# Force tabs for indexing
echo "Forcing tabs for indexing..."
awk '{$1=$1; OFS="\t"; print}' "${bed_file}" > "${bed_file}.fixed"
mv "${bed_file}.fixed" "${bed_file}"

# Remove any non standard chromosome names
echo "Removing non standard chromosome names..."
grep -E '^(chr)?([1-9]|1[0-9]|2[0-2]|X|Y|M)[[:space:]]' "${bed_file}" > "${bed_file}.clean"
mv "${bed_file}.clean" "${bed_file}"

# Sort bed file so it can be indexed correctly
echo "Sorting BED file..."
sort -k1,1 -k2,2n "${bed_file}" > "${sorted_bed_file}"

# Compress and index bed file 
echo "Compressing and indexing BED file..."
bgzip -c "${sorted_bed_file}" > "${compressed_bed_file}"
tabix -p bed "${compressed_bed_file}"

echo "Sorted and compressed bed file written to ${compressed_bed_file}"

# Filter VCF using regions from BED
echo "Filtering VCF for variants in genes of interest ..."
bcftools view "${vcf_input_file}" \
    --regions-file "${compressed_bed_file}" \
    --output "${vcf_output_file}" \
    --output-type z

tabix -p vcf "${vcf_output_file}"

echo "Filtered VCF written to ${vcf_output_file}"