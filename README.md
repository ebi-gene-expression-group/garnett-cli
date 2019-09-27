# garnett-cli
Command line interface for the [Garnett](https://cole-trapnell-lab.github.io/garnett/) cell type classification tool. 
Graphical representation of the general workflow:


![](https://github.com/ebi-gene-expression-group/garnett-cli/blob/master/garnett_pipeline.png){:height="50%" width="50%"}

## Commands 
Currently available Garnett functions are listed in the following section. Each script has usage instructions available via --help, consult function documentation in Garnett for more dertail. 

### Import test data 
In order to test the tool, you will need to extract the CellDataSet (CDS) object holding example expression data in .rds format and the marker text file which are used as initial input to for the workflow. This is done via the following command:

``` 
garnett_import_test_data.R --cds-object <path to CDS object in .rds format>\
                           --marker-file <path to marker file in .txt format>
```

### Build CDS object input from raw expression matrix
If you are using raw experiment data, you can build a CDS object using the following script:

```
parse_expr_data.R --expression-matrix <numeric matrix with expression values in .mtx or .txt format>\
                  --phenotype-data <table of phenotype data in .txt format>\
                  --feature-data <table of gene features in .txt format>\
                  --output-file <path to output file in .rds format> 
```



