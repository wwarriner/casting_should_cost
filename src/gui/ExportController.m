classdef ExportController < handle
    
    methods
        function obj = ExportController( ...
                order_controller, ...
                cost_controller, ...
                setting_controller, ...
                toolsuite_model, ...
                cost_advisor_model ...
                )
            obj.order_controller = order_controller;
            obj.cost_controller = cost_controller;
            obj.setting_controller = setting_controller;
            obj.toolsuite_model = toolsuite_model;
            obj.cost_advisor_model = cost_advisor_model;
        end
        
        function export( obj )
            filter = { char( "*" + obj.EXPORT_EXT ), 'CSV file' };
            filter_path = fullfile( ...
                obj.previous_export_folder, ...
                obj.toolsuite_model.name + obj.EXPORT_EXT ...
                );
            try
                [ file, path ] = uiputfile( ...
                    filter, ...
                    'Save As', ...
                    filter_path ...
                    );
                if file ~= 0
                    file_path = fullfile( path, file );
                    obj.write( file_path );
                    obj.previous_export_folder = path;
                end
            catch e
                disp( getReport( e ) );
            end
        end
    end
    
    properties ( Access = private )
        order_controller OrderController
        cost_controller CostController
        setting_controller SettingController
        toolsuite_model ToolsuiteModel
        cost_advisor_model CostAdvisorModel
        previous_export_folder(1,1) string
    end
    
    methods ( Access = private )
        function write( obj, file )
            t = [ ...
                obj.setting_controller.to_table() ...
                obj.order_controller.to_table() ...
                obj.toolsuite_model.summary ...
                table( obj.cost_advisor_model.shape_complexity, 'variablenames', cellstr( "complexity" ) ) ...
                obj.cost_controller.to_table() ...
                ];
            writetable( t, file );
        end
    end
    
    properties ( Access = private, Constant )
        EXPORT_EXT = ".csv";
    end
    
end

