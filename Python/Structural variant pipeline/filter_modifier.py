#!/usr/bin/env python3
"""
Script Name: filter_modifier.py
Author: Victoria Fuller
Date Created: 20/11/2025
Last Modified 20/11/2025

Description: 
Description: Keeps variants with a MODIFIER impact

Usage:
python3 <filter_modifier> --vcf_input <vcf_file> 

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
        description="Filters variants that have a modifier impact"
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

    def filter_modifier(vcf_input):
        """
        Filters variants to include only those with a modifier impact
        Index the output vcf if gzipped
        """

        # Compute output filename based on input filename
        in_path = Path(vcf_input)
        out_path = output_dir / f"{in_path.stem}_filter_modifier.vcf.gz"
        out_format = "z" if out_path.suffix == ".gz" else "v"

        # Bcftools command
        cmd = [
            "bcftools", "view",
            "--include", '(INFO/vep_IMPACT = "MODIFIER")',
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
            print(f"Filtered VCF written to {out_path}")

        return out_path
    
    for vcf_file in vcf_input.split(","):

        if not Path(vcf_file).is_file():
            logging.error(f"Input VCF {vcf_file} does not exist")
            sys.exit(1)
        
        output_vcf = filter_modifier(vcf_file)

        if output_vcf:
            logging.info(f"Processed input VCF {Path(vcf_file)} to {output_vcf.name}")
        else:
            logging.error(f"Failed to process input VCF {Path(vcf_file).name}")

    logging.info(f"Successfully completed script '{script_name}'")

    duration = time.time() - start_time
    logging.info(f"Script '{script_name}' completed in {duration:.2f} seconds.")

if __name__ == "__main__":
    main()