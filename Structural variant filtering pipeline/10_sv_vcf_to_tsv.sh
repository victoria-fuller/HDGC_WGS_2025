#!/bin/bash
# Created by Victoria Fuller
# Date: 14/06/2025

# Script Name:
# 10_sv_vcf_to_tsv.sh
# Description: Converts the filtered VCF file to a TSV file

# How to run:
# Log in to CYNAPSE using magic link
# Start interactive session and open terminal
# Mount annotated structural variant vcf files into session data
# sample202.manta.diploid_sv_VEP.ann.vcf.gz, sample252.manta.diploid_sv_VEP.ann.vcf.gz, 
# sample301.manta.diploid_sv_VEP.ann.vcf.gz, sample302.manta.diploid_sv_VEP.ann.vcf.gz, sample303.manta.diploid_sv_VEP.ann.vcf.gz
# Run: bash 10_sv_vcf_to_tsv.sh <vcf file path> 

set -euo pipefail

# Define the current step for file names
previous_step="both_siblings"
current_step="sv_vcf_to_tsv"

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
header="CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tST349_202_sample202\tST349_252_sample252\tST349_301_sample301\tST349_302_sample302\tST349_303_sample303\t\
vep_Allele\tvep_Consequence\tvep_IMPACT\tvep_SYMBOL\tvep_Gene\tvep_Feature_type\tvep_Feature\tvep_BIOTYPE\tvep_EXON\tvep_INTRON\t\
vep_HGVSc\tvep_HGVSp\tvep_cDNA_position\tvep_CDS_position\tvep_Protein_position\tvep_Amino_acids\tvep_Codons\tvep_Existing_variation\t\
vep_DISTANCE\tvep_STRAND\tvep_FLAGS\tvep_VARIANT_CLASS\tvep_SYMBOL_SOURCE\tvep_HGNC_ID\tvep_CANONICAL\tvep_MANE\tvep_MANE_SELECT\tvep_MANE_PLUS_CLINICAL\t\
vep_TSL\tvep_APPRIS\tvep_CCDS\tvep_ENSP\tvep_SWISSPROT\tvep_TREMBL\tvep_UNIPARC\tvep_UNIPROT_ISOFORM\tvep_GENE_PHENO\tvep_NEAREST\tvep_SIFT\tvep_PolyPhen\t\
vep_DOMAINS\tvep_miRNA\tvep_AF\tvep_AFR_AF\tvep_AMR_AF\tvep_EAS_AF\tvep_EUR_AF\tvep_SAS_AF\tvep_gnomADe_AF\tvep_gnomADe_AFR_AF\tvep_gnomADe_AMR_AF\t\
vep_gnomADe_ASJ_AF\tvep_gnomADe_EAS_AF\tvep_gnomADe_FIN_AF\tvep_gnomADe_MID_AF\tvep_gnomADe_NFE_AF\tvep_gnomADe_REMAINING_AF\t\
vep_gnomADe_SAS_AF\tvep_gnomADg_AF\tvep_gnomADg_AFR_AF\tvep_gnomADg_AMI_AF\tvep_gnomADg_AMR_AF\tvep_gnomADg_ASJ_AF\tvep_gnomADg_EAS_AF\t\
vep_gnomADg_FIN_AF\tvep_gnomADg_MID_AF\tvep_gnomADg_NFE_AF\tvep_gnomADg_REMAINING_AF\tvep_gnomADg_SAS_AF\tvep_MAX_AF\tvep_MAX_AF_POPS\t\
vep_FREQS\tvep_CLIN_SIG\tvep_SOMATIC\tvep_PHENO\tvep_PUBMED\tvep_MOTIF_NAME\tvep_MOTIF_POS\tvep_HIGH_INF_POS\tvep_MOTIF_SCORE_CHANGE\t\
vep_TRANSCRIPTION_FACTORS\tvep_CADD_phred\tvep_HGVSp_VEP\tvep_REVEL_score\tvep_clinvar_clnsig\tvep_clinvar_id\tvep_clinvar_review\tvep_clinvar_trait"

# Write header to file
echo -e "${header}" > "${tsv_output_file}"

# Run query command and extract fields
echo "Querying the vcf..."
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER[\t%GT]\t%INFO/vep_Allele\t%INFO/vep_Consequence\t%INFO/vep_IMPACT\t%INFO/vep_SYMBOL\t%INFO/vep_Gene\t%INFO/vep_Feature_type\t%INFO/vep_Feature\t%INFO/vep_BIOTYPE\t%INFO/vep_EXON\t%INFO/vep_INTRON\t%INFO/vep_HGVSc\t%INFO/vep_HGVSp\t%INFO/vep_cDNA_position\t%INFO/vep_CDS_position\t%INFO/vep_Protein_position\t%INFO/vep_Amino_acids\t%INFO/vep_Codons\t%INFO/vep_Existing_variation\t%INFO/vep_DISTANCE\t%INFO/vep_STRAND\t%INFO/vep_FLAGS\t%INFO/vep_VARIANT_CLASS\t%INFO/vep_SYMBOL_SOURCE\t%INFO/vep_HGNC_ID\t%INFO/vep_CANONICAL\t%INFO/vep_MANE\t%INFO/vep_MANE_SELECT\t%INFO/vep_MANE_PLUS_CLINICAL\t%INFO/vep_TSL\t%INFO/vep_APPRIS\t%INFO/vep_CCDS\t%INFO/vep_ENSP\t%INFO/vep_SWISSPROT\t%INFO/vep_TREMBL\t%INFO/vep_UNIPARC\t%INFO/vep_UNIPROT_ISOFORM\t%INFO/vep_GENE_PHENO\t%INFO/vep_NEAREST\t%INFO/vep_SIFT\t%INFO/vep_PolyPhen\t%INFO/vep_DOMAINS\t%INFO/vep_miRNA\t%INFO/vep_AF\t%INFO/vep_AFR_AF\t%INFO/vep_AMR_AF\t%INFO/vep_EAS_AF\t%INFO/vep_EUR_AF\t%INFO/vep_SAS_AF\t%INFO/vep_gnomADe_AF\t%INFO/vep_gnomADe_AFR_AF\t%INFO/vep_gnomADe_AMR_AF\t%INFO/vep_gnomADe_ASJ_AF\t%INFO/vep_gnomADe_EAS_AF\t%INFO/vep_gnomADe_FIN_AF\t%INFO/vep_gnomADe_MID_AF\t%INFO/vep_gnomADe_NFE_AF\t%INFO/vep_gnomADe_REMAINING_AF\t%INFO/vep_gnomADe_SAS_AF\t%INFO/vep_gnomADg_AF\t%INFO/vep_gnomADg_AFR_AF\t%INFO/vep_gnomADg_AMI_AF\t%INFO/vep_gnomADg_AMR_AF\t%INFO/vep_gnomADg_ASJ_AF\t%INFO/vep_gnomADg_EAS_AF\t%INFO/vep_gnomADg_FIN_AF\t%INFO/vep_gnomADg_MID_AF\t%INFO/vep_gnomADg_NFE_AF\t%INFO/vep_gnomADg_REMAINING_AF\t%INFO/vep_gnomADg_SAS_AF\t%INFO/vep_MAX_AF\t%INFO/vep_MAX_AF_POPS\t%INFO/vep_FREQS\t%INFO/vep_CLIN_SIG\t%INFO/vep_SOMATIC\t%INFO/vep_PHENO\t%INFO/vep_PUBMED\t%INFO/vep_MOTIF_NAME\t%INFO/vep_MOTIF_POS\t%INFO/vep_HIGH_INF_POS\t%INFO/vep_MOTIF_SCORE_CHANGE\t%INFO/vep_TRANSCRIPTION_FACTORS\t%INFO/vep_CADD_phred\t%INFO/vep_HGVSp_VEP\t%INFO/vep_REVEL_score\t%INFO/vep_clinvar_clnsig\t%INFO/vep_clinvar_id\t%INFO/vep_clinvar_review\t%INFO/vep_clinvar_trait\n' ${vcf_input_file} >> ${tsv_output_file}

echo "TSV file written to ${tsv_output_file}"