#!/usr/bin/env python3
"""
Script Name: cnv_annotate.py
Author: Victoria Fuller
Date Created: 26/11/2025
Last Modified 26/11/2025

Description: 
Description:
Cleans BioMart TSV file
Creates BED file using BioMart file
Annotates combined CNV VCF using BED file

Usage:
python3 <cnv_annotate> --vcf_input <vcf_file> 

Arguments:
--vcf_input : Path to the input vcf file(s)

Dependencies: 
bcftools

Notes:
Ensure all files exist and paths are correct before running the script
Compatible with Python 3.x

"""

import argparse
import sys
from pathlib import Path
from datetime import datetime
import time
import logging
import os
import subprocess
import re
import tempfile

def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Annotates CNV VCF file using Ensembl BioMart"
        )
    parser.add_argument("-v", "--vcf_input", required=True, help="Path to the annotated input vcf file(s) to process")

    # Accept unused arguments so pipeline doesn't break
    parser.add_argument("-g", "--gene_list", help="Path to the gene list file")
    parser.add_argument("-b", "--biomart_file", required=True, help="Path to the Biomart annotation file")
    parser.add_argument("-f", "--flank_bp", type=int, default=5000, help="Number of flanking base pairs for filtering (integer)")
    return parser.parse_args()

def main():

    # Parse command line arguments
    args = parse_args()

    # Define command line arguments as variables 
    script_name = Path(sys.argv[0]).stem
    input_dir = Path("/home/jovyan/session_data/mounted-data-readonly/")
    output_dir = Path("/home/jovyan/session_data/output_data/")
    vcf_input = (args.vcf_input)
    gene_list = (args.gene_list)
    biomart_file = (args.biomart_file)
    flank_bp = int(args.flank_bp)


    # Set up logging

    # Set timestamp and start time
    timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    start_time = time.time()

    # Create log directory if it doesnt exist
    log_dir = output_dir / "logs"

    if not log_dir.is_dir():
        log_dir.mkdir(parents=True, exist_ok=True)

    # Create log file
    log_file = log_dir / f"{script_name}.log"

    logging.basicConfig(
        level = logging.INFO, 
        format = "%(asctime)s [%(levelname)s] %(message)s", 
        handlers = [
            logging.FileHandler(log_file, mode ="a"), # Append to existing log file
            logging.StreamHandler(sys.stdout) # Echo to console
        ]
    )

    logging.info("="*80)
    logging.info(f"Created log directory '{log_dir.stem}' if it did not exist.")
    logging.info(f"Created log file '{log_file.name}' if it did not exist.")
    logging.info(f"Script '{script_name}' started at {timestamp}")
    logging.info(f"Input VCF file: {vcf_input}")
    logging.info(f"Input directory: {input_dir}")
    logging.info(f"Output directory: {output_dir}")
    logging.info("# Processing files...")
    logging.info("="*80)

    # Check input and output directories exist
    if not input_dir.is_dir():
        logging.error(f"Error: Input directory '{input_dir}' does not exist.")
        sys.exit(1)

    if not output_dir.is_dir():
        logging.info(f"Creating output directory '{output_dir.stem}' ...")
        output_dir.mkdir(parents=True, exist_ok=True)

    # Clean BioMart file to ensure it has correct tabs
    def clean_biomart_tsv(biomart_file):
        """Cleans the BioMart TSV file to make it suitable for filtering"""
        biomart_file_path = Path(biomart_file)
        cleaned_tsv = output_dir / (f"{biomart_file_path.stem}.cleaned.tsv")
        logging.info(f"Cleaning BioMart TSV: {biomart_file} -> {cleaned_tsv}")
        with open(biomart_file, "r") as infile, open(cleaned_tsv, "w") as outfile:
            for line in infile:
                line = line.rstrip("\n")
                parts = re.split(r"\t+", line)
                outfile.write("\t".join(parts) + "\n")
                #outfile.write("\t".join(line.strip().split()) + "\n")
        return cleaned_tsv
    
    biomart_file_cleaned = clean_biomart_tsv(biomart_file)

    if not biomart_file_cleaned:
        logging.error(f"Error: Could not clean BioMart file")
        sys.exit(1)

    def build_bed_file(biomart_file, flank_bp):
        """Builds the BED file using the coordinates from the BioMart TSV file"""
        bed_file = output_dir / f"{biomart_file.stem}.bed"
        logging.info(f"Building BED file")

        count_written = 0
        
        with open(biomart_file) as biomart, open(bed_file, "w") as output_bed:
            for i, line in enumerate(biomart):
                if i == 0:
                    continue
                parts = line.rstrip("\n").split("\t")

                if len(parts) < 5:
                    logging.debug(f"Skipping malformed line {i+1}")
                    continue
                chrom, start, end, gene_name = parts[0], int(parts[1]), int(parts[2]), parts[4]
                start = max(0, start - flank_bp)
                end = end + flank_bp
                
                chrom = chrom if chrom.startswith("chr") else (f"chr{chrom}")
                if chrom[3:] in [str(n) for n in range(1, 23)] + ["X", "Y", "M"]:
                    output_bed.write(f"{chrom}\t{start}\t{end}\t{gene_name}\n")
                    count_written += 1
        logging.info(f"{count_written} regions written to {bed_file}")

        if count_written == 0:
            logging.error(f"No regions written to BED file")
            sys.exit(1)

        return bed_file
    
    bed_file = build_bed_file(biomart_file_cleaned, flank_bp)
    
    if not bed_file:
        logging.error(f"Error: Could not build BED file")
        sys.exit(1)

    def sort_compress_bed(bed_file):
        """Sorts and compresses the BED file"""
        sorted_bed = output_dir / f"{bed_file.stem}.sorted.bed"
        compressed_bed = output_dir / f"{bed_file.stem}.sorted.bed.gz"

        logging.info(f"Sorting BED file: {bed_file} -> {sorted_bed}")
        subprocess.run(["sort", "-k1,1", "-k2,2n", str(bed_file)], stdout=open(sorted_bed, "w"), check=True)
    
        logging.info(f"Compressing BED file: {sorted_bed} -> {compressed_bed}")
        subprocess.run(["bgzip", "-c", str(sorted_bed)], stdout=open(compressed_bed, "wb"), check=True)

        logging.info(f"Indexing BED file: {compressed_bed}")
        subprocess.run(["tabix", "-p", "bed", str(compressed_bed)], check=True)
    
        return compressed_bed
    
    compressed_bed = sort_compress_bed(bed_file)

    if not compressed_bed:
        logging.error(f"Error: Could not sort and compress BED file")
        sys.exit(1)

    def cnv_annotate(vcf_input, compressed_bed):
        """
        Annotates variants using the BED file
        Index the output vcf if gzipped
        """

        # Compute output filename based on input filename
        in_path = Path(vcf_input)
        out_path = output_dir / f"{in_path.stem}_annotated.vcf.gz"
        out_format = "z" if out_path.suffix == ".gz" else "v"

        # Create temporary header file
        header = '##INFO=<ID=GeneName,Number=1,Type=String,Description="Gene name from BED">'
        with tempfile.NamedTemporaryFile(mode="w", delete=False) as header_file:
            header_file.write(header)
            header_path = header_file.name

        # Bcftools command
        cmd = [
            "bcftools", "annotate",
            "--annotations", str(compressed_bed),
            "--columns", "CHROM,FROM,TO,INFO/GeneName",
            "--header-lines", header_path,
            "--output", str(out_path),
            "--output-type", out_format,
            str(vcf_input)
        ]

        # Run the bcftools command
        output = subprocess.run(cmd, capture_output=True, text=True)

        if output.returncode != 0:
            print("STDOUT:", output.stdout)
            print("STDERR:", output.stderr)
            sys.exit(output.returncode)

        # Index the output VCF if gzipped
        if out_path.suffix == ".gz":
            index_cmd = [
                "bcftools", "index", "-t", str(out_path)
                ]
            subprocess.run(index_cmd, capture_output=True, text=True)
            
        # Print output path so it can be captured by the pipeline
        print(f"Annotated VCF written to {out_path}")

        return out_path
    
    for vcf_file in vcf_input.split(","):

        if not Path(vcf_file).is_file():
            logging.error(f"Input VCF {vcf_file} does not exist")
            sys.exit(1)
        
        output_vcf = cnv_annotate(vcf_file, compressed_bed)

        if output_vcf:
            logging.info(f"Processed input VCF {Path(vcf_file)} to {output_vcf.name}")
        else:
            logging.error(f"Failed to process input VCF {Path(vcf_file).name}")

    logging.info(f"Successfully completed script '{script_name}'")

    duration = time.time() - start_time
    logging.info(f"Script '{script_name}' completed in {duration:.2f} seconds.")

if __name__ == "__main__":
    main()