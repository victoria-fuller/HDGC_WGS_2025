# Copy number variant pipeline
## Scripts used:
[`WGS_HDGC_CNV_pipeline.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/WGS_HDGC_CNV_pipeline.sh) : Retreives file path from output file to automate filtering pipeline with optional scripts  
  
[`combine_cnv_vcf.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/combine_sv_vcf.sh) : Combines individual copy number variant VCF files into a joint VCF for downstream processing  

[`prepare_annotation.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/prepare_annotation.sh) : Prepares a bed file with genes downloaded from Ensembl BioMart for annotation of the CNV VCF file
  
[`cnv_annotate.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/pass_filter.sh) :  Annotates VCF file using gene names  

[`filter_genes.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_genes.sh) : Filters to keep variants in or near to genes of interest or genes physically interacting with them      

[`cnv_filter_deletion.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/filter_deletion.sh) : Filters to keep only copy number deletions 

[`vcf_to_tsv.sh`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/vcf_to_tsv.sh) : Converts filtered VCF file to a TSV file

# Additional files
[`hdgc_gene_list.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/hdgc_gene_list.txt) : Gene list used to filter for genes of interest  

[`biomart_export.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Bash/Structural%20variant%20pipeline/biomart_export.txt) : BioMart export file used to generate BED files for gene filtering

