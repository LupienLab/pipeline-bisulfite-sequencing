conda create -n BSseq
conda activate BSseq
conda config --env --add channels bioconda
conda config --env --add channels conda-forge

# tools with some dependencies
conda install bioconda::bedtools
conda install bioconda::sambamba
conda install bioconda::samtools

# tools for bisulfite sequencing pre-processing
conda install bioconda::fastqc
conda install bioconda::bowtie2 bioconda::trim-galore bioconda::bismark
conda install pandas bioconda::snakemake-minimal bioconda::multiqc

# various script-writing tools
conda install r-argparse

# various plotting tools
conda install r-ggplot2 conda-forge::r-upsetr conda-forge::r-pheatmap

# dmrseq for differentially methylated region calling
# minfi for methylation array analyses
conda install bioconda::bioconductor-dmrseq bioconda::bioconductor-minfi

# annotation tools and databases
conda install \
    bioconda::bioconductor-illuminahumanmethylationepicmanifest \
    bioconda::bioconductor-illuminahumanmethylationepicanno.ilm10b4.hg19 \
    bioconda::bioconductor-illuminahumanmethylation450kmanifest \
    bioconda::bioconductor-illuminahumanmethylation450kanno.ilmn12.hg19 \
    bioconda::bioconductor-bsgenome.hsapiens.ucsc.hg38 \
    bioconda::bioconductor-bsgenome.hsapiens.ucsc.hg19
