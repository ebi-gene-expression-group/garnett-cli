# garnett-cli
Command line interface for the [Garnett](https://cole-trapnell-lab.github.io/garnett/) cell type classification tool. You can build cell type classification model using single-cell RNA-seq data and expressed marker genes. Alternatively, you can use pre-trained classifiers to determine cell types in your data.

Note: Nextflow implementation of Garnett pipeline is also available [here](https://github.com/ebi-gene-expression-group/garnett-workflow/tree/master).    

Graphical representation of the general workflow:

![](https://github.com/ebi-gene-expression-group/garnett-cli/blob/master/garnett_pipeline.png)

## Installation 
Garnett-cli is installed through Conda. [Miniconda](https://docs.conda.io/en/latest/miniconda.html) is a good way of getting set up with a basic Conda installation.

It will help if you have your Conda set up to use channels as per Bioconda:
```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge 
```

We recommend you use a fresh environment to install the package: 

```
conda create --name <garnett-env>
conda activate <garnett-env>
conda install -c bioconda garnett-cli 
```

## Testing
To test Garnett-cli installation, run ```garnett-cli-post-install-tests.sh 'test' 'false' ```

## Commands 
Currently available Garnett functions are listed in the following section. Each script has usage instructions available via --help, consult function documentation in Garnett for more dertail. 

### parse_expr_data(): Build CDS object input from raw expression matrix
If you are using raw experiment data, you can build a CDS object using the following script:

```
parse_expr_data.R --input-10x-dir <10x-style expression data directory>\
                  --output-cds <output file path for query CDS object in .rds format> 
```

Please refer [here](http://cole-trapnell-lab.github.io/monocle-release/docs/#the-celldataset-class) for description of the file structure.

### transform_marker_file(): Transform SCXA-style marker file into Garnett-compatible one
Garnett has an author-defined marker file format. To work with marker files stored in SCXA ([example](ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/sc_experiments/E-ENAD-14/E-ENAD-14.marker_genes_18.tsv)), they need to be transformed in a specific way. Marker genes are filtered to leave only those with adjusted p-value below specified threshold.

```
transform_marker_file.R --input-marker-file <path to SCXA type marker file>\
                        --marker-list <path to serialised object containing marker genes per cell type>\
                        --garnett-marker-file <path to the output file in Garnett-compatible format>
```

### garnett_check_markers(): Check marker file 
In order to verify that markers provide an accurate representation of corresponding cell types, run the following script:

```
garnett_check_markers.R --cds-object <path to CDS object in .rds format>\
                        --marker-file-path <path to marker file in .txt format>\
                        --database <name of gene database (e.g. org.Hs.eg.db for Homo Sapiens genes)>\
                        --cds-gene-id-type <Format of the gene IDs in your CDS object>\
                        --marker-file-gene-id-type <Format of the gene IDs in your marker file>\
                        --marker-output-path <output path for marker analysis file in .txt format>\
                        --plot-output-path <output path for the plot in .png format>
```
_NB_: before specifying the database, make sure you have it installed as package in your environment. For example, you can use [conda](https://anaconda.org/bioconda/bioconductor-org.hs.eg.db) or [bioconductor](https://bioconductor.org/packages/release/data/annotation/html/org.Hs.eg.db.html) to install org.Hs.eg.db.
 
If the flag ` --plot-output-path` is used, graphical representation of marker quality will be produced automatically. 

### update_marker_file(): Remove suboptimal markers
After the marker checking step, to avoid manual inspection of the reults, this scrip removes markers deemed suboptimal by Garnett. 

```
update_marker_file.R --marker-list-obj <path to serialised object containing marker genes per cell type>\
                     --marker-check-file <path to marker analysis file in .txt format>\
                     --updated-marker-file <path to updated marker gene file in .txt format>
```

### garnett_train_classifier(): Train the classifier 
Although a range of [pre-trained classifiers](https://cole-trapnell-lab.github.io/garnett/classifiers/) are available for usage, you can train your own via the following command: 

```
garnett_train_classifier.R --cds-object <path to CDS object in .rds format>\
                           --marker-file-path <path to marker file in .txt format>\
                           --database <name of gene database (e.g. org.Hs.eg.db for Homo Sapiens genes)>\
                           --output-path <output path for the trained classifier in .rds format>
```

### garnett_get_feature_genes(): Get genes used as features in the classification model
In some cases, it might be of interest to investigate which genes are deemed important by the classification model and thus used as features for classification.

```
garnett_get_feature_genes.R --classifier-object <path to a classifier object 
                            (pre-trained or trained _de novo_) in .rds format>\
                             --database <name of gene database (e.g. org.Hs.eg.db for Homo Sapiens genes)>\
                             --output-path <path to output file in .txt format>
```

### garnett_classify_cells(): Classify cell types 
```
garnett_classify_cells.R --cds-object <path to CDS object in .rds format>
                         --classifier-object <path to a classifier object 
                            (pre-trained or trained _de novo_) in .rds format>
                         --database <name of gene database (e.g. org.Hs.eg.db for Homo Sapiens genes)>
```
Classification column will be added to the CDS object's metadata as an additional column. **Note**: to repeat classification on the same CDS object you will need first to delete the column with previous classification result. 

### make_test_data(): Obtain test data
In case you would like to extract raw data for the test CDS object and example marker file, run: 
```
make_test_data.R --marker-file <output path for marker file in .txt format>\
                 --expr-matrix <output path for extracted expression matrix in .txt format>\
                 --pheno-data <output path for phenotype data in .txt format>
                 --feature-data <output path for gene features in .txt format>
```
