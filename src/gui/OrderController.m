classdef OrderController < handle
    
    properties ( Access = public, Constant )
        CLASS = "class";
        GRADE = "grade";
        MATERIAL = "material";
        QUANTITY_ORDERED = "quantity_ordered";
    end
    
    methods ( Access = public )
        function obj = OrderController( ...
                cost_advisor_model, ...
                edit_fields ...
                )
            obj.cost_advisor_model = cost_advisor_model;
            obj.edit_fields = edit_fields;
            obj.update_listbox_contents();
            obj.update();
        end
        
        function update_listbox_contents( obj )
            obj.update_class_listbox_items();
            obj.update_grade_listbox_items();
            obj.update_material_listbox_items();
        end
        
        function update( obj )
            obj.update_class();
            obj.update_grade();
            obj.update_material();
            obj.update_quantity_ordered();
        end
        
        function value = to_table( obj )
            value = table( ...
                string( obj.cost_advisor_model.material ), ...
                string( obj.cost_advisor_model.grade ), ...
                string( obj.cost_advisor_model.class ), ...
                obj.cost_advisor_model.quantity_ordered, ...
                'variablenames', ...
                cellstr( [ "material" ...
                "grade" ...
                "class" ...
                "quantity_ordered" ] ) ...
                );
        end
    end
    
    properties ( Access = private )
        cost_advisor_model
        edit_fields
    end
    
    methods ( Access = private )
        function update_class_listbox_items( obj )
            value = obj.cost_advisor_model.classes;
            obj.update_listbox_items( obj.CLASS, value );
        end
        
        function update_grade_listbox_items( obj )
            value = obj.cost_advisor_model.grades;
            obj.update_listbox_items( obj.GRADE, value );
        end
        
        function update_material_listbox_items( obj )
            value = obj.cost_advisor_model.materials;
            obj.update_listbox_items( obj.MATERIAL, value );
        end
        
        function update_class( obj )
            f = obj.edit_fields( obj.CLASS );
            obj.cost_advisor_model.class = f.Value;
        end
        
        function update_grade( obj )
            f = obj.edit_fields( obj.GRADE );
            obj.cost_advisor_model.grade = f.Value;
        end
        
        function update_material( obj )
            f = obj.edit_fields( obj.MATERIAL );
            obj.cost_advisor_model.material = f.Value;
        end
        
        function update_quantity_ordered( obj )
            f = obj.edit_fields( obj.QUANTITY_ORDERED );
            obj.cost_advisor_model.quantity_ordered = f.Value;
        end
        
        function update_listbox_items( obj, tag, items )
            f = obj.edit_fields( tag );
            f.Items = items;
        end
    end
    
end