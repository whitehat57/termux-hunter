#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys

# Fungsi helper untuk jalankan command shell dan tangani error
def run_command(cmd, output_file=None):
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        output = result.stdout.strip()
        if output_file:
            with open(output_file, 'w') as f:
                f.write(output)
            print(f"Output saved to {output_file}")
        else:
            print(output)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr.strip()}")
        sys.exit(1)

# Main parser
parser = argparse.ArgumentParser(description="Bug Bounty Workflow Tool for Termux")
subparsers = parser.add_subparsers(dest='command', required=True)

# Subcommand: recon
recon_parser = subparsers.add_parser('recon', help='Subdomain recon & live filter')
recon_parser.add_argument('target', help='Target domain (e.g., target.com)')
recon_parser.add_argument('--output', '-o', default='alive.txt', help='Output file for live hosts')

def recon(args):
    cmd = f"subfinder -d {args.target} -all -silent | dnsx -silent | httpx -silent -title -tech -status-code -o {args.output}"
    run_command(cmd, args.output)

recon_parser.set_defaults(func=recon)

# Subcommand: crawl
crawl_parser = subparsers.add_parser('crawl', help='Crawl & gather URLs')
crawl_parser.add_argument('input_file', help='Input file (e.g., alive.txt)')
crawl_parser.add_argument('--output', '-o', default='urls.txt', help='Output file for URLs')

def crawl(args):
    cmd = f"cat {args.input_file} | katana -silent | gau | hakrawler | waybackurls | uro | anew {args.output}"
    run_command(cmd, args.output)

crawl_parser.set_defaults(func=crawl)

# Subcommand: params
params_parser = subparsers.add_parser('params', help='Parameter & secret discovery')
params_parser.add_argument('input_file', help='Input file (e.g., urls.txt)')
params_parser.add_argument('--output', '-o', default='params.txt', help='Output file for params')

def params(args):
    cmd = f"cat {args.input_file} | arjun -t 30 | tee {args.output}; cat {args.input_file} | gf xss | tee xss_candidates.txt"
    run_command(cmd)

params_parser.set_defaults(func=params)

# Subcommand: vulnscan
vulnscan_parser = subparsers.add_parser('vulnscan', help='Vulnerability scanning with Nuclei')
vulnscan_parser.add_argument('input_file', help='Input file (e.g., alive.txt)')
vulnscan_parser.add_argument('--output', '-o', default='nuclei_results.txt', help='Output file')
vulnscan_parser.add_argument('--concurrency', '-c', default=20, type=int, help='Concurrency level')
vulnscan_parser.add_argument('--rate-limit', '-rl', default=60, type=int, help='Rate limit')

def vulnscan(args):
    cmd = f"nuclei -l {args.input_file} -t cves/ -t vulnerabilities/ -t misconfiguration/ -c {args.concurrency} -rl {args.rate_limit} -o {args.output}"
    run_command(cmd, args.output)

vulnscan_parser.set_defaults(func=vulnscan)

# Subcommand: xsshunt
xsshunt_parser = subparsers.add_parser('xsshunt', help='XSS hunting with Dalfox')
xsshunt_parser.add_argument('input_file', help='Input file (e.g., xss_candidates.txt)')
xsshunt_parser.add_argument('--output', '-o', default='xss.txt', help='Output file')
xsshunt_parser.add_argument('--blind', '-b', default='https://yours.xss.ht', help='Blind XSS server')

def xsshunt(args):
    cmd = f"dalfox file {args.input_file} --only-poc -b {args.blind} -o {args.output}"
    run_command(cmd, args.output)

xsshunt_parser.set_defaults(func=xsshunt)

# Parse args & jalankan
args = parser.parse_args()
args.func(args)
