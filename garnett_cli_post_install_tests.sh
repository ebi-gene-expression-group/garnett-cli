#!/usr/bin/env bash

# this script creates necessary parameters and easy-to use variables for input paths and exports them into the 
# .bats testing script for the Garnett R package. Parameters defined here do not 
#  necessarily reflect a biologically sensible set up. 

script_name=$0
# Initialise directories
test_dir=`pwd`/test_dir
output_dir=$test_dir'/outputs'
mkdir -p $test_dir
mkdir -p $output_dir

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

# Main inputs for the workflow
export CDS=$test_dir'/test_cds.rds'
export marker_file=$test_dir'/test_marker_file.txt'

# Make raw test data from provided CDS object 
export expr_mat=$output_dir'/expression_matrix.mtx'
export pheno_data=$output_dir'/pheno_data.txt'
export feature_data=$output_dir'/feature_data.txt'

# Parse raw data back into CDS object 
#export CDS_rebuilt=$output_dir'/cds_rebuilt.rds'

# Check marker file 
export DB='org.Hs.eg.db'
export checked_markers=$output_dir'/markers_checked.txt'
export marker_plot=$output_dir'/marker_plot.png'

# Classifier training 
export trained_classifier=$output_dir'/trained_classifier.rds'

# Obtain feature genes 
export feature_genes=$output_dir'/feature_genes.txt'

# Classify cells 
# copy to allow classificaion several times
export CDS_copy=$output_dir'/test_cds_copy.rds' 
cp $CDS $CDS_copy 
export tsne_plot=$output_dir'/tsne_plot.png'
export tsne_plot_ext=$output_dir'/tsne_plot_ext.png'

# Workflow parameters 
export gene_id_type='SYMBOL'
export marker_gene_type='SYMBOL'
export n_outgroups=50
export node='root'
export convert_ids=true
export cluster_extend=true

################################################################################
# Test individual scripts
################################################################################

export use_existing_outputs
tests_file="${script_name%.*}".bats
# Execute the tests
$tests_file