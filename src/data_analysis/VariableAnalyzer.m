classdef VariableAnalyzer < handle
    
    properties ( SetAccess = private, Dependent )
        count(1,1) double
        level_count(1,1) double
        at_end(1,1) logical
    end
    
    methods
        function obj = VariableAnalyzer( variable_cycles, operation_fn )
            obj.variable_cycles = variable_cycles;
            obj.operation_fn = operation_fn;
        end
        
        function run( obj )
            obj.loop( obj, 1 );
        end
        
        function value = get.count( obj )
            value = prod( [ obj.variable_cycles.count ] );
        end
        
        function value = get.level_count( obj )
            value = numel( obj.variable_cycles );
        end
        
        function value = get.at_end( obj )
            value = obj.count <= obj.iteration;
        end
    end
    
    properties
        variable_cycles(:,1) VariableCycles
        operation_fn(1,1) function_handle
        iteration(1,1) uint32 = 1;
    end
    
    methods ( Access = private )
        function loop( obj, level )
            if obj.level_count < level
                obj.operation_fn();
                obj.iteration = obj.iteration + 1;
            else
                while true
                    vc = VariableCycles( level );
                    vc.update();
                    obj.loop( level + 1 );
                    if vc.at_end; break; end
                end
            end
        end
    end
    
end

