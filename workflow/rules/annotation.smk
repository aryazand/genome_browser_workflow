rule gff3_to_genepred:
    input:
        gff=config.get("ucsc_trackhub", {})
        .get("process_genome_annotation", {})
        .get("path", "data/genome/genome.gff"),
    output:
        genepred="results/get_genome/genome.genePred",
    params:
        extra=config["ucsc_trackhub"]["process_genome_annotation"]["gff3_to_GenePred"],
    container:
        "docker://quay.io/biocontainers/ucsc-gff3togenepred:482--h0b57e2e_0"
    log:
        "results/get_genome/gff3ToGenePred.log",
    shell:
        """
        gff3ToGenePred {params.extra} {input.gff} {output.genepred}
        """


rule genepred_to_bgpinput:
    input:
        genepred=rules.gff3_to_genepred.output.genepred,
    output:
        bgpinput="results/get_genome/genome.bgpInput",
    params:
        extra=config["ucsc_trackhub"]["process_genome_annotation"][
            "GenePred_to_bgpInput"
        ],
    container:
        "docker://quay.io/biocontainers/ucsc-genepredtobiggenepred:482--h0b57e2e_0"
    log:
        "results/get_genome/genePredToBigGenePred.log",
    shell:
        """
        genePredToBigGenePred {params.extra} {input.genepred} stdout \
        | sort -k1,1 -k2,2n > {output.bgpinput}
        """


rule bgpinput_to_biggenepred:
    input:
        bgpinput=rules.genepred_to_bgpinput.output.bgpinput,
        chrom_sizes=rules.get_chrom_sizes.output[0],
    output:
        bigGenePred="results/get_genome/genome.bb",
    params:
        extra=config["ucsc_trackhub"]["process_genome_annotation"][
            "bgpInput_to_bigGenePred"
        ],
    container:
        "docker://quay.io/biocontainers/ucsc-bedtobigbed:482--hdc0a859_0"
    log:
        "results/get_genome/bedToBigBed.log",
    shell:
        """
        bedToBigBed {params.extra} {input.bgpinput} {input.chrom_sizes} {output.bigGenePred}
        """
