classdef PathController < handle
    
    % TODO rename AnalysisController
    methods ( Access = public )
        function obj = PathController( ...
                toolsuite_model, ...
                label, ...
                lamp, ...
                load_button, ...
                process_button, ...
                save_button ...
                )
            % TODO put component name in UI figure or in label
            % currently user has no way of knowing what model they are
            % interested in
            obj.toolsuite_model = toolsuite_model;
            obj.label = label;
            obj.lamp = lamp;
            obj.load_button = load_button;
            obj.process_button = process_button;
            obj.save_button = save_button;
            obj.set_state( obj.INITIAL_STATE );
            obj.update();
        end
        
        function load( obj )
            valid_states = [ ...
                obj.INITIAL_STATE ...
                obj.FAILED_LOAD_STATE ...
                obj.FAILED_PROCESS_STATE ...
                obj.FAILED_SAVE_STATE ...
                obj.LOADED_STATE ...
                obj.PROCESSED_STATE ...
                obj.SAVED_STATE ...
                ];
            assert( ismember( obj.state, valid_states ) );
            
            original_state = obj.state;
            filter = { [ '*' obj.SAVE_EXT ], 'Save file' };
            try
                [ file, path ] = uigetfile( ...
                    filter, ...
                    'Select a File to Load', ...
                    obj.previous_load_path ...
                    );
                if file ~= 0
                    input_file_path = fullfile( path, file );
                    obj.set_state( obj.LOADING_STATE );
                    obj.toolsuite_model.load( input_file_path );
                    obj.previous_load_path = input_file_path;
                    if isempty( obj.current_save_folder )
                        obj.current_save_folder = fileparts( input_file_path );
                    end
                    final_state = obj.LOADED_STATE;
                else
                    final_state = original_state;
                end
            catch e
                disp( getReport( e ) );
                obj.set_state( obj.FAILED_LOAD_STATE );
            end
            obj.set_state( final_state );
            obj.update();
        end
        
        function process( obj )
            valid_states = [ ...
                obj.INITIAL_STATE ...
                obj.FAILED_LOAD_STATE ...
                obj.FAILED_PROCESS_STATE ...
                obj.FAILED_SAVE_STATE ...
                obj.LOADED_STATE ...
                obj.PROCESSED_STATE ...
                obj.SAVED_STATE ...
                ];
            assert( ismember( obj.state, valid_states ) );
            
            original_state = obj.state;
            filter = { [ '*' obj.STL_EXT ], 'Stereolithograpy file' };
            try
                [ file, path ] = uigetfile( ...
                    filter, ...
                    'Select a File to Process', ...
                    obj.previous_process_path ...
                    );
                if file ~= 0
                    input_file_path = fullfile( path, file );
                    obj.set_state( obj.PROCESSING_STATE );
                    obj.toolsuite_model.process( input_file_path );
                    obj.previous_process_path = input_file_path;
                    if isempty( obj.current_save_folder )
                        obj.current_save_folder = fileparts( input_file_path );
                    end
                    final_state = obj.PROCESSED_STATE; 
                else
                    final_state = original_state;
                end
            catch e
                disp( getReport( e ) );
                final_state = obj.FAILED_PROCESS_STATE;
            end
            obj.set_state( final_state );
            obj.update();
        end
        
        function save( obj )
            valid_states = [ ...
                obj.INITIAL_STATE ...
                obj.FAILED_LOAD_STATE ...
                obj.FAILED_PROCESS_STATE ...
                obj.FAILED_SAVE_STATE ...
                obj.LOADED_STATE ...
                obj.PROCESSED_STATE ...
                obj.SAVED_STATE ...
                ];
            assert( ismember( obj.state, valid_states ) );
            
            original_state = obj.state;
            filter = { [ '*' obj.SAVE_EXT ], 'Stereolithograpy file' };
            filter_path = fullfile( ...
                obj.current_save_folder, ...
                obj.toolsuite_model.name + obj.SAVE_EXT ...
                );
            try
                [ file, path ] = uiputfile( ...
                    filter, ...
                    'Save As', ...
                    filter_path ...
                    );
                if file ~= 0
                    file_path = fullfile( path, file );
                    obj.set_state( obj.SAVING_STATE );
                    obj.toolsuite_model.save( file_path );
                    obj.current_save_folder = path;
                else
                    obj.set_state( original_state );
                end
            catch e
                disp( getReport( e ) );
                obj.set_state( obj.FAILED_SAVE_STATE );
            end
            obj.set_state( obj.SAVED_STATE );
            obj.update();
        end
    end
    
    properties ( Access = private )
        toolsuite_model
        label
        lamp
        load_button
        process_button
        save_button
        previous_load_path
        previous_process_path
        current_save_folder
        state
    end
    
    properties ( Access = private, Constant )
        SAVE_EXT = '.cap';
        STL_EXT = '.stl';
        INITIAL_STATE = 0;
        FAILED_LOAD_STATE = 1;
        FAILED_PROCESS_STATE = 2;
        FAILED_SAVE_STATE = 3;
        LOADED_STATE = 4;
        LOADING_STATE = 5;
        PROCESSED_STATE = 6;
        PROCESSING_STATE = 7;
        SAVED_STATE = 8;
        SAVING_STATE = 9;
    end
    
    methods ( Access = private )
        function set_state( obj, state )
            obj.state = state;
            obj.update();
        end
        
        function set_saveable( obj )
            obj.save_button.Enable = 'on';
            obj.update();
        end
        
        function update( obj )
            obj.update_label_text();
            obj.update_lamp_color();
            obj.update_load_button();
            obj.update_process_button();
            obj.update_save_button();
            drawnow();
        end
        
        function update_label_text( obj )
            map = obj.create_map( { ...
                'Please process or load a file to see results.' ...
                'Loading failed, please email err.log to authors.' ...
                'Processing failed, please email err.log to authors.' ...
                'Saving failed, please email err.log to authors.' ...
                'Loaded successfully!' ...
                'Loading...' ...
                'Processed successfully!' ...
                'Processing...' ...
                'Saved successfully!' ...
                'Saving...' ...
                } );
            obj.label.Text = map( obj.state );
        end
        
        function update_lamp_color( obj )
            BLACK = [ 0.1 0.1 0.1 ];
            GREEN = [ 0.0 0.6 0.5 ];
            SKY_BLUE = [ 0.35 0.7 0.9 ];
            VERMILLION = [ 0.8 0.4 0.0 ];
            map = obj.create_map( { ...
                BLACK ...
                VERMILLION ...
                VERMILLION ...
                VERMILLION ...
                GREEN ...
                SKY_BLUE ...
                GREEN ...
                SKY_BLUE ...
                GREEN ...
                SKY_BLUE ...
                } );
            obj.lamp.Color = map( obj.state );
        end
        
        function update_load_button( obj )
            map = obj.create_map( { ...
                true ...
                true ...
                true ...
                true ...
                true ...
                false ...
                true ...
                false ...
                true ...
                false ...
                } );
            obj.load_button.Enable = map( obj.state );
        end
        
        function update_process_button( obj )
            map = obj.create_map( { ...
                true ...
                true ...
                true ...
                true ...
                true ...
                false ...
                true ...
                false ...
                true ...
                false ...
                } );
            obj.process_button.Enable = map( obj.state );
        end
        
        function update_save_button( obj )
            if obj.toolsuite_model.ready
                map = obj.create_map( { ...
                    true ...
                    true ...
                    true ...
                    true ...
                    true ...
                    false ...
                    true ...
                    false ...
                    true ...
                    false ...
                    } );
                obj.save_button.Enable = map( obj.state );
            else
                obj.save_button.Enable = 'off';
            end
        end
    end
    
    methods ( Access = private, Static )
        function is = is_save_file( path )
            is = PathController.does_file_have_ext( ...
                path, ...
                PathController.SAVE_EXT ...
                );
        end
        
        function is = is_stl_file( path )
            is = PathController.does_file_have_ext( ...
                path, ...
                PathController.STL_EXT ...
                );
        end
        
        function has = does_file_have_ext( path, ext )
            [ ~, ~, path_ext ] = fileparts( path );
            has = strcmpi( path_ext, ext );
        end
        
        function map = create_map( values )
            keys = { ...
                PathController.INITIAL_STATE ...
                PathController.FAILED_LOAD_STATE ...
                PathController.FAILED_PROCESS_STATE ...
                PathController.FAILED_SAVE_STATE ...
                PathController.LOADED_STATE ...
                PathController.LOADING_STATE ...
                PathController.PROCESSED_STATE ...
                PathController.PROCESSING_STATE ...
                PathController.SAVED_STATE ...
                PathController.SAVING_STATE ...
                };
            map = containers.Map( keys, values );
        end
    end
    
end

