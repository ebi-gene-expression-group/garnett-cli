#!/usr/bin/env bash

# this script creates necessary parameters and easy-to use variables for input paths and exports them into the 
# .bats testing script for the Garnett R package. Parameters defined here do not 
#  necessarily reflect a biologically sensible set up. 

script_name=$0
# Initialise directories
test_dir=`pwd`/post_install_tests
data_dir=$test_dir/'data'
output_dir=$test_dir'/outputs'
mkdir -p $test_dir
mkdir -p $output_dir

# update path variable
export PATH=`pwd`:$PATH

function usage {
    echo "usage: garnett_cli_post_install_tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] &&\
   [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

# Clean up if specified
if [ "$action" = 'clean' ]; then
    echo "Cleaning up $output_dir ..."
    rm -rf $output_dir

    exit 0
fi 

################################################################################
# List tool outputs/ inputs
################################################################################
export marker_file=$data_dir'/ref_marker_genes.txt'
export test_10x_dir=$data_dir'/10x_data'

export train_id='E-ENAD-16'
export transformed_markers=$output_dir'/markers_transformed.txt'
export marker_list=$output_dir'/marker_list.rds'
export garnett_CDS=$output_dir'/garnett_cds.rds' 

# Check marker file 
export DB='org.Hs.eg.db'
export marker_check=$output_dir'/marker_check.txt'
export updated_markers=$output_dir'/markers_upd.txt'
export marker_plot=$output_dir'/marker_plot.png'

# Classifier training 
export trained_classifier=$output_dir'/trained_classifier.rds'

# Obtain feature genes 
export feature_genes=$output_dir'/feature_genes.txt'

# Classify cells 
export tsne_plot=$output_dir'/tsne_plot.png'
export tsne_plot_ext=$output_dir'/tsne_plot_ext.png'
export cds_output_obj=$output_dir'/cds_pred_labs.rds'
export garnett_output_tbl=$output_dir'/garnett_output_tbl.txt'

# Workflow parameters
export pval_col='pvals' 
export gene_id_type='ENSEMBL'
export marker_gene_type='ENSEMBL'
export classifier_gene_type='ENSEMBL'
export n_outgroups=50
export node='root'
export convert_ids=true
export cluster_extend=true

################################################################################
# Fetch test data
################################################################################
wget "https://www.ebi.ac.uk/~a_solovyev/garnett_cli_test_data.tar.gz" -P $test_dir
tar -xzvf $test_dir/'garnett_cli_test_data.tar.gz' -C $test_dir  

################################################################################
# Test individual scripts
################################################################################

export use_existing_outputs
tests_file="${script_name%.*}".bats
# Execute tests
$tests_file

