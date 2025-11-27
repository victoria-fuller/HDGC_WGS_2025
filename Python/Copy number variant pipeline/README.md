# Copy number variant pipeline
## Scripts used:
[`WGS_HDGC_CNV_pipeline.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/WGS_HDGC_CNV_pipeline.py) : Retreives file path from output file to automate filtering pipeline with optional scripts  
  
[`combine_cnv_vcf.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/combine_sv_vcf.py) : Combines individual copy number variant VCF files into a joint VCF for downstream processing  
  
[`cnv_annotate.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/pass_filter.py) : Prepares a bed file with genes downloaded from Ensembl BioMart for annotation of the CNV VCF file and annotates VCF file using gene names  

[`filter_genes.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_genes.py) : Filters to keep variants in or near to genes of interest or genes physically interacting with them      

[`cnv_filter_deletion.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_deletion.py) : Filters to keep only copy number deletions 

[`vcf_to_tsv.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/vcf_to_tsv.py) : Converts filtered VCF file to a TSV file

# Additional files
[`hdgc_gene_list.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/hdgc_gene_list.txt) : Gene list used to filter for genes of interest  

[`biomart_export.txt`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/biomart_export.txt) : BioMart export file used to generate BED files for gene filtering

