rule faToTwoBit:
    input:
        config.get("ucsc_trackhub", {})
        .get("process_fasta", {})
        .get("path", "data/genome/genome.fasta"),
    output:
        "results/get_genome/genome.2bit",
    params:
        extra=config.get("ucsc_trackhub", {})
        .get("process_fasta", {})
        .get("faToTwoBit", ""),
    log:
        "results/get_genome/fa_to_2bit.log",
    wrapper:
        "v7.1.0/bio/ucsc/faToTwoBit"


rule get_chrom_sizes:
    input:
        config.get("ucsc_trackhub", {})
        .get("process_fasta", {})
        .get("path", "data/genome/genome.fasta"),
    output:
        "results/get_genome/genome.chrom.sizes",
    params:
        extra="-detailed"
    log:
        "results/get_genome/get_chrom_sizes.log",
    container:
        "docker://quay.io/biocontainers/ucsc-fasize:482--h0b57e2e_0"
    shell:
        """
        faSize {params.extra} {input} > {output}
        """