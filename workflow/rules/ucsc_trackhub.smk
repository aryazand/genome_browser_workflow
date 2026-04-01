rule ucsc_trackhub:
    input:
        genome_2bit=config.get("ucsc_trackhub", {}).get(
            "genome_2bit", rules.faToTwoBit.output[0]
        ),
        genome_genePred=config.get("ucsc_trackhub", {}).get(
            "genome_annotation_bb", rules.bgpinput_to_biggenepred.output[0]
        ),
        BigWig=select_bigwig,
    output:
        dir=directory(config["ucsc_trackhub"]["directory"]),
        trackdb=expand(
            os.path.join(config["ucsc_trackhub"]["directory"], "{org}", "trackDb.txt"),
            org=config["ucsc_trackhub"]["genomes"],
        ),
        hubtxt=os.path.join(
            config["ucsc_trackhub"]["directory"],
            config["ucsc_trackhub"]["hub_name"] + ".hub.txt",
        ),
        genomestxt=os.path.join(
            config["ucsc_trackhub"]["directory"],
            config["ucsc_trackhub"]["hub_name"] + ".genomes.txt",
        ),
    container:
        "docker://quay.io/biocontainers/trackhub:1.0--pyh7cba7a3_0"
    log:
        os.path.join(config["ucsc_trackhub"]["directory"], "trackhub.log"),
    script:
        "../scripts/trackhub.py"
