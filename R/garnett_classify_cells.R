#!/usr/bin/env Rscript


# package management
suppressPackageStartupMessages(require(pacman))
# Load optparse we need to check inputs
suppressPackageStartupMessages(require(optparse))
# Load common functions
suppressPackageStartupMessages(require(workflowscriptscommon))


# Classify cells into cell types using a pre-trained classifier or one obtained
# via garnett_train_classifier.R 
# input:
#	- cds: object of CellDataSet class which holds gene expression data. 
#		   After classification is obtained, the column with classes is added to
#		   the pData of gene expression table. NB: running the script again on 
#		   the same CDS will cause an error. Delete the classification column to
#		   repeat classificaion.	 
#	- classifier: garnett_classifier class object obtained previously
#	- db: argument for Bioconductor AnnotationDb-class package used for
#		  converting gene IDs.
#	- cds_gene_id_type: the format of the gene IDs in your CDS object
#	- cluster_extend: boolean, tells Garnett whether to create a second set of 
#	  assignments that expands classifications to cells in the same cluster
#	- plot_output_path: output path for the t-SNE plots. In case
# 					    --cluster-extend is provided, two plots will be made. 
#					    If no path is provided, plots will not be produced


# parse options 
option_list = list(
	make_option(
		c("-i", "--cds-object"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "CDS object holding expression data. After classification is
    			 obtained, the column with classes is added to the pData of gene
    			 expression table. NB: running the script again on the same CDS
    			 will cause an error. Delete the classification column to 
    			 repeat classificaion."
	),
	make_option(
		c("-c", "--classifier-object"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "path to the object of class garnett_classifier, which is either
    	 		trained via garnett_train_classifier.R or obtained previously"
	),
	make_option(
		c("-d", "--database"),
		action = "store",
		default = NA,
    	type = 'character',
    	help = "argument for Bioconductor AnnotationDb-class package used for
    			converting gene IDs. For example, use org.Hs.eg.db for
    			Homo Sapiens genes."
	),
	make_option(
		c("--cds-gene-type"),
		action = "store",
		default = "ENSEMBL",
    	type = 'character',
    	help = "Format of the gene IDs in your CDS object. The default
    			is \"ENSEMBL\"."
	),
	make_option(
		c("-e", "--cluster-extend"),
		action = "store_true",
		default = FALSE, 
		help = "Boolean, tells Garnett whether to create a second set of
				assignments that expands classifications to cells in the same
				cluster. Default: FALSE"
	),
	make_option(
		c("-p", "--plot-output-path"),
		action = "store",
		default = NA,
		type = 'character',
		help = "output path for the t-SNE plots. In case --cluster-extend
				tag is provided, two plots will be made. If no path is provided,
				plots will not be produced."
	)
)

opt = wsc_parse_args(option_list, mandatory = c("cds_object",
												"classifier_object",
												"database"))
print(opt)

# check input is correct
if(! file.exists(opt$cds_object)){
	stop(paste("File ", opt$cds_object, "does not exist."))
}

if(! file.exists(opt$classifier_object)){
	stop(paste("File", opt$classifier_object, "does not exist."))
}

tryCatch({
	p_load(opt$database, character.only = TRUE)},
	warning = function(w){
		stop((paste('Database', opt$database,
					'was not found on Bioconductor')))}
)

# convert string into variable 
opt$database = get(opt$database)

# if input is OK, load the package
suppressPackageStartupMessages(require(garnett))

pbmc_cds = readRDS(opt$cds_object)
pbmc_classifier = readRDS(opt$classifier_object)

# run the function 
pbmc_cds = classify_cells(pbmc_cds, pbmc_classifier,
						  db = opt$database, 
						  cluster_extend = opt$cluster_extend, 
						  cds_gene_id_type = opt$cds_gene_type)	

saveRDS(pbmc_cds, file = opt$cds_object)

# if plot output is provided, do plotting step 
print(opt$plot_output_path)
if(! is.na(opt$plot_output_path)){
	p_load(ggplot2)
	png(file = opt$plot_output_path)
	print(qplot(tsne_1, tsne_2, color = cell_type,
				data = pData(pbmc_cds)) + theme_bw())
	print("plotting is happening")
	dev.off()
	if(opt$cluster_extend){
		path = paste(strsplit(opt$plot_output_path,
					 		  '.png')[[1]][1], "_ext.png", sep='')
		print(path) 
		png(file = path)
		print(qplot(tsne_1, tsne_2, color = cluster_ext_type, 
					data = pData(pbmc_cds)) + theme_bw())
		print("plotting is happening again")
		dev.off()
	}
}


