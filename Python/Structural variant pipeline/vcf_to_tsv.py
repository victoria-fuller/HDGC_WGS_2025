#!/usr/bin/env python3
"""
Script Name: vcf_to_tsv.py
Author: Victoria Fuller
Date Created: 19/11/2025
Last Modified 19/11/2025, 20/11/2025

Description: 
Description: Converts VCF files to TSV files

Usage:
python3 <vcf_to_tsv> --vcf_input <vcf_file> 

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

def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Converts VCF files to TSV files"
        )
    parser.add_argument("-v", "--vcf_input", required=True, help="Path to the annotated input vcf file(s) to process")

    # Accept unused arguments so pipeline doesn't break
    parser.add_argument("-g", "--gene_list", help="Path to the gene list file")
    parser.add_argument("-b", "--biomart_file", help="Path to the Biomart annotation file")
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


    def extract_info_fields(vcf_input):
        """Extract INFO fields from VCF header"""
        try:
            cmd = [
                "bcftools", "view",
                "-h", 
                str(vcf_input)
            ]
            
            output = subprocess.run(cmd, capture_output=True, text=True)
            
            info_fields = []

            for line in output.stdout.splitlines():
                if line.startswith("##INFO"):
                    try:
                        key = line.split("ID=")[1].split(",")[0]
                        info_fields.append(key)
                    except Exception:
                        continue
            return info_fields
        except Exception as e:
            logging.error(f"Failed to extract INFO fields: {e}")
            return []
        
    info_fields = extract_info_fields(vcf_input)

    if not info_fields:
        logging.error(f"Error: No INFO fields found in VCF header")
        sys.exit(1)

    def extract_samples(vcf_input):
        """Extract sample names from VCF using bcftools"""
        cmd = [
            "bcftools", "query", 
            "-l", 
            str(vcf_input)
        ]

        output = subprocess.run(cmd, capture_output=True, text=True)
        return output.stdout.split()
    
    samples = extract_samples(vcf_input)

    logging.info(f"Samples found: {samples}")

    # Build header using INFO fields and sample names
    header_columns = ["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER"]
    header_columns += [f"{s}_GT" for s in samples]
    header_columns += info_fields
    header = "\t".join(header_columns)

    logging.info(f"Header created: {header}")

    # Build query string
    query_string = "%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER[\t%GT]\t"
    if info_fields:
        query_string += "\t".join([f"%INFO/{field}" for field in info_fields])
    query_string += "\n"

    logging.info(f"Created query string: {query_string}")

    def vcf_to_tsv(vcf_input):
        """Converts VCF file to TSV file"""

        # Compute output filename based on input filename
        in_path = Path(vcf_input)
        out_path = output_dir / f"{in_path.stem}.tsv"
        
        # Bcftools command
        cmd = [
            "bcftools", "query",
            "-f", query_string, 
            str(vcf_input)
        ]

        # Run the bcftools command
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
            sys.exit(result.returncode)
        
        # Write header to output file
        # Append the bcftools output to output file
        with open(out_path, "w") as output_tsv:
            output_tsv.write(header + "\n")
            output_tsv.write(result.stdout)

        # Index the output VCF if gzipped
        if out_path.suffix == ".gz":
            index_cmd = [
                "bcftools", "index", "-t", str(out_path)
                ]
            subprocess.run(index_cmd, capture_output=True, text=True)
            
        # Print output path so it can be captured by the pipeline
        print(f"Filtered TSV written to {out_path}")

        return out_path
    
    for vcf_file in vcf_input.split(","):

        if not Path(vcf_file).is_file():
            logging.error(f"Input VCF {vcf_file} does not exist")
            sys.exit(1)
        
        output_tsv = vcf_to_tsv(vcf_file)

        if output_tsv:
            logging.info(f"Processed input VCF {Path(vcf_file)} to {output_tsv.name}")
        else:
            logging.error(f"Failed to process input VCF {Path(vcf_file).name}")

    logging.info(f"Successfully completed script '{script_name}'")

    duration = time.time() - start_time
    logging.info(f"Script '{script_name}' completed in {duration:.2f} seconds.")

if __name__ == "__main__":
    main()