#!/usr/bin/env bats

@test "Obtain raw data from the package" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$expr_mat" ]; then
        skip "$expr_mat exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $expr_mat $pheno_data $feature_data\
        && make_test_data.R --marker-file $marker_file\
                              --expr-matrix $expr_mat\
                              --pheno-data $pheno_data\
                              --feature-data $feature_data\
                              --output-dir $test_10x_dir
    echo "status = ${status}"
    echo "output = ${output}"    
    [ "$status" -eq 0 ]
    [ -f "$marker_file" ]
    [ -f "$expr_mat" ]
    [ -f "$pheno_data" ]
    [ -f "$feature_data" ]
    [ -f "$test_10x_dir" ]
}

@test "Parse reference and query data into CDS objects " {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$ref_CDS" ]; then
        skip "$ref_CDS exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $ref_CDS && parse_expr_data.R --ref-10x-dir $test_10x_dir\
                                            --query-10x-dir $test_10x_dir\
                                            --ref-output-cds $ref_CDS\
                                            --query-output-cds $query_CDS
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $ref_CDS ]
    [ -f $query_CDS ]
}

@test "Check marker file" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$checked_markers" ] &&\
       [ -f "$marker_plot" ]; then
        skip "$checked_markers and $marker_plot exist and use_existing_outputs\
              is set to 'true'"
    fi
    run rm -f $checked_markers $marker_plot &&\
              garnett_check_markers.R -c $ref_CDS -m $marker_file\
                                           --cds-gene-id-type $gene_id_type\
                                           -d $DB -o $checked_markers\
                                           --plot-output-path $marker_plot

    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $checked_markers ]
    [ -f $marker_plot ]
}

@test "Classifier training " {
    if [ "$use_existing_outputs" = 'true' ] &&\
       [ -f "$trained_classifier" ]; then
        skip "$trained_classifier exists and use_existing_outputs\
              is set to 'true'"
    fi
    run rm -f $trained_classifier &&\
    garnett_train_classifier.R  -c $ref_CDS\
                                   -m $marker_file\
                                   --cds-gene-id-type $gene_id_type\
                                   --marker-file-gene-id-type $marker_gene_type\
                                   --classifier-gene-id-type $classifier_gene_type\
                                   -d $DB -n $n_outgroups\
                                   -o $trained_classifier
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $trained_classifier ]
}

@test "Obtain feature genes " {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$feature_genes" ]; then
        skip "$feature_genes exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $feature_genes && garnett_get_feature_genes.R\
                                        -c $trained_classifier -n $node -d $DB\
                                        -o $feature_genes\
                                        
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $feature_genes ]
}

@test "Classify cells" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$tsne_plot" ]; then
        skip "$tsne_plot exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $tsne_plot $tsne_plot_ext $cds_output_obj && garnett_classify_cells.R\
                                           --cds-object $query_CDS\
                                           --classifier-object $trained_classifier\
                                           -d $DB --cds-gene-id-type $gene_id_type\
                                           --cluster-extend -p $tsne_plot\
                                           --cds-output-obj $cds_output_obj
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $tsne_plot ]
    [ -f $tsne_plot_ext ]
    [ -f $cds_output_obj ]
}
