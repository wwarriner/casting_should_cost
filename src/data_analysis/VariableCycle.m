classdef VariableCycle < handle
    
    properties ( SetAccess = private, Dependent )
        next(1,1)
        at_end(1,1) logical
        count(1,1) double
    end
    
    methods
        function obj = VariableCycle( values )
            obj.values = values;
        end
        
        function reset( obj )
            obj.index = 1;
        end
        
        function value = get.next( obj )
            if obj.at_end
                obj.reset();
            end
            if iscell( obj.values )
                value = obj.values{ obj.index };
            else
                value = obj.values( obj.index );
            end
            if ~obj.at_end
                obj.advance();
            end
        end
        
        function value = get.at_end( obj )
            value = obj.index > obj.count;
        end
        
        function value = get.count( obj )
            value = numel( obj.values );
        end
    end
    
    properties ( Access = private )
        values(:,1)
        index(1,1) uint32 = 1
    end
    
    methods ( Access = private )
        function advance( obj )
            obj.index = obj.index + 1;
        end
    end
    
end

