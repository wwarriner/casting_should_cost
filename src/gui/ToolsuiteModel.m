classdef ToolsuiteModel < handle
    % TODO feature extraction should be done somewhere else perhaps, refactor?
    
    properties ( Constant )
        INPUT_FILE_PATH = 'processes.Casting.input_file';
        MESH_ELEMENTS = 'processes.Mesh.desired_element_count';
        USE_THERMAL_PROFILE = 'processes.IsolatedSections.use_thermal_profile';
    end
    
    properties ( SetAccess = private, Dependent )
        ready(1,1) logical
        name(1,1) string
        summary table
        features(1,:) double {mustBeReal,mustBeFinite}
        box_dimensions(1,3) double {mustBeReal,mustBeFinite,mustBePositive}
        core_volume(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        feeder_count(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        casting_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_surface_area(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
    end
    
    methods
        function obj = ToolsuiteModel( ...
                resource_folder_path, ...
                settings_file_path ...
                )
            assert( isfolder( resource_folder_path ) );
            assert( isfile( settings_file_path ) );
            
            obj.resource_folder_path = resource_folder_path;
            obj.settings = SettingsFile( settings_file_path );
        end
        
        function value = get_setting( obj, key )
            value = obj.settings.(key);
        end
        
        function set_setting( obj, key, value )
            obj.settings.(key) = value;
        end
        
        function load( obj, features_file )
            loaded = load( features_file, '-mat', 'features_data' );
            obj.features_model = loaded.features_data;
        end
        
        function process( obj, casting_file )
            obj.set_setting( ...
                obj.INPUT_FILE_PATH, ...
                casting_file ...
                );
            pm = ProcessManager( obj.settings );
            pm.run();
            obj.features_model = Features( pm );
        end
        
        function save( obj, save_file_path )
            features_data = obj.features_model;
            save( save_file_path, 'features_data' );
        end
        
        function value = get.ready( obj )
            value = ~isempty( obj.features_model );
        end
        
        function value = get.name( obj )
            assert( obj.ready );
            value = obj.features_model.name;
        end
        
        function value = get.summary( obj )
            assert( obj.ready );
            value = obj.features_model.summary;
        end
        
        function value = get.features( obj )
            assert( obj.ready );
            value = obj.features_model.features;
        end
        
        function value = get.box_dimensions( obj )
            assert( obj.ready );
            value = obj.features_model.box_dimensions;
            value = sort( value, 'ascend' );
        end
        
        function value = get.core_volume( obj )
            assert( obj.ready );
            value = obj.features_model.core_volume;
        end
        
        function value = get.feeder_count( obj )
            assert( obj.ready );
            value = obj.features_model.feeder_count;
        end
        
        function value = get.casting_volume( obj )
            assert( obj.ready );
            value = obj.features_model.casting_volume;
        end
        
        function value = get.casting_surface_area( obj )
            assert( obj.ready );
            value = obj.features_model.casting_surface_area;
        end
    end
    
    properties ( Access = private )
        resource_folder_path
        settings
        features_model
    end
    
end

