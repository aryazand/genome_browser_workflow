import trackhub
from snakemake.script import snakemake
import os

#################
# Initiate Hub
#################
hub = trackhub.Hub(
hub=snakemake.config["ucsc_trackhub"]["hub_name"],
short_label=snakemake.config["ucsc_trackhub"]["short_label"],
long_label=snakemake.config["ucsc_trackhub"]["long_label"],
email=snakemake.config["ucsc_trackhub"]["email"]
)

#########################################
# Add genomes for genome.txt file
#########################################

for assembly_name, assembly_data in snakemake.config["ucsc_trackhub"]["genomes"].items():

	genome = trackhub.Assembly(
		genome=assembly_name,
		twobit_file=os.path.abspath(snakemake.input.genome_2bit),
		organism=assembly_data["organism"],
		defaultPos=assembly_data["defaultPos"],
		scientificName=assembly_data["scientificName"],
		description=assembly_data["description"],
		html_string=assembly_data["description"],
		orderKey=4800
	)

	genomes_file = trackhub.GenomesFile()
	hub.add_genomes_file(genomes_file)

	# Add TrackDb 
	# we also need to create a trackDb and add it to the genome
	trackdb = trackhub.TrackDb()
	genome.add_trackdb(trackdb)

	# add the genome to the genomes file here:
	genomes_file.add_genome(genome)

	#######################
	# Add genome model to trackdb.txt
	#######################

	# Add genome model
	genome_model = trackhub.Track(
		name=assembly_data["annotation"]["track_name"],
		tracktype="bigGenePred",
		source=os.path.abspath(snakemake.input.genome_genePred),
		shortLabel=assembly_data["annotation"]["short_label"],
		longLabel=assembly_data["annotation"]["long_label"],
		visibility="pack",
	)

	trackdb.add_tracks(genome_model)

	#######################
	# Add BigBed file to trackdb.txt
	#######################

	# Loop through bigbed files in snakemake.input.BigBed and add to trackhub, if snakemake.input.BigBed is not empty
	if hasattr(snakemake.input, 'BigBed'):
		for bigbed in snakemake.input.BigBed:
			bigbed_basename=os.path.basename(bigbed)
			bigbed_name=os.path.splitext(bigbed_basename)[0]
				
			bigbed_track = trackhub.Track(
				name=bigbed_name,
				tracktype="bigBed",
				source=os.path.abspath(bigbed),
				shortLabel=bigbed_name,
				longLabel=bigbed_name,
				visibility="dense",
			)

		trackdb.add_tracks(bigbed_track)

	#######################
	# Add BigWig to trackdb.txt
	#######################

	# Loop through bigwig files in snakemake.input.bw and add to trackhub, if snakemake.input.bw is not empty

	print("snakemake.input.BigWig:", snakemake.input.BigWig)
	if hasattr(snakemake.input, 'BigWig'):
		for bw in snakemake.input.BigWig:
			bw_basename=os.path.basename(bw)
			bw_name=os.path.splitext(bw_basename)[0]

			bw_track = trackhub.Track(
				name=bw_name,
				tracktype="bigWig",
				source=os.path.abspath(bw),
				shortLabel=bw_name,
				longLabel=bw_name,
				visibility="full",
				autoScale="on",
				maxHeightPixels="100:50:8",
				color=snakemake.config["ucsc_trackhub"]["process_bw"]["plus_color"],
				altColor=snakemake.config["ucsc_trackhub"]["process_bw"]["minus_color"]
			)

			trackdb.add_tracks(bw_track)

	#######################
	# Add groups 
	#######################

	group_name=snakemake.config["ucsc_trackhub"]["group_name"]
	group_label=snakemake.config["ucsc_trackhub"]["group_label"]

	grouping = trackhub.groups.GroupDefinition(
		name=group_name,
		label=group_label,
		priority=1,
		default_is_closed=False)

	groups_file = trackhub.groups.GroupsFile([grouping])
	genome.add_groups(groups_file)

	# We can now add the "group" parameter to all the children of the trackDb
	for track in trackdb.children:
		track.add_params(group=group_name)


	#######################
	# Stage Trackhub 
	#######################

	trackhub.upload.stage_hub(hub, staging=snakemake.output.dir)