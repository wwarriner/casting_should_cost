classdef EnsembleRegressor < handle
    
    properties
        k_fold(1,1) uint32 {mustBePositive} = 5
        learning_cycle_count(1,1) uint32 {mustBePositive} = 30;
        ensemble_method(1,1) string = "bag";
        seed(1,1) uint32 = 314159;
    end
    
    methods
        function obj = EnsembleRegressor( training_data )
            obj.data = training_data;
        end
        
        function generate( obj )
            tree_split_count = obj.data.example_count - 1;
            learner_template = templateTree( ...
                "maxnumsplits", tree_split_count ...
                );
            
            model_in = fitrensemble( ...
                obj.data.predictor_values, obj.data.responses, ...
                "method", obj.ensemble_method, ...
                "numlearningcycles", obj.learning_cycle_count, ...
                "learners", learner_template, ...
                "predictornames", obj.data.predictor_names ...
                );
            pm = crossval( model_in, 'kfold', double( obj.k_fold ) );
            predictions = kfoldPredict( pm );
            accuracy = 1 - kfoldLoss( pm );
            
            obj.model = model_in;
            obj.cv_predictions = predictions;
            obj.cv_accuracy = accuracy;
        end
        
        function y = predict( obj, x )
            y = predict( obj.model, x );
        end
        
        function errors = plot_errors( obj )
            errors = obj.compute_errors();
            
            figure();
            histogram( errors );
            
            figure();
            cdfplot( errors );
        end
        
        function ci = compute_confidence_interval( obj, alpha )
            if nargin < 2
                alpha = 0.05;
            end
            errors = obj.compute_errors();
            [ f, x ] = ecdf( errors, 'alpha', alpha );
            tail = alpha ./ 2;
            range = [ tail 1-tail ];
            ci = interp1( f, x, range, 'linear' );
        end
    end
    
    properties ( Access = private )
        data TrainingData
        model
        cv_predictions
        cv_accuracy
    end
    
    methods ( Access = private )
        function errors = compute_errors( obj )
            errors = obj.data.responses - obj.cv_predictions;
        end
    end
    
end

