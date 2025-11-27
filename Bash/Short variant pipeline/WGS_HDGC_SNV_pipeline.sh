#!/bin/bash
# Created by Victoria Fuller
# Date: 20/10/2025

# Script Name:
# WGS_HDGC_SNV_pipeline.sh
# Retrieves file path from output files to automate filtering pipeline with optional scripts

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated vcf files into session data
# Run: WGS_HDGC_SNV_pipeline.sh <pipeline> <vcf file> <gene list> <biomart file> <flank_bp>

set -euo pipefail

# Usage function
usage () {
    echo "Usage: $0 [whole_genome_high_impact|whole_genome_tfbs|whole_genome_modifier|genes_high_impact|genes_tfbs|genes_modifier] <input_file> <gene_list> <biomart_file> [flank_bp]"
    exit 1
}

# Check arguments 
if [[ $# -lt 2 ]]; then
    usage
fi

# Define pipeline type and input file
# Pipeline
pipeline="${1}"
# Initial input file
vcf_input_file="${2}"

# Define current file
current_file="${vcf_input_file}"

echo "Running pipeline: ${pipeline} using ${current_file} vcf file"

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"


# Define pipeline scripts
whole_genome_high_impact_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_high_moderate.sh"
    "vcf_to_tsv.sh"
)

whole_genome_tfbs_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_modifier.sh"
    "filter_tfbs.sh"
    "vcf_to_tsv.sh"
)

whole_genome_modifier_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_modifier.sh"
    "vcf_to_tsv.sh"
)

genes_high_impact_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_genes.sh"
    "filter_high_moderate.sh"
    "vcf_to_tsv.sh"
)

genes_tfbs_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_genes.sh"
    "filter_modifier.sh"
    "filter_tfbs.sh"
    "vcf_to_tsv.sh"
)

genes_modifier_scripts=(
    "genotype_qc.sh" 
    "pass_filter.sh" 
    "remove_multiallelic.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_genes.sh"
    "filter_modifier.sh"
    "vcf_to_tsv.sh"
)

# Select which scripts to run according to selected pipeline
case "$pipeline" in 
    whole_genome_high_impact)
    scripts=("${whole_genome_high_impact_scripts[@]}");;
    whole_genome_tfbs)
    scripts=("${whole_genome_tfbs_scripts[@]}");;
    whole_genome_modifier)
    scripts=("${whole_genome_modifier_scripts[@]}");;
    genes_high_impact)
    scripts=("${genes_high_impact_scripts[@]}");;
    genes_tfbs)
    scripts=("${genes_tfbs_scripts[@]}");;
    genes_modifier)
    scripts=("${genes_modifier_scripts[@]}");;
    *)
    echo "Error: Unknown pipeline '${pipeline}' "
    usage ;;
esac

# Loop over scripts and process then then pass output into next script

for script in "${scripts[@]}"; do
    echo "Running ${script} with input: ${current_file}"

    if [[ "${script}" == "filter_genes.sh" ]]; then
        # Run script once and capture output
        script_output=$(bash "${script}" "${current_file}" "$3" "$4" "${5:-0}" | tee /dev/tty)

        # Extract "written to" paths
        output_files=$(echo "${script_output}" | grep -oP '(?<=written to ).*')

        # Prefer a .vcf(.gz) file
        output_file=$(printf '%s\n' "${output_files}" | grep -E '\.vcf(\.gz)?$' | tail -n1 || true)

        # If no vcf file found, pick the first output file
        if [[ -z "${output_file}" ]]; then
            output_file=$(printf '%s\n' "${output_files}" | head -n1)
        fi

    else
        # Other scripts
        script_output=$(bash "${script}" "${current_file}" | tee /dev/tty)
        output_file=$(echo "$script_output" | grep -oP '(?<=written to ).*')
    fi

    if [[ -z "${output_file}" ]]; then
        echo "Error: Could not detect output file from ${script}"
        exit 1
    fi

    echo "Output file: ${output_file}"
    current_file="${output_file}"
done

echo "Completed '${pipeline}' pipeline"
echo "Final filtered file: ${current_file}"
