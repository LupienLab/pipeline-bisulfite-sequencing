# pipeline-bisulfite-sequencing

Instructions on how to perform bisulfite sequencing data pre-processing and analyses

# Installation

## Using conda environments

```shell
conda create --file environment.yaml
```

The core packages are found in `environment.sh`, if you want to install packages one-by-one, or troubleshoot installation.

# Usage

Activate the conda environment to access all of the software you'll likely need.

```shell
conda activate BSseq
```

After this, you'll need to go through the bioinformatic pipeline for pre-processing your data.

# Pre-processing Pipeline

The overall pipeline looks like this:

![Pre-processing pipeline]()

A brief description of each step is below.

## FastQC

This tool generates an HTML report that reviews a variety of quality control (QC) metrics for sequencing data, in general.
Important metrics to consider are:

* Per base sequence quality
* Sequence length distribution
* Sequence duplication levels
* Adapter content
