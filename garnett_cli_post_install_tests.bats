#!/usr/bin/env bats

@test "Parse data into CDS object" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$garnett_CDS" ]; then
        skip "$garnett_CDS exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $garnett_CDS && monocle3 create $garnett_CDS\
                                  --expression-matrix $test_10x_dir/'matrix.mtx'\
                                  --cell-metadata $test_10x_dir/'barcodes.tsv'\
                                  --gene-annotation $test_10x_dir/'genes.tsv'

    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $garnett_CDS ]
}


@test "Transform markers file into Garnett-compatible format" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$transformed_markers" ]; then
          skip "$transformed_markers exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $transformed_markers && transform_marker_file.R\
                                            --input-marker-file $marker_file\
                                            --marker-list $marker_list\
                                            --pval-col $pval_col\
                                            --garnett-marker-file $transformed_markers

    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $transformed_markers ]
}


@test "Check marker file" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$marker_check" ] &&\
       [ -f "$marker_plot" ]; then
        skip "$marker_check and $marker_plot exist and use_existing_outputs\
              is set to 'true'"
    fi
    run rm -f $marker_check $marker_plot &&\
              garnett_check_markers.R -c $garnett_CDS -m $transformed_markers\
                                           --cds-gene-id-type $gene_id_type\
                                           --marker-file-gene-id-type $marker_gene_type\
                                           -d $DB -o $marker_check\
                                           --plot-output-path $marker_plot

    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $marker_check ]
    [ -f $marker_plot ]
}

@test "Update markers" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$updated_markers" ]; then
       skip "$updated_markers exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $updated_markers && update_marker_file.R\
                                        --marker-list-obj $marker_list\
                                        --marker-check-file $marker_check\
                                        --updated-marker-file $updated_markers

    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $updated_markers ]
}

@test "Classifier training " {
    if [ "$use_existing_outputs" = 'true' ] &&\
       [ -f "$trained_classifier" ]; then
        skip "$trained_classifier exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $trained_classifier &&\
    garnett_train_classifier.R  -c $garnett_CDS\
                                   -m $updated_markers\
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
    skip # skip because of internal bug in Garnett, remove when it's resolved
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
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$cds_output_obj" ]; then
        skip "$tsne_plot exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $cds_output_obj && garnett_classify_cells.R\
                                           --cds-object $garnett_CDS\
                                           --classifier-object $trained_classifier\
                                           -d $DB --cds-gene-id-type $gene_id_type\
                                           --cds-output-obj $cds_output_obj
    echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $cds_output_obj ]
}

@test "Get standard output" {
  if [ "$use_existing_outputs" = 'true' ] && [ -f "$garnett_output_tbl" ]; then
        skip "$garnett_output_tbl exists and use_existing_outputs is set to 'true'"
  fi

  run rm -f $garnett_output_tbl && garnett_get_std_output.R\
                                        --input-object $cds_output_obj\
                                        --output-file-path $garnett_output_tbl
  
  echo "status = ${status}"
  echo "output = ${output}"
  [ "$status" -eq 0 ]
  [ -f $garnett_output_tbl ]
}



