pm = train_model( which( "training_data.csv" ) );
out_folder = fileparts( mfilename( "fullpath" ) );
out_folder = fullfile( out_folder, "..", "..", "res" );
pm.save_obj( out_folder, "complexity_model.mat" );
