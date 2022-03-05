classdef ComplexityModel < handle
    
    methods ( Access = public )
        function obj = ComplexityModel( model_file_path )
            obj.complexity_model = PredictionModel.load_obj( model_file_path );
        end
        
        function expected_features = get_expected_features( obj )
            expected_features = obj.complexity_model.PredictorNames;
        end
        
        function complexity = predict_complexity( obj, features )
            values = obj.complexity_model.predict( features );
            complexity = values.complexity;
            obj.previous_values = values;
        end
        
        function cost_range = compute_cost_range( obj, costs )
            switch obj.previous_values.complexity
                case 1
                    complexity_range = 1 : 3;
                case 2
                    complexity_range = 1 : 4;
                case 3
                    complexity_range = 1 : 5;
                case 4
                    complexity_range = 2 : 5;
                case 5
                    complexity_range = 3 : 5;
                otherwise
                    assert( false );
            end
            cost_range = interp1( ...
                complexity_range, ...
                costs( complexity_range ), ...
                obj.previous_values.range, ...
                'linear', ...
                'extrap' ...
                );
        end
    end
    
    properties ( Access = private )
        complexity_model
        previous_values
    end
end

