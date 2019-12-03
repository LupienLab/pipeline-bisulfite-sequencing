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

A more detailed description of what to look out for can be found in [the detailed docs](docs/fastqc/README.md).

## Trim Galore!

This tool trims adapter contamination and low-quality bases from the end of reads.
Use this if you have particularly large adapter content or lots of low-quality base calls in the 3' end of your reads.
If the sequencing data is of good quality, you can skip this step.

## Bismark

This tool performs the alignment, using Bowtie2 as the underlying aligner.
It requires a pre-converted genome to perform the alignment against, not the standard reference sequence you'd use for other genomics assays.
Alignment will produce a BAM file, which should then be deduplicated.

To extract useful information about how many (un)methylated reads cover each C in your dataset, use the `bismark_methylation_extractor` tool that comes with Bismark.
This extracted data will be in a tabular format that most downstream analysis tools can read in directly and use.

There is also a summary report that is generated after methylation extraction that contains some QC metrics.
These metrics include:

* % of CpG methylation
* % of CHG methylation
* % of CHH methylation
* Duplication rates
* M-bias

`H` here stands for `A/C/T`.

A more detailed description of what to look out for can be found in [the detailed docs](docs/bismark/README.md).
