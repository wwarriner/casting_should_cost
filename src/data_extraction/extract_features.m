function extract_features( input_file, output_folder, settings_file )

input_file = string( input_file );
output_folder = string( output_folder );
settings_file = string( settings_file );

settings = Settings( settings_file );
settings.processes.Casting.input_file = input_file;
settings.manager.output_folder = output_folder;

try
    pm = ProcessManager( settings );
    pm.run();
    f = Features( pm );
catch e
    fprintf( 1, "%s" + newline, settings_file );
    fprintf( 1, "%s" + newline, getReport( e ) );
    return;
end

out_file = fullfile( settings.manager.output_folder, f.name + ".csv" );
f.write( out_file );

end

