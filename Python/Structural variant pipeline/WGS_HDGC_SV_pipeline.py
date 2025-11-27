#!/usr/bin/env python3
"""
Script Name: WGS_HDGC_SNV_pipeline.py
Author: Victoria Fuller
Date Created: 20/11/2025
Last Modified 20/11/2025, 26/11/2025

Description: 
Retreives file path from output file to automate filtering pipeline with optional scrips

Usage:
python3 <WGS_HDGC_SV_pipeline.py> --pipeline <pipeline> --vcf_input <vcf_file> --gene_list <gene_list> --biomart_file <biomart_file> --flank_bp <flank_bp>

Arguments:
-p --pipeline : Name of the pipeline to be used
-v --vcf_input : Path to the input vcf file(s)
-g --gene_list : Path to the gene list file
-b --biomart_file : Path to the Biomart annotation file 
-f --flank_bp : Number of flanking base pairs for filtering (integer)

Dependencies: 
bcftools

Notes:
Ensure all files exist and paths are correct before running the script
Compatible with Python 3.x

"""

__author__ = "Victoria Fuller"
__version__ = "1.0"
__date__ = "20/11/2025"
__status__ = "Development"

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
        description="Automates WGS HDGC SNV filtering pipeline"
        )
    parser.add_argument("-p", "--pipeline", required=True, help="Name of the pipeline to be used")
    parser.add_argument("-v", "--vcf_input", required=False, help="Optional. Path to the annotated input vcf file(s) to process. If not provided, pipeline will combine all annotated VCFs")
    parser.add_argument("-g", "--gene_list", required=True, help="Path to the gene list file")
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
    logging.info(f"Selected pipeline: {args.pipeline}")
    logging.info(f"Script '{script_name}' started at {timestamp}")
    logging.info(f"Input VCF file: {current_file}")
    logging.info(f"Input directory: {input_dir}")
    logging.info(f"Output directory: {output_dir}")
    logging.info(f"Gene list file: {args.gene_list}")
    logging.info(f"Biomart file: {args.biomart_file}")
    logging.info(f"Flanking base pairs: {args.flank_bp}")
    logging.info("# Processing files...")
    logging.info("="*80)

    if args.vcf_input:
        logging.info(f"Using input VCF file: {args.vcf_input}")
        current_file = args.vcf_input
        args.multiple_vcfs = None
    else:
        detected = list(Path(input_dir).glob("*.manta.diploid_sv_VEP.ann.vcf.gz"))
        if not detected:
            logging.error(f"No VCFs found in {input_dir}")
            sys.exit(1)

        logging.info(f"No input VCF provided - combining all annotated VCFs")

        args.multiple_vcfs = [str(file) for file in detected]
        current_file = args.multiple_vcfs[0]

    # Check input and output directories exist
    if not input_dir.is_dir():
        logging.error(f"Error: Input directory '{input_dir}' does not exist.")
        sys.exit(1)

    if not output_dir.is_dir():
        logging.info(f"Creating output directory '{output_dir.stem}' ...")
        output_dir.mkdir(parents=True, exist_ok=True)

    # Define pipelines
    PIPELINES = {
        "whole_genome_high_impact": [
            "combine_sv_vcf.py",
            "pass_filter.py", 
            "split_vep.py", 
            "filter_af.py", 
            "filter_high_moderate.py",
            "filter_deletion.py",
            "protein_coding.py", 
            "vcf_to_tsv.py"
            ],
        "genes_high_impact": [
            "combine_sv_vcf.py",
            "pass_filter.py", 
            "split_vep.py", 
            "filter_af.py", 
            "filter_genes.py", 
            "filter_high_moderate.py",
            "filter_deletion.py",
            "protein_coding.py",  
            "vcf_to_tsv.py"
            ],
        "genes_tfbs": [
            "combine_sv_vcf.py",
            "pass_filter.py", 
            "split_vep.py", 
            "filter_af.py", 
            "filter_genes.py", 
            "filter_modifier.py", 
            "filter_tfbs.py", 
            "vcf_to_tsv.py"
            ],
        "genes_modifier":  [
            "combine_sv_vcf.py",
            "pass_filter.py", 
            "split_vep.py", 
            "filter_af.py", 
            "filter_genes.py", 
            "filter_modifier.py", 
            "vcf_to_tsv.py"
            ],
    }

    logging.info(f"Selected pipeline '{args.pipeline}' scripts: {PIPELINES[args.pipeline]}")

    def run_script(script, current_file, extra_args=None):
        """Run a script and return the output file produced. """
        extra_args = extra_args or []

        # Decide which arguments to pass based on script name
        if "filter_genes" in script:
            # Scripts that require all args
            standard_args = [
                "--vcf_input", current_file,
                "--gene_list", args.gene_list,
                "--biomart_file", args.biomart_file,
                "--flank_bp", str(args.flank_bp)
            ]
            # Accept all input VCFs for first script or none if none provided
        elif "combine_sv_vcf" in script:
            vcfs = getattr(args, "multiple_vcfs", []) or []
            if not vcfs:
                logging.info(f"Skipping {script}, merged VCF provided")
                return current_file
            standard_args = sum([["--vcf_input", file] for file in vcfs], [])
            current_file = None
        else:
            # Scripts that only need the VCF input
            standard_args = ["--vcf_input", current_file]

        logging.info(f"Running script: {script}")
    
        if script.endswith(".py"):
            cmd = ["python3", script] + standard_args + extra_args
            logging.info(f"Running: {' '.join(cmd)}")
        else:
            raise ValueError(f"Unknown script type: {script}")

        # Run the command and capture stdout
        output = subprocess.run(cmd, capture_output=True, text=True)
        logging.info(output.stdout) 

        if output.returncode != 0:
            logging.error(f"Error: {script} failed with return code {output.returncode}")
            sys.exit(output.returncode)

        # Extract lines with "written to ..."
        matches = re.findall(r"written to (.*)", output.stdout)
        output_file = None

        # Prefer VCF files if multiple outputs are found
        if matches:
            vcf_matches = [f for f in matches if re.search(r"\.vcf(\.gz)?$", f)]
            tsv_matches = [f for f in matches if re.search(r"\.tsv$", f)]
            if vcf_matches:
                output_file = vcf_matches[-1] 
            elif tsv_matches:
                output_file = tsv_matches[-1]
            else:
                logging.warning(f"No VCF output detected from {script}, skipping this script's output")
                output_file = current_file

        if not output_file:
            logging.error(f"Error: Could not detect output file from {script}")
            sys.exit(1)

        logging.info(f"{script} completed successfully, output: {output_file}")
        return output_file

        
    def run_pipeline(name):
        if name not in PIPELINES:
            raise ValueError(f"Pipeline '{name}' not recognized. Available pipelines: {list(PIPELINES.keys())}")
        
        current_file = args.vcf_input

        for script in PIPELINES[name]:
            script_name = Path(script).stem
            logging.info(f"Running script: {script_name} on file: {current_file}")
            current_file = run_script(script, current_file)
            
        # Update current_file to the output of the last script
        logging.info(f"Pipeline '{name}' completed. Final output file: {current_file}")

    # Run the pipeline
    run_pipeline(args.pipeline)

    duration = time.time() - start_time
    logging.info(f"Pipeline '{args.pipeline}' completed in {duration:.2f} seconds.")

            
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        # traceback.print_exc()
        sys.exit(1)
