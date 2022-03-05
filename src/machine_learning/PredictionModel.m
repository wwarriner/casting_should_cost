classdef PredictionModel < Saveable & handle
    
    properties
        alpha(1,1) double = 0.05
    end
    
    methods
        function obj = PredictionModel( classifier, regressor )
            obj.classifier = classifier;
            obj.regressor = regressor;
        end
        
        function values = predict( obj, features )
            values.complexity = obj.classifier.predict( features );
            ci = obj.regressor.compute_confidence_interval( obj.alpha );
            values.range = ci + values.complexity;
        end
    end
    
    properties ( Access = private )
        classifier EnsembleClassifier
        regressor EnsembleRegressor
    end
    
end

