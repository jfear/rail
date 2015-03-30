Rail-RNA
====

This is the official repo for Rail-RNA, software for RNA-seq analysis. Download the latest stable release at [`releases/install_rail-rna-0.1.0`](https://github.com/buci/rail/blob/master/releases/install_rail-rna-0.1.0?raw=true). **Ask questions in the repo's Gitter: [![Join the chat at https://gitter.im/buci/rail](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/buci/rail?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) .**

Get interested
-----
Rail-RNA's distinguishing features are
* Scalability: built on MapReduce, the software scales to analyze hundreds of RNA-seq samples at the same time. Moreover, through reduced-redundancy analysis, the end-to-end analysis time per sample *decreases* for fixed computer cluster size as the number of samples increases.
* Integrative analysis: the software borrows strength across replicates to achieve more accurate splice junction detection, especially in genomic regions with low levels of coverage.
* Mode agnosticism: Rail-RNA integrates its own parallel abstraction layer that allows it to be run in various distributed computing environments, including the Amazon Web Services (AWS) [Elastic MapReduce (EMR) service](http://aws.amazon.com/elasticmapreduce/), or any distributed environment supported by [IPython](http://ipython.org/), including clusters using batch schedulers like PBS or SGE, Message Passing Interface (MPI), or any cluster with a shared filesystem and mutual SSH access. Alternately, Rail-RNA can be run on a single multi-core computer, without the aid of a batch system or MapReduce implementation.

Outputs currently include
* Alignment BAMs
* Genome coverage bigWigs
* [TopHat](http://ccb.jhu.edu/software/tophat/index.shtml)-like indel and splice junction BEDs
and will likely expand in future versions.

Read the [preprint](https://youtu.be/6ZPZUtE6RgA) for more details.

Get set up
-----
Start with a recent (>= 2009) Mac OS or Linux box. Download [`releases/install_rail-rna-0.1.0`](https://github.com/buci/rail/blob/master/releases/install_rail-rna-0.1.0?raw=true), change to the directory containing it, and run
```
sudo ./install_rail-rna-0.1.0
```
to install for all users or
```
./install_rail-rna-0.1.0
```
to install for just you. Check
```
./install_rail-rna-0.1.0 -h
```
for more installation options. If the executable doesn't work, you may need [Python](http://www.python.org). You'll also need Bowtie 1 and 2 indexes of the appropriate genome assembly if you will be running Rail-RNA in either its single-computer (local) or IPython Parallel (parallel) modes. The easiest way to get these is by downloading an [Illumina iGenome](http://support.illumina.com/sequencing/sequencing_software/igenome.html). If running Rail-RNA on EMR (elastic mode) and aligning to hg19, the assembly can be specified at the command line with the `-a` parameter. More assemblies are on their way.

Get started
-----
Rail-RNA takes as input a [Myrna](http://bowtie-bio.sourceforge.net/myrna/)-style manifest file, which describes a set of input FASTQs that may be on the local filesystem in local and parallel modes; or on the web or Amazon [Simple Storage Service](http://aws.amazon.com/s3/) (S3) in local, parallel, and elastic modes. Each line takes one of the following two forms.

1. (for a set of unpaired input reads) `<FASTQ URL>(tab)<optional MD5>(tab)<sample label>`
2. (for a set of paired input reads) `<FASTQ URL 1>(tab)<optional MD5 1>(tab)<FASTQ URL 2>(tab)<optional MD5 2>(tab)<sample label>`

`<sample label>` must be formatted as `<group ID>-<biorep ID>-<techrep ID>`.

**Find some RNA-seq data, create a manifest file, run**
```
rail-rna
```
**and follow the instructions.** A manual will be posted shortly.

Contributors
-----
* [Abhi Nellore]
* Mark Pritt
* Leo Collado-Torres
* Jamie Morton
* [Jeff Leek]
* [Ben Langmead]

[Abhi Nellore]: https://scholar.google.com/citations?user=XxPWj5oAAAAJ&hl=en
[Leo Collado-Torres]: https://github.com/lcolladotor
[Ben Langmead]: http://www.cs.jhu.edu/~langmea/index.shtml
[Jeff Leek]: http://www.biostat.jhsph.edu/~jleek/
