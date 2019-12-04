# pipeline-bisulfite-sequencing

Instructions on how to perform bisulfite sequencing data pre-processing and analyses

# Installation

## Using conda environments

```shell
conda create --file environment.yaml
```

The core packages are found in `environment.sh`, if you want to install packages one-by-one, or troubleshoot installation.

# Usage

## Activate the conda environment

This will let you access all of the software you'll likely need.

```shell
conda activate BSseq
```

## List your metadata in `config.tsv`

`config.tsv` should contain all relevant metadata to your samples.
Each row of `config.tsv` is a sample and each column is a particular feature you want to consider for pre-processing or analysis.
See [detailed notes](docs/directory-structure/README.md) for more information.

## Copy `Snakefile` to your data directory

```shell
cp pipeline/Snakefile your/data/directory/
cd your/data/directory/
```

This will allow you to run `snakemake` in the `your/data/directory/` folder, read the rules written in `Snakefile`, and pre-process your data.

## Run the pre-processing pipeline with Snakemake

Run

```shell
snakemake -n
```

to preview what jobs you're about to run.
If this lists all the steps your expect for each sample, you can tell Snakemake to execute the jobs with

```shell
snakemake
```

Next, we'll cover what the bioinformatic pipeline for pre-processing your data entails.

# Pre-processing Pipeline

The overall pipeline looks like this:

![Pre-processing pipeline]()

A brief description of each step is below.

## FastQC

FastQC [1] tool generates an HTML report that reviews a variety of quality control (QC) metrics for sequencing data, in general.
Important metrics to consider are:

* Per base sequence quality
* Sequence length distribution
* Sequence duplication levels
* Adapter content

A more detailed description of what to look out for can be found in [the detailed docs](docs/fastqc/README.md).

## Trim Galore!

Trim Galore! [2] trims adapter contamination and low-quality bases from the end of reads.
Use this if you have particularly large adapter content or lots of low-quality base calls in the 3' end of your reads.
If the sequencing data is of good quality, you can skip this step.

## Bismark

Bismark [3] performs the alignment, using Bowtie2 as the underlying aligner.
It requires a pre-converted genome to perform the alignment against, not the standard reference sequence you'd use for other genomics assays.
Alignment will produce a BAM file, which should then be deduplicated.

To extract useful information about how many (un)methylated reads cover each C in your dataset, use the `bismark_methylation_extractor` tool that comes with Bismark.
This extracted data will be in a tabular format that most downstream analysis tools can read in directly and use.

There is also a summary report that is generated after methylation extraction that contains some QC metrics.
These metrics include:

* % of `CpG` methylation
* % of `CHG` methylation
* % of `CHH` methylation
* Duplication rates
* M-bias

`H` here stands for `A/C/T`.

A more detailed description of what to look out for can be found in [the detailed docs](docs/bismark/README.md).

If your data has good QC metrics, you're ready to proceed to your analysis.

# Analysis

The most common analysis step for bisulfite-sequencing data is calling differentially methylated regions (DMRs) in your samples between your desired conditions.

## dmrseq

`dmrseq` [4] is an R package developed to call DMRs from bisulfite-sequencing data while controlling for false discoveries.

This tool starts by calculating matrices (`CpG`s by samples) of methylated and total read counts.
You can directly read in tables from `bismark_methylation_extractor` to make this process simpler.
You then specify the test covariate (your condition of interest) and other nuisance covariates (sequencing batch or age, for example) for each sample in a design matrix and test for differential methylation.

This can be done with single- or multi-threaded processes to decrease runtime.
[`pipeline/call-dmrs.R`](pipeline/call-dmrs.R) is an example script that can be modified for your specific use.
See the [documentation on Bioconductor](https://bioconductor.org/packages/release/bioc/html/dmrseq.html) for more details.

Copy `pipeline/call-dmrs.R` into `your/data/directory/` and edit it such that you will be comparing your condition of interest and controlling for other confounding factors.

Run the script by running

```shell
Rscript call-dmrs.R config.tsv Methylation/sample1.bismark.cov.gz Methylation/sample2.bismark.cov.gz ...
```

See comments in the script for details on where to edit it.

## QC metrics for DMRs

Plot a histogram of the p-values from the DMR calls, to ensure they don't have odd behaviour.
See [this blog post](http://varianceexplained.org/statistics/interpreting-pvalue-histogram/) for an explanation of what its shape can tell you.

To limit false discoveries that may not be biologically meaningful, consider DMRs that have a median change in methylation of >= 10% between your test conditions (or larger if you choose).

# References

[1] Simon Andrews, FastQC: a quality control tool for high throughput sequence data. 2010. https://github.com/s-andrews/FastQC

[2] Felix Krueger, Trim Galore. 2012. https://github.com/FelixKrueger/TrimGalore

[3] F. Krueger and S. R. Andrews, “Bismark: a flexible aligner and methylation caller for Bisulfite-Seq applications,” Bioinformatics, vol. 27, no. 11, pp. 1571–1572, Jun. 2011. https://github.com/FelixKrueger/Bismark

[4] K. Korthauer, S. Chakraborty, Y. Benjamini, and R. A. Irizarry, “Detection and accurate false discovery rate control of differentially methylated regions from whole genome bisulfite sequencing,” Biostatistics, Feb. 2018. https://github.com/kdkorthauer/dmrseq
