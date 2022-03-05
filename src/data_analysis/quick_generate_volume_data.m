training_data_file = "path\to\training_data.csv";
training_data = readtable( training_data_file );
stl_folder = "path\to\parts_stl";
cost_data = generate_volume_data( training_data, stl_folder );
writetable( cost_data, "path\to\volume_data.csv" );
