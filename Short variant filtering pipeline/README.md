# Short variant filtering pipeline
Pipeline used to filter output from GATK HaplotypeCaller annotated joint VCF file to produce a list of candidate variants shorter than 50 base pairs.   

Scripts used:  
1_genotype_qc.sh  
Performs per-sample genotype filtering and assigns missing (./.) to the genotypes that fail the filter. 

2_pass_filter.sh  
Filters variants to include only those that have PASS in the filter field from annotated VCF using bcftools. 
Removes variants with VQSLOD less than 99.9% truth sensitivity and with missing genotypes (./.) or homozyogus reference for the proband. 

3_remove_multiallelic.sh  
Removes multiallelic sites to prvent issues with split VEP command.

4_split_vep.sh  
Splits VEP consequences into separate fields to allow for downstream filtering by impact, consequence and allele frequency.

5_filter_af.sh/n  
Keeps variants that have a maximum allele frequency of < 0.01 or absent (.) from gnomAD.

6_optional_filter_genes.sh  
Optional filter to keep variants in or near to CDH1 or CTNNA1 or genes physically interacting with them identified by STRING.
Was not used when considering variants present across the whole genome. 

7a_filter_high_moderate_impact.sh  
Keeps HIGH or MODERATE impact variants with SIFT < 0.05 (deleterious), PolyPhen > 0.908 (probably damaging, possibly damaging). 
Used after 5_filter_af.sh when considering variants present across the whole genome. 

7b_filter_modifier.sh  
Filters to keep MODIFIER variants. 
Used after 5_filter_af.sh when considering variants present across the whole genome. 

7c_filter_high_moderate_impact.sh  
Keeps HIGH or MODERATE impact variants with SIFT < 0.05 (deleterious), PolyPhen > 0.908 (probably damaging, possibly damaging).
Used after 6_optional_filter_genes.sh when considering variants present in CDH1 or CTNNA1 or genes physically interacting with them. 

7d_filter_modifier.sh  
Filters to keep MODIFIER variants. 
Used after 6_optional_filter_genes.sh when considering variants present in CDH1 or CTNNA1 or genes physically interacting with them.

8b_filter_tfbs.sh  
Filters to keep regulatory variants (TFBS ablation,TFBS amplification, TF binding site variant, regulatory region ablation, regulatory region amplification, regulatory region variant). 
Used after 7b_filter_modifier.sh when considering variants present across the whole genome. 

8d_filter_tfbs.sh  
Filters to keep regulatory variants (TFBS ablation,TFBS amplification, TF binding site variant, regulatory region ablation, regulatory region amplification, regulatory region variant). 
Used after 7d_filter_modifier.sh when considering variants present in CDH1 or CTNNA1 or genes physically interacting with them. 

9a_both_sibling_gt.sh  
Removes variants with missing genotypes (./.) or homozyogus reference for the proband and both siblings

9b_one_sibling_gt.sh  
Removes variants with missing genotypes (./.) or homozyogus reference for the proband and one sibling

10_vcf_to_tsv.sh  
Converts the filtered VCF file to a TSV file
