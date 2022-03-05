classdef GeometryController < handle
    
    properties ( Access = public, Constant )
        BOX_HEIGHT = 'box_height';
        BOX_LENGTH = 'box_length';
        BOX_VOLUME = 'box_volume';
        BOX_WIDTH = 'box_width';
        CORE_VOLUME = 'core_volume';
        FEEDER_COUNT = 'feeder_count';
        CASTING_SURFACE_AREA = 'casting_surface_area';
        CASTING_VOLUME = 'casting_volume';
        CASTING_WEIGHT = 'casting_weight';
    end
    
    methods
        function obj = GeometryController( ...
                cost_advisor_model, ...
                toolsuite_model, ...
                complexity_model, ...
                edit_fields ...
                )
            obj.cost_advisor_model = cost_advisor_model;
            obj.toolsuite_model = toolsuite_model;
            obj.complexity_model = complexity_model;
            obj.edit_fields = edit_fields;
        end
        
        function update( obj )
            if ~obj.toolsuite_model.ready
                return;
            end
            obj.update_box_dimensions();
            obj.update_casting_surface_area();
            obj.update_casting_volume();
            obj.update_core_volume();
            obj.update_feeder_count();
        end
    end
    
    properties ( Access = private )
        cost_advisor_model
        toolsuite_model
        complexity_model
        edit_fields
    end
    
    methods ( Access = private )
        function update_box_dimensions( obj )
            value = obj.toolsuite_model.box_dimensions;
            obj.cost_advisor_model.box_dimensions = value;
            value = obj.cost_advisor_model.box_dimensions;
            obj.set_field( obj.BOX_HEIGHT, value( 1 ) );
            obj.set_field( obj.BOX_WIDTH, value( 2 ) );
            obj.set_field( obj.BOX_LENGTH, value( 3 ) );
            obj.set_field( obj.BOX_VOLUME, obj.cost_advisor_model.box_volume );
        end
        
        function update_casting_volume( obj )
            value = obj.toolsuite_model.casting_volume;
            obj.cost_advisor_model.casting_volume = value;
            obj.set_field( obj.CASTING_VOLUME, obj.cost_advisor_model.casting_volume );
            obj.set_field( obj.CASTING_WEIGHT, obj.cost_advisor_model.casting_weight );
        end
        
        function update_core_volume( obj )
            value = obj.toolsuite_model.core_volume;
            obj.cost_advisor_model.core_volume = value;
            obj.set_field( obj.CORE_VOLUME, obj.cost_advisor_model.core_volume );
        end
        
        function update_feeder_count( obj )
            value = obj.toolsuite_model.feeder_count;
            obj.set_field( obj.FEEDER_COUNT, value );
        end
        
        function update_casting_surface_area( obj )
            value = obj.toolsuite_model.casting_surface_area;
            obj.cost_advisor_model.casting_surface_area = value;
            obj.set_field( obj.CASTING_SURFACE_AREA, obj.cost_advisor_model.casting_surface_area );
        end
        
        function set_field( obj, name, value )
            f = obj.edit_fields( name );
            f.Value = double( value );
        end
    end
    
end

