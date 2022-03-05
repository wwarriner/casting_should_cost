function merge_training_data( csv_folder, part_file, output_file )

contents = get_feature_contents( csv_folder );
feature_data = merge_feature_contents( contents );

part_data = readtable( part_file );
part_data = part_data( :, [ "file_name" "complexity_classification" ] );
part_data.Properties.VariableNames{ 'file_name' } = 'name';
part_data.Properties.VariableNames{ 'complexity_classification' } = 'class';

data = join( feature_data, part_data, ...
    "leftkeys", "name", ...
    "rightkeys", "name" ...
    );
data = movevars( data, "class", "after", size( data, 2 ) );
data = movevars( data, "name", "before", 1 );
writetable( data, output_file );

end


function contents = get_feature_contents( csv_folder )

contents = get_contents( csv_folder );
contents = get_files_with_extension( contents, ".csv" );

end


function data = merge_feature_contents( contents )

data = initialize_table( contents );
for i = 1 : size( contents, 1 )
    entry = contents( i, : );
    path = fullfile( entry.folder{1}, entry.name{1} );
    features = readtable( path ); % replace with readmatrix R2019a
    data( i, : ) = features( 1, : );
end

names = string( [ contents.name ] );
[ ~, names ] = arrayfun( @(x)fileparts(x), names );
names = table( cellstr( names ), 'variablenames', { 'name' } );
data = [ names data ];

end


function data = initialize_table( listing )

assert( ~isempty( listing ) );

first = listing( 1, : );
contents = readtable( fullfile( first.folder{1}, first.name{1} ) );

% construct empty table
data = contents;
count = numel( listing );
data( count, : ) = contents( 1, : );
data( :, : ) = [];

end
