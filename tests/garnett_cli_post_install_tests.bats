#!/usr/bin/env bats

@test "Make raw test data from provided CDS object" {
	if [ "$use_existing_outputs" = 'true' ] && [ -f "$expr_mat" ]; then
		skip "$expr_mat exists and use_existing_outputs is set to 'true'"
	fi
	run rm -f $expr_mat $pheno_data $feature_data\
		&& ../R/make_test_data.R --input-file $CDS\
								 --expr-matrix $expr_mat\
								 --pheno-data $pheno_data\
								 --feature-data $feature_data
	echo "status = ${status}"
    echo "output = ${output}"
 
    [ "$status" -eq 0 ]
    [ -f  "$expr_mat" ]
    [ -f  "$pheno_data" ]
    [ -f  "$feature_data" ]
}

@test "Parse raw data back into CDS object " {
	if [ "$use_existing_outputs" = 'true' ] && [ -f "$CDS_rebuilt" ]; then
		skip "$CDS_rebuilt exists and use_existing_outputs is set to 'true'"
	fi
	run rm -f $CDS_rebuilt && ../R/parse_expr_data.R -e $expr_mat\
													 -p $pheno_data\
													 -f $feature_data\
													 -o $CDS_rebuilt
	echo "status = ${status}"
    echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $CDS_rebuilt ]
}

@test "Check marker file" {
	if [ "$use_existing_outputs" = 'true' ] && [ -f "$checked_markers" ] &&\
	   [ -f "$marker_plot" ]; then
		skip "$checked_markers and $marker_plot exist and use_existing_outputs\
			  is set to 'true'"
	fi
	run rm -f $checked_markers $marker_plot &&\
	 		  ../R/garnett_check_markers.R -c $CDS -m $marker_file\
	 		  							   -d $DB -o $checked_markers\
	 		  							   --plot-output-file $marker_plot

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
	 ../R/garnett_train_classifier.R  -c $CDS\
	 								  -m $marker_file\
	 								  --cds-gene-type $gene_id_type\
	 								  --marker-gene-type $marker_gene_type\
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
	run rm -f $feature_genes && ../R/garnett_get_feature_genes.R\
										-c $primary_classifier -n $node -d $DB\
										-o $feature_genes\
										--convert-ids $convert_ids
	echo "status = ${status}"
	echo "output = ${output}"
	[ "$status" -eq 0 ]
	[ -f $feature_genes ]
}

@test "Classify cells" {
	if [ "$use_existing_outputs" = 'true' ] && [ -f "$tsne_plot" ]; then
		skip "$tsne_plot exists and use_existing_outputs is set to 'true'"
	fi

	run rm -f $tsne_plot $tsne_plot_ext && ../R/garnett_classify_cells.R\
										   -i $CDS_copy -c $trained_classifier\
										   -d $DB --cds-gene-type $gene_id_type\
										   --cluster-extend -p $tsne_plot
	echo "status = ${status}"
	echo "output = ${output}"
    [ "$status" -eq 0 ]
    [ -f $tsne_plot ]
    [ -f $tsne_plot_ext ]
}













