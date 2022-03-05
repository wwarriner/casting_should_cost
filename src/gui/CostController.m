classdef CostController < handle
    
    properties ( Access = public, Constant )
        GRAND_TOTAL = 'grand_total';
        PART_SUBTOTAL = 'part';
        MATERIAL = 'material';
        PROCESSING = 'processing';
        NDT = 'ndt';
        TOOLING = 'tooling';
        FIXTURING_SUBTOTAL = 'fixturing';
        STRAIGHTENING = 'straightening';
        CHECK = 'check';
    end
    
    methods ( Access = public )
        function obj = CostController( ...
                cost_advisor_model, ...
                complexity_model, ...
                toolsuite_model, ...
                per_part_edit_fields, ...
                per_order_edit_fields, ...
                grand_total_part_range_edit_fields, ...
                grand_total_order_range_edit_fields ...
                )
            obj.cost_advisor_model = cost_advisor_model;
            obj.complexity_model = complexity_model;
            obj.toolsuite_model = toolsuite_model;
            obj.per_part_edit_fields = per_part_edit_fields;
            obj.per_order_edit_fields = per_order_edit_fields;
            obj.grand_total_part_range_edit_fields = grand_total_part_range_edit_fields;
            obj.grand_total_order_range_edit_fields = grand_total_order_range_edit_fields;
            obj.update();
        end
        
        function update( obj )
            if ~obj.toolsuite_model.ready
                return;
            end
            base_complexity = obj.update_shape_complexity();
            complexities = obj.cost_advisor_model.shape_complexity_tags;
            count = numel( complexities );
            costs = nan( count, 1 );
            
            for i = 1 : count
                complexity = complexities( i );
                obj.set_shape_complexity( complexity );
                per_part_costs = obj.get_per_part_costs();
                costs( i ) = sum( per_part_costs );
                if complexity == base_complexity
                    base_per_part_costs = per_part_costs;
                end
            end
            
            obj.update_part_cost();
            obj.update_tooling_cost();
            obj.update_fixture_cost();
            
            grand_total_part = sum( base_per_part_costs );
            quantity = obj.get_quantity_ordered();
            grand_total_order = grand_total_part .* quantity;
            obj.set_per_part( obj.GRAND_TOTAL, grand_total_part );
            obj.set_per_order( obj.GRAND_TOTAL, grand_total_order );
            
            cost_range_part = obj.complexity_model.compute_cost_range( costs );
            cost_range_part = cost_range_part - grand_total_part;
            obj.set_per_part_grand_total_range( cost_range_part );
            
            cost_range_order = obj.complexity_model.compute_cost_range( costs .* quantity );
            cost_range_order = cost_range_order - grand_total_order;
            obj.set_per_order_grand_total_range( cost_range_order );
            
            obj.previous_costs = base_per_part_costs;
            obj.set_shape_complexity( base_complexity );
        end
        
        function value = to_table( obj )
            [ ppc, titles ] = obj.get_per_part_costs();
            ppc = num2cell( ppc );
            value = table( ...
                ppc{ : }, ...
                'variablenames', ...
                cellstr( titles ) ...
                );
        end
    end
    
    properties ( Access = private )
        cost_advisor_model
        complexity_model
        toolsuite_model
        per_part_edit_fields
        per_order_edit_fields
        grand_total_part_range_edit_fields
        grand_total_order_range_edit_fields
        previous_costs
    end
    
    methods ( Access = private )
        function complexity = update_shape_complexity( obj )
            features = obj.toolsuite_model.features;
            complexity = obj.complexity_model.predict_complexity( features );
            obj.set_shape_complexity( complexity );
        end
        
        function set_shape_complexity( obj, complexity )
            allowed_tags = obj.cost_advisor_model.shape_complexity_tags;
            assert( ismember( complexity, allowed_tags ) );
            obj.cost_advisor_model.shape_complexity = complexity;
        end
        
        function subtotal_part = update_part_cost( obj )
            quantity = obj.get_quantity_ordered();
            
            material = obj.get_material_part_cost();
            obj.set_per_part( obj.MATERIAL, material );
            obj.set_per_order( obj.MATERIAL, material .* quantity );
            
            processing = obj.get_processing_part_cost();
            obj.set_per_part( obj.PROCESSING, processing );
            obj.set_per_order( obj.PROCESSING, processing .* quantity );
            
            ndt = obj.get_ndt_part_cost();
            obj.set_per_part( obj.NDT, ndt );
            obj.set_per_order( obj.NDT, ndt .* quantity );
            
            costs_per_part = [ ...
                material ...
                processing ...
                ndt ...
                ];
            
            subtotal_part = sum( costs_per_part );
            obj.set_per_part( obj.PART_SUBTOTAL, subtotal_part );
            obj.set_per_order( obj.PART_SUBTOTAL, subtotal_part .* quantity );
        end
        
        function subtotal_part = update_tooling_cost( obj )
            quantity = obj.get_quantity_ordered();
            tooling = obj.get_tooling_part_cost();
            obj.set_per_part( obj.TOOLING, tooling );
            obj.set_per_order( obj.TOOLING, tooling .* quantity );
            subtotal_part = tooling;
        end
        
        function subtotal_part = update_fixture_cost( obj )
            quantity = obj.get_quantity_ordered();
            
            straight = obj.get_straightening_fixture_part_cost();
            obj.set_per_part( obj.STRAIGHTENING, straight );
            obj.set_per_order( obj.STRAIGHTENING, straight .* quantity );
            
            check = obj.get_check_fixture_part_cost();
            obj.set_per_part( obj.CHECK, check );
            obj.set_per_order( obj.CHECK, check .* quantity );
            
            costs_per_part = [ straight check ];
            subtotal_part = sum( costs_per_part );
            obj.set_per_part( obj.FIXTURING_SUBTOTAL, subtotal_part );
            obj.set_per_order( obj.FIXTURING_SUBTOTAL, subtotal_part .* quantity );
        end
        
        function [ value, titles ] = get_per_part_costs( obj )
            value = [ ...
                obj.get_material_part_cost() ...
                obj.get_processing_part_cost() ...
                obj.get_tooling_part_cost() ...
                obj.get_ndt_part_cost() ...
                obj.get_straightening_fixture_part_cost() ...
                obj.get_check_fixture_part_cost() ...
                ];
            titles = [ ...
                "material_per_part" ...
                "processing_per_part" ...
                "tooling_per_part" ...
                "ndt_per_part" ...
                "straightening_per_part" ...
                "check_per_part" ...
                ];
        end
        
        function value = get_material_part_cost( obj )
            value = obj.cost_advisor_model.material_part_cost;
        end
        
        function value = get_processing_part_cost( obj )
            value = obj.cost_advisor_model.processing_part_cost;
        end
        
        function value = get_ndt_part_cost( obj )
            value = obj.cost_advisor_model.ndt_part_cost;
        end
        
        function value = get_tooling_part_cost( obj )
            value = obj.cost_advisor_model.tooling_part_cost;
        end
        
        function value = get_straightening_fixture_part_cost( obj )
            value = obj.cost_advisor_model.straightening_fixture_part_cost;
        end
        
        function value = get_check_fixture_part_cost( obj )
            value = obj.cost_advisor_model.check_fixture_part_cost;
        end
        
        function set_per_part( obj, name, value )
            f = obj.per_part_edit_fields( name );
            f.Value = value;
        end
        
        function set_per_order( obj, name, value )
            f = obj.per_order_edit_fields( name );
            f.Value = value;
        end
        
        function set_per_part_grand_total_range( obj, range )
            assert( range( 1 ) <= 0 );
            assert( 0 <= range( 2 ) );
            range = abs( range );
            [ obj.grand_total_part_range_edit_fields.Value ] = ...
                deal( range( 1 ), range( 2 ) );
        end
        
        function set_per_order_grand_total_range( obj, range )
            assert( range( 1 ) <= 0 );
            assert( 0 <= range( 2 ) );
            range = abs( range );
            [ obj.grand_total_order_range_edit_fields.Value ] = ...
                deal( range( 1 ), range( 2 ) );
        end
        
        function value = get_quantity_ordered( obj )
            value = obj.cost_advisor_model.quantity_ordered;
        end
    end
    
end

