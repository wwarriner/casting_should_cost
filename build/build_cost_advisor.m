function build_cost_advisor()
%% MODIFY PATH
old_path = path();
path_restorer = onCleanup(@()path(old_path));
restoredefaultpath();

%% EXTEND SEARCH PATH WITH APP SOURCE FOLDER
build_folder = fileparts( mfilename( "fullpath" ) );
root_folder = fullfile( build_folder, ".." );
addpath( root_folder );
extend_search_path();

%% CREATE OUTPUT FOLDER
out_folder = fullfile( root_folder, "out" );
assert( out_folder ~= build_folder );
assert( out_folder ~= root_folder );
prepare_folder( out_folder );

%% CREATE TARGET FOLDER
target_folder = fullfile( root_folder, "target" );
assert( target_folder ~= build_folder );
assert( target_folder ~= root_folder );
prepare_folder( target_folder );

%% MANAGE DEPENDENCIES
cgt_folder = fullfile( root_folder, "..", "casting_geometric_toolsuite" );
addpath( cgt_folder );
extender_file = fullfile( cgt_folder, "extend_search_path()" );
run( extender_file );
build_casting_geometric_toolsuite( out_folder );
run( extender_file );

%% COMPILE APP INTO TARGET FOLDER
app_name = "CostAdvisorPlus";
app_file = "cost_advisor_plus.mlapp";
target = "compile:exe";
mcc( ...
    "-T", target, ...
    "-e", ...
    "-d", target_folder, ...
    "-o", app_name, ...
    app_file ...
    );
copyfile( fullfile( target_folder, app_name + ".exe" ), out_folder );

%% COPY RESOURCES TO OUTPUT FOLDER
res_folder = fullfile( root_folder, "res" );
out_res_folder = fullfile( out_folder, "res" );
copyfile( res_folder, out_res_folder );

%% ZIP OUTPUT FOLDER
zip_file = fullfile( out_folder, app_name + ".zip" );
zip( zip_file, out_folder );

end