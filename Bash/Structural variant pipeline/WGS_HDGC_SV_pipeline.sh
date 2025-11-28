#!/bin/bash
# Created by Victoria Fuller
# Date: 23/10/2025

# Script Name:
# WGS_HDGC_SV_pipeline.sh
# Retrieves file path from output files to automate filtering pipeline with optional scripts

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated vcf files into session data
# Run: WGS_HDGC_SV_pipeline.sh <pipeline> <vcf file> <gene list> <biomart file> <flank_bp>

set -euo pipefail
shopt -s nullglob

# Usage functions
usage () {
    echo "Usage: $0 [whole_genome_high_impact|genes_high_impact|genes_tfbs|genes_modifier] optional:<input_file> <gene_list> <biomart_file> [flank_bp]"
    exit 1
}

# Check arguments 
if [[ $# -lt 2 ]]; then
    usage
fi

# Define directories
data_input_dir="/home/jovyan/session_data/mounted-data-readonly/"
data_output_dir="/home/jovyan/session_data/output-data/"

# Define pipeline type and input file
# Pipeline
pipeline="${1}"

# Detect if a VCF file is provided as the next argument
if [[ "${2}" =~ \.vcf(\.gz)?$ ]]; then
    vcf_input_files=("${2}")
    echo "Using provided input VCF: ${2}"
    shift 2
else
    # If there is no VCF input, combine all annotated VCFs
    vcf_input_files=("${data_input_dir}"/*.manta.diploid_sv_VEP.ann.vcf.gz)
    echo "No input VCF file provided, combining all annotated VCFs"
    shift 1
fi
gene_list="${1}"
biomart_file="${2}"
flank="${3:-0}"


# Capture input VCF argument if provided, otherwise set to 'none'
#vcf_input_arg="${2:-none}"

# Initial input file
#vcf_input_files=("${data_input_dir}"/*.manta.diploid_sv_VEP.ann.vcf.gz)

# Clarify behavior
#if [[ "${vcf_input_arg}" == "none" ]]; then
    #vcf_input_files=("${data_input_dir}"/*.manta.diploid_sv_VEP.ann.vcf.gz)
    #echo "No input VCF file provided, combining all annotated VCFs"
#else
    #if [[ ! -f "${vcf_input_arg}" ]]; then
        #echo "Error: Provided input VCF '${vcf_input_arg}' not found."
        #exit 1
    #fi
    #vcf_input_files=("${vcf_input_arg}")
    #echo "Using provided input VCF: ${vcf_input_arg}"
#fi

if [[ ${#vcf_input_files[@]} -eq 0 ]]; then
    echo "ERROR: No VCF files found in ${data_input_dir}"
    exit 1
fi

# Define current file
current_file="${vcf_input_files[0]}"

echo "Running pipeline: ${pipeline} using ${vcf_input_files[@]} vcf files"

# Define pipeline scripts
whole_genome_high_impact_scripts=(
    "combine_sv_vcf.sh" 
    "split_vep.sh" 
    "filter_af.sh"
    "filter_high_moderate.sh"
    "filter_deletion.sh"
    "protein_coding.sh"
    "vcf_to_tsv.sh"
)

genes_high_impact_scripts=(
    "combine_sv_vcf.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_genes.sh"
    "filter_high_moderate.sh"
    "filter_deletion.sh"
    "protein_coding.sh"
    "vcf_to_tsv.sh"
)

genes_tfbs_scripts=(
    "combine_sv_vcf.sh"
    "split_vep.sh"
    "filter_af.sh"
    "filter_genes.sh"
    "filter_modifier.sh"
    "filter_tfbs.sh"
    "vcf_to_tsv.sh"
)

genes_modifier_scripts=(
    "combine_sv_vcf.sh"
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

    # Run combine_sv_vcf.sh script once to created a combined vcf from multiple vcf input files
    if [[ "${script}" == "combine_sv_vcf.sh" ]]; then

        echo "Running ${script}"
        # Run script once and capture output 
        script_output=$(bash "${script}" | tee /dev/tty)

        # Extract "written to" paths
        output_file=$(echo "$script_output" | grep -oP '(?<=written to ).*')

        # Re-define current file
        current_file="${output_file}"
        vcf_input_files=("${current_file}")

        echo "Output file: ${output_file}"
    elif [[ "${script}" == "filter_genes.sh" ]]; then
        # Run script once and capture output
        script_output=$(bash "${script}" "${current_file}" "${gene_list}" "${biomart_file}" "${flank}" | tee /dev/tty)

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
