# Structural variant pipeline
## Scripts used:
[`WGS_HDGC_SV_pipeline.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/WGS_HDGC_SV_pipeline.sh) : Retreives file path from output file to automate filtering pipeline with optional scripts  
  
[`combine_sv_vcf.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/combine_sv_vcf.sh) : Combines individual structural variant VCF files into a joint VCF for downstream processing  
  
[`pass_filter.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/pass_filter.sh) : Filters to keep variants that pass technical filter from Manta  

[`split_vep.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/split_vep.sh) : Splits up VEP consequences into multiple fields  

[`filter_af.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_af.sh) : Filters to keep variants that have an allele frequency < 0.01 or missing in gnomAD  

[`filter_genes.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_genes.sh) : Filters to keep variants in or near to genes of interest or genes physically interacting with them    

[`filter_high_moderate.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_high_moderate.sh) : Filters to keep variants that are high or moderate impact as predicted by Ensembl VEP    

[`filter_deletion.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_deletion.sh) : Filters to keep only deletions   

[`protein_coding.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/protein_coding.sh) : Filters to keep protein coding variants  
  
[`filter_modifier.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_modifier.sh) : Filters to keep variants that are modifier impact as predicted by Ensembl VEP    

[`filter_tfbs.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_tfbs.sh) : Filters to keep variants affecting regulatory regions  

[`vcf_to_tsv.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/vcf_to_tsv.sh) : Converts filtered VCF file to a TSV file

# Additional files
[`hdgc_gene_list.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/hdgc_gene_list.txt) : Gene list used to filter for genes of interest  

[`biomart_export.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/biomart_export.txt) : BioMart export file used to generate BED files for gene filtering
