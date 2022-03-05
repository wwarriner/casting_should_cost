function pm = train_model( file )

td = TrainingData( file );
td.excluded_variable_names = "name";
td.class_variable_name = "class";

% TESTING FOR ALTERNATE CLASSIFICATIONS
% predictors( response == 3, : ) = [];
% response( response == 3 ) = [];
% 
% classes = [ 1 2 ];
% response( ismember( response, [ 1 2 ] ) ) = 1;
% %response( ismember( response, [ 2 3 ] ) ) = 2;
% response( ismember( response, [ 3 4 5 ] ) ) = 2;

ec = EnsembleClassifier( td );
ec.generate();
ec.plot_roc();
ec.plot_confusion();

er = EnsembleRegressor( td );
er.generate();
er.plot_errors();

pm = PredictionModel( ec, er );

end
