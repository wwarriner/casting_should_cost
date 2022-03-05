cost_advisor_file = "path\to\cost_advisor.xlsx";
training_data_file = "path\to\training_data.csv";
training_data = readtable( training_data_file );
stl_folder = "path\to\parts_stl";
cost_data = generate_cost_data( cost_advisor_file, training_data, stl_folder );
writetable( cost_data, "path\to\cost_data.csv" );
