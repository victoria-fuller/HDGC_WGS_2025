# Structural variant pipeline
## Scripts used:
[`WGS_HDGC_SV_pipeline.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/WGS_HDGC_SV_pipeline.py) : Retreives file path from output file to automate filtering pipeline with optional scripts  
  
[`combine_sv_vcf.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/combine_sv_vcf.py) : Combines individual structural variant VCF files into a joint VCF for downstream processing  
  
[`pass_filter.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/pass_filter.py) : Filters to keep variants that pass technical filter from Manta  

[`split_vep.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/split_vep.py) : Splits up VEP consequences into multiple fields  

[`filter_af.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_af.py) : Filters to keep variants that have an allele frequency < 0.01 or missing in gnomAD  

[`filter_genes.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_genes.py) : Filters to keep variants in or near to genes of interest or genes physically interacting with them (in this case *CDH1* or *CTNNA1*).    

[`filter_high_moderate.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_high_moderate.py) : Filters to keep variants that are high or moderate impact as predicted by Ensembl VEP    

[`filter_deletion.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_deletion.py) : Filters to keep only deletions   

[`protein_coding.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/protein_coding.py) : Filters to keep protein coding variants  
  
[`filter_modifier.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_modifier.py) : Filters to keep variants that are modifier impact as predicted by Ensembl VEP    

[`filter_tfbs.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/filter_tfbs.py) : Filters to keep variants affecting regulatory regions  

[`vcf_to_tsv.py`](https://github.com/victoria-fuller/HDGC_WGS_2025/blob/main/Python/Structural%20variant%20pipeline/vcf_to_tsv.py) : Converts filtered VCF file to a TSV file

