function folder = get_executable_folder()

    [ status, result ] = system( "path" );
    success = status == 0;
    if ~success
        error( "Unable to locate root path. Please contact the author if you are not using a Windows operating system." + newline );
    end
    folder = string( regexpi( result, "Path=(.*?);", "tokens", "once" ) );
    
end

