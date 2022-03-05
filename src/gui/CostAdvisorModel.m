classdef CostAdvisorModel < handle
    
    properties
        casting_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive} = 1
        core_volume(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative} = 0
    end
    
    properties ( Dependent )
        class(1,1) string
        grade(1,1) string
        material(1,1) string
        quantity_ordered(1,1) double
        box_dimensions(1,3) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_surface_area(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        shape_complexity(1,1) uint32 {...
            mustBeGreaterThanOrEqual(shape_complexity,1),...
            mustBeLessThanOrEqual(shape_complexity,5)...
            }
    end
    
    properties ( SetAccess = private, Dependent )
        classes(:,1) string
        grades(:,1) string
        materials(:,1) string
        shape_complexity_tags(:,1) double
        box_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_weight(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        density(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_envelope_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        check_fixture_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        straightening_fixture_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        tooling_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        ndt_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        processing_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        material_part_cost(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
    end
    
    methods
        function obj = CostAdvisorModel( file_path )
            e = actxserver( 'Excel.Application' );
            e.Visible = false;
            e.DisplayAlerts = false;
            e.ScreenUpdating = false;
            
            ca = e.Workbooks.Open( file_path );
            
            obj.active_x_server = e;
            obj.cost_advisor = ca;
        end
        
        function set.casting_volume( obj, value )
            value = obj.mm3_to_in3( value );
            obj.casting_volume = value;
            obj.update_casting_weight();
            obj.update_casting_envelope_volume();
        end
        
        function set.core_volume( obj, value )
            value = obj.mm3_to_in3( value );
            obj.core_volume = value;
            obj.update_casting_envelope_volume();
        end
        
        function set.class( obj, value )
            obj.set_input( obj.CLASS_RANGE, str2double( value ) );
        end
        
        function value = get.class( obj )
            value = obj.get_input( obj.CLASS_RANGE );
        end
        
        function set.grade( obj, value )
            obj.set_input( obj.GRADE_RANGE, char( value ) );
        end
        
        function value = get.grade( obj )
            value = obj.get_input( obj.GRADE_RANGE );
        end
        
        function set.material( obj, value )
            obj.set_input( obj.PART_MATERIAL_RANGE, char( value ) );
        end
        
        function value = get.material( obj )
            value = obj.get_input( obj.PART_MATERIAL_RANGE );
        end
        
        function set.quantity_ordered( obj, value )
            obj.set_input( obj.QUANTITY_ORDERED_RANGE, value );
        end
        
        function value = get.quantity_ordered( obj )
            value = obj.get_input( obj.QUANTITY_ORDERED_RANGE );
        end
        
        function set.box_dimensions( obj, value )
            value = obj.mm_to_in( value );
            % H < W < L
            value = sort( value, 'ascend' );
            obj.set_input( obj.BOX_HEIGHT_RANGE, value( 1 ) );
            obj.set_input( obj.BOX_WIDTH_RANGE, value( 2 ) );
            obj.set_input( obj.BOX_LENGTH_RANGE, value( 3 ) );
        end
        
        function value = get.box_dimensions( obj )
            value = [ ...
                obj.get_input( obj.BOX_HEIGHT_RANGE ) ...
                obj.get_input( obj.BOX_WIDTH_RANGE ) ...
                obj.get_input( obj.BOX_LENGTH_RANGE ) ...
                ];
            value = sort( value, 'ascend' );
        end
        
        function set.casting_surface_area( obj, value )
            value = obj.mm2_to_in2( value );
            obj.set_input( obj.SURFACE_AREA_RANGE, value );
        end
        
        function value = get.casting_surface_area( obj )
            value = obj.get_input( obj.SURFACE_AREA_RANGE );
        end
        
        function set.shape_complexity( obj, value )
            assert( isa( value, 'uint32' ) );
            assert( isscalar( value ) );
            assert( 1 <= value );
            assert( value <= 5 );
            
            obj.set_input( obj.SHAPE_COMPLEXITY_RANGE, value );
        end
        
        function value = get.shape_complexity( obj )
            value = obj.get_input( obj.SHAPE_COMPLEXITY_RANGE );
        end
        
        function value = get.classes( obj )
            value = obj.get_input_tags( obj.CLASS_RANGE );
            value = value( 2 : end );
            value = arrayfun( @(x)string(num2str(x)), value );
        end
        
        function value = get.grades( obj )
            value = obj.get_input_tags( obj.GRADE_RANGE );
            value = value( 2 : end );
        end
        
        function value = get.materials( obj )
            value = obj.get_input_tags( obj.PART_MATERIAL_RANGE );
        end
        
        function value = get.shape_complexity_tags( obj )
            value = str2double( obj.get_input_tags( obj.SHAPE_COMPLEXITY_RANGE ) );
        end
        
        function value = get.box_volume( obj )
            value = obj.get_input( obj.BOX_VOLUME_RANGE );
        end
        
        function value = get.casting_weight( obj )
            value = obj.get_input( obj.WEIGHT_RANGE );
        end
        
        function value = get.density( obj )
            original_weight = obj.get_input( obj.WEIGHT_RANGE );
            resetter = onCleanup( @()obj.set_input( obj.WEIGHT_RANGE, original_weight ) );
            
            TEMP_WEIGHT_LB = 1;
            obj.set_input( obj.WEIGHT_RANGE, TEMP_WEIGHT_LB );
            volume_in_cu = obj.get_input( obj.PART_VOLUME_RANGE );
            density_lb_per_in_cu = TEMP_WEIGHT_LB ./ volume_in_cu;
            value = density_lb_per_in_cu;
        end
        
        function value = get.casting_envelope_volume( obj )
            value = obj.get_input( obj.ENVELOPE_VOLUME_RANGE );
        end
        
        function value = get.check_fixture_part_cost( obj )
            value = obj.get_output( obj.CHECK_FIXTURE_COST_RANGE );
            value = value ./ obj.quantity_ordered;
        end
        
        function value = get.straightening_fixture_part_cost( obj )
            value = obj.get_output( obj.STRAIGHTENING_FIXTURE_COST_RANGE );
            value = value ./ obj.quantity_ordered;
        end
        
        function value = get.tooling_part_cost( obj )
            value = obj.get_output( obj.TOOLING_COST_RANGE );
            value = value ./ obj.quantity_ordered;
        end
        
        function value = get.ndt_part_cost( obj )
            value = obj.get_output( obj.NDT_COST_RANGE );
        end
        
        function value = get.processing_part_cost( obj )
            value = obj.get_output( obj.PROCESSING_COST_RANGE );
        end
        
        function value = get.material_part_cost( obj )
            value = obj.get_output( obj.MATERIAL_COST_RANGE );
        end
        
        function delete( obj )
            obj.cost_advisor.Close( false );
            obj.active_x_server.Quit();
            delete( obj.cost_advisor );
            %delete( obj.active_x_server );
        end
    end
    
    properties ( Access = private )
        active_x_server
        cost_advisor
    end
    
    properties ( Access = private )
        INPUT_SHEET_NAME = 'Part Info';
        OUTPUT_SHEET_NAME = 'Output';
    end
    
    methods ( Access = private )
        function update_casting_weight( obj )
            value = obj.casting_volume .* obj.density;
            obj.set_input( obj.WEIGHT_RANGE, value );
        end
        
        function update_casting_envelope_volume( obj )
            value = obj.casting_volume + obj.core_volume;
            obj.set_input( obj.ENVELOPE_VOLUME_RANGE, value );
        end
        
        function set_input( obj, range, value )
            sheet = obj.change_to_input_sheet();
            sheet.Range( range ).Value = value;
            obj.update();
        end
        
        function value = get_input( obj, range )
            sheet = obj.change_to_input_sheet();
            value = sheet.Range( range ).Value;
        end
        
        function value = get_output( obj, range )
            sheet = obj.change_to_output_sheet();
            value = sheet.Range( range ).Value;
        end
        
        function update( obj )
            obj.active_x_server.Calculate();
        end
        
        function tags = get_input_tags( obj, cell_range )
            contents = obj.get_data_validation_contents( ...
                obj.change_to_input_sheet(), ...
                cell_range ...
                );
            tags = string( obj.remove_invalid( contents ) );
        end
        
        function contents = get_data_validation_contents( ...
                obj, ...
                sheet, ...
                range_string ...
                )
            r = sheet.Range( range_string );
            res = obj.active_x_server.Evaluate( r.Validation.Formula1 );
            contents = res.Value;
        end
        
        function sheet = change_to_input_sheet( obj )
            sheet = obj.change_to_sheet( obj.INPUT_SHEET_NAME );
        end
        
        function sheet = change_to_output_sheet( obj )
            sheet = obj.change_to_sheet( obj.OUTPUT_SHEET_NAME );
        end
        
        function sheet = change_to_sheet( obj, name )
            sheets = obj.cost_advisor.Sheets;
            sheet = get( sheets, 'Item', name );
            invoke( sheet, 'Activate' );
            sheet = obj.active_x_server.Activesheet;
        end
    end
    
    properties ( Access = private, Constant )
        % order inputs
        CLASS_RANGE = 'D10';
        GRADE_RANGE = 'D9';
        PART_MATERIAL_RANGE = 'D8';
        QUANTITY_ORDERED_RANGE = 'D12';
        
        % geometry inputs
        BOX_HEIGHT_RANGE = 'D17';
        BOX_LENGTH_RANGE = 'D15';
        BOX_WIDTH_RANGE = 'D16';
        ENVELOPE_VOLUME_RANGE = 'D28';
        SHAPE_COMPLEXITY_RANGE = 'D25';
        SURFACE_AREA_RANGE = 'D21';
        WEIGHT_RANGE = 'D19';
        
        % check values
        BOX_VOLUME_RANGE = 'D33';
        PART_VOLUME_RANGE = 'D35';
        CORE_VOLUME_RANGE = 'D37';
        
        % cost outputs
        CHECK_FIXTURE_COST_RANGE = 'C17';
        MATERIAL_COST_RANGE = 'C5';
        NDT_COST_RANGE = 'C9';
        PROCESSING_COST_RANGE = 'C7';
        STRAIGHTENING_FIXTURE_COST_RANGE = 'C16';
        TOOLING_COST_RANGE = 'C13';
    end
    
    methods ( Access = private, Static )
        function contents = remove_invalid( contents )
            valid = cellfun( ...
                @(x)any( ~(isnan(x)|isempty(x)) ), ...
                contents ...
                );
            contents( ~valid ) = [];
        end
                
        function v = mm_to_in( v )
            v = v ./ 25.4;
        end
        
        function v = mm2_to_in2( v )
            v = v ./ ( 25.4 ^ 2 );
        end
        
        function v = mm3_to_in3( v )
            v = v ./ ( 25.4 ^ 3 );
        end
    end
    
end

