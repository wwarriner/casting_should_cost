function volume_data = generate_volume_data( training_data, stl_folder )

row_count = height( training_data );
volume_data = {};
parfor i = 1 : row_count
    row = training_data( i, : );
    casting = read_casting( row, stl_folder );
    volume_data = [ volume_data; { casting.name casting.volume } ]; %#ok<AGROW>
    fprintf( "%i/%i\n", i, row_count );
end
volume_data = cell2table( volume_data );
volume_data.Properties.VariableNames = { ...
    'name' ...
    'volume' ...
    };

end


function c = read_casting( row, stl_folder )

name = string( row.name{1} );
file = fullfile( stl_folder, name + ".stl" );

c = Casting();
c.input_file = file;
c.run();

end

