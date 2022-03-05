classdef TrainingData < handle
    
    properties
        excluded_variable_names(1,1) string
        class_variable_name(1,1) string
    end
    
    properties ( SetAccess = private, Dependent )
        example_count(1,1) double
        predictor_count(1,1) double
        predictor_values(:,:) double
        predictor_names(:,1) string
        responses(:,1) double
        classes(:,1) double
    end
    
    methods
        function obj = TrainingData( file )
            if nargin == 0
                return;
            end
            assert( isfile( file ) );
            
            obj.data = readtable( file );
        end
        
        function set.excluded_variable_names( obj, value )
            assert( isstring( value ) );
            assert( isvector( value ) );
            names = string( obj.data.Properties.VariableNames ); %#ok<MCSUP>
            assert( all( ismember( value, names ) ) );
            
            obj.excluded_variable_names = value;
        end
        
        function set.class_variable_name( obj, value )
            assert( isstring( value ) );
            assert( isscalar( value ) );
            names = string( obj.data.Properties.VariableNames ); %#ok<MCSUP>
            assert( ismember( value, names ) );
            
            obj.class_variable_name = value;
        end
        
        function value = get.example_count( obj )
            value = size( obj.data, 1 );
        end
        
        function value = get.predictor_count( obj )
            value = numel( obj.predictor_names );
        end
        
        function value = get.predictor_values( obj )
            t = obj.data;
            t( :, obj.excluded_variable_names ) = [];
            t( :, obj.class_variable_name ) = [];
            value = t{ :, : };
        end
        
        function value = get.predictor_names( obj )
            t = obj.data;
            t( :, obj.excluded_variable_names ) = [];
            t( :, obj.class_variable_name ) = [];
            value = string( t.Properties.VariableNames );
        end
        
        function value = get.responses( obj )
            value = obj.data{ :, obj.class_variable_name };
        end
        
        function value = get.classes( obj )
            value = unique( obj.responses );
        end
    end
    
    properties( Access = private )
        data table
    end
    
    methods ( Static )
        function obj = loadobj( s )
            obj = TrainingData();
            obj.data = s.data;
            obj.excluded_variable_names = s.excluded_variable_names;
            obj.class_variable_name = s.class_variable_name;
        end
    end
    
end

