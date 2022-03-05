classdef SettingController < handle
    
    methods ( Access = public )
        function obj = SettingController( ...
                toolsuite_model, ...
                mesh_elements_edit_field, ...
                thermal_profile_check_box ...
                )
            obj.toolsuite_model = toolsuite_model;
            obj.mesh_elements_edit_field = mesh_elements_edit_field;
            obj.thermal_profile_check_box = thermal_profile_check_box;
            obj.pull();
        end
        
        function update( obj )
            obj.toolsuite_model.set_setting( ...
                obj.toolsuite_model.MESH_ELEMENTS, ...
                obj.mesh_elements_edit_field.Value ...
                );
            obj.toolsuite_model.set_setting( ...
                obj.toolsuite_model.USE_THERMAL_PROFILE, ...
                obj.thermal_profile_check_box.Value ...
                );
        end
        
        function pull( obj )
            obj.mesh_elements_edit_field.Value = ...
                obj.toolsuite_model.get_setting( obj.toolsuite_model.MESH_ELEMENTS );
            obj.thermal_profile_check_box.Value = ...
                obj.toolsuite_model.get_setting( obj.toolsuite_model.USE_THERMAL_PROFILE );
        end
        
        function value = to_table( obj )
            value = table( ...
                obj.toolsuite_model.get_setting( obj.toolsuite_model.MESH_ELEMENTS ), ...
                obj.toolsuite_model.get_setting( obj.toolsuite_model.USE_THERMAL_PROFILE ), ...
                'variablenames', ...
                cellstr( [ "mesh_elements" ...
                "use_thermal_profile" ] ) ...
                );
        end
    end
    
    properties ( Access = private )
        toolsuite_model
        mesh_elements_edit_field
        thermal_profile_check_box
    end
    
end

