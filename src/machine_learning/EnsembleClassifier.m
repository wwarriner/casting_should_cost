classdef EnsembleClassifier < handle
    
    properties
        k_fold(1,1) uint32 {mustBePositive} = 5
        learning_cycle_count(1,1) uint32 {mustBePositive} = 30;
        ensemble_method(1,1) string = "bag";
        seed(1,1) uint32 = 314159;
    end
    
    methods
        function obj = EnsembleClassifier( training_data )
            obj.data = training_data;
        end
        
        function generate( obj )
            tree_split_count = obj.data.example_count - 1;
            learner_template = templateTree( ...
                "maxnumsplits", tree_split_count ...
                );
            
            model_in = fitcensemble( ...
                obj.data.predictor_values, obj.data.responses, ...
                "method", obj.ensemble_method, ...
                "numlearningcycles", obj.learning_cycle_count, ...
                "learners", learner_template, ...
                "predictornames", obj.data.predictor_names, ...
                "classnames", obj.data.classes ...
                );
            pm = crossval( model_in, 'kfold', double( obj.k_fold ) );
            [ predictions, scores ] = kfoldPredict( pm );
            accuracy = 1 - kfoldLoss( pm, 'lossfun', 'classiferror' );
            
            obj.model = model_in;
            obj.cv_predictions = predictions;
            obj.cv_scores = scores;
            obj.cv_accuracy = accuracy;
        end
        
        % TODO save/load
        
        function y = predict( obj, x )
            y = predict( obj.model, x );
        end
        
        function aucs = plot_roc( obj )
            [ ~, aucs ] = plot_roc( ...
                obj.data.classes, ...
                obj.data.responses, ...
                obj.cv_scores ...
                );
        end
        
        function cm = plot_confusion( obj )
            figure();
            cm = confusionmat( obj.data.responses, obj.cv_predictions );
            cmh = confusionchart( cm );
            cmh.RowSummary = "row-normalized";
        end
        
%         function s = saveobj( obj )
%             s.k_fold = obj.k_fold;
%             s.learning_cycle_count = obj.learning_cycle_count;
%             s.ensemble_method = obj.ensemble_method;
%             s.seed = obj.seed;
%             s.data = obj.data.saveobj();
%             s.model = obj.model;
%             s.cv_predictions = obj.cv_predictions;
%             s.cv_scores = obj.cv_scores;
%             s.cv_accuracy = obj.cv_accuracy;
%         end
    end
    
    properties ( Access = private )
        data TrainingData
        model
        cv_predictions
        cv_scores
        cv_accuracy
    end
    
%     methods ( Static )
%         function obj = loadobj( s )
%             obj.k_fold = s.k_fold;
%             obj.learning_cycle_count = s.learning_cycle_count;
%             obj.ensemble_method = s.ensemble_method;
%             obj.seed = s.seed;
%             obj.data = TrainingData.loadobj( s.data );
%             obj.model = s.model;
%             obj.cv_predictions = s.cv_predictions;
%             obj.cv_scores = s.cv_scores;
%             obj.cv_accuracy = s.cv_accuracy;
%         end
%     end
    
end

