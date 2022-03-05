csv_folder = "path\to\ict_results";
part_file = "path\to\parts.xlsx";
output_file = fullfile( fileparts( part_file ), "training_data.csv" );
merge_training_data( csv_folder, part_file, output_file );
