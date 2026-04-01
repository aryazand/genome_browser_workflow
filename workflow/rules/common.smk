# import basic packages
import pandas as pd
from snakemake.utils import validate
import re


# Function to select all files in a directory that match a pattern defined in config file
# The function should return the path to file relative to the workflow root, so that it can be used as input in the rules.
def select_bigwig(wildcards):
    folder = (
        config.get("ucsc_trackhub", {})
        .get("process_bw", {})
        .get("directory", "data/bigwig/")
    )
    pattern_str = (
        config.get("ucsc_trackhub", {}).get("process_bw", {}).get("regex", ".*\\.bw$")
    )
    pattern = re.compile(pattern_str)
    bigwig_files = [os.path.join(folder, f) for f in os.listdir(folder) if pattern.search(f)]
    return bigwig_files


def select_bigbed(wildcards):
    folder = (
        config.get("ucsc_trackhub", {})
        .get("process_bed", {})
        .get("directory", "data/bed/")
    )
    pattern_str = (
        config.get("ucsc_trackhub", {}).get("process_bed", {}).get("regex", ".*\\.bed$")
    )
    pattern = re.compile(pattern_str)
    bigbed_files = [os.path.join(folder, f) for f in os.listdir(folder) if pattern.search(f)]
    return bigbed_files
