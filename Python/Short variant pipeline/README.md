# Structural variant pipeline
## Scripts used:
[`WGS_HDGC_SNV_pipeline.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/WGS_HDGC_SNV_pipeline.py) : Retreives file path from output file to automate filtering pipeline with optional scripts  
  
[`genotype_qc.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/genotype_qc.py) : Performs per-sample genotype filtering and assigns missing (./.) to the genotypes that fail the filter  
  
[`pass_filter.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/pass_filter.py) : Filters variants to include only those that have PASS in the filter field from annotated VCF using bcftools. Removes variants with VQSLOD less than 99.9% truth sensitivity and with missing genotypes (./.) or homozyogus reference for the proband  

[`remove_multiallelic.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/remove_multiallelic.py) : Filters variants to keep only biallelic sites to prevent issues with downstream filtering

[`split_vep.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/split_vep.py) : Splits up VEP consequences into multiple fields using bcftools+split-vep  

[`filter_af.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_af.py) : Filters to keep variants that have an allele frequency < 0.01 or missing in gnomAD  

[`filter_genes.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_genes.py) : Filters to keep variants in or near to genes of interest or genes physically interacting with them    

[`filter_high_moderate.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_high_moderate.py) : Filters to keep variants that are HIGH or MODERATE impact as predicted by Ensembl VEP with SIFT < 0.05 (deleterious), PolyPhen > 0.908 (probably damaging, possibly damaging)    
  
[`filter_modifier.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_modifier.py) : Filters to keep variants that are MODIFIER impact as predicted by Ensembl VEP    

[`filter_tfbs.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_tfbs.py) : Filters to keep variants affecting regulatory regions (TFBS ablation,TFBS amplification, TF binding site variant, regulatory region ablation, regulatory region amplification, regulatory region variant)     

[`vcf_to_tsv.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/vcf_to_tsv.py) : Converts filtered VCF file to a TSV file

# Additional files
[`hdgc_gene_list.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/hdgc_gene_list.txt) : Gene list used to filter for genes of interest  

[`biomart_export.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/biomart_export.txt) : BioMart export file used to generate BED files for gene filtering

