classdef Features < handle
    
    properties ( SetAccess = private, Dependent )
        name(1,1) string
        summary table
        features(1,:) double {mustBeReal,mustBeFinite}
        box_dimensions(1,3) double {mustBeReal,mustBeFinite,mustBePositive}
        box_z_length(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        box_xy_area(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        box_xy_perimeter(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        box_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_volume(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        casting_surface_area(1,1) double {mustBeReal,mustBeFinite,mustBePositive}
        core_volume(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
        feeder_count(1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative}
    end
    
    methods
        function obj = Features( process_manager )
            obj.process_manager = process_manager;
        end
        
        function write( obj, file )
            writetable( obj.summary, file );
        end
        
        function value = get.name( obj )
            c = obj.get_casting();
            value = c.name;
        end
        
        function value = get.summary( obj )
            value = obj.get_feature_table();
        end
        
        function value = get.features( obj )
            value = obj.summary;
            value = value{ :, : };
            
            assert( isa( value, 'double' ) );
        end
        
        function value = get.box_dimensions( obj )
            c = obj.get_casting();
            value = c.envelope.lengths;
        end
        
        function value = get.box_z_length( obj )
            b = obj.box_dimensions;
            value = b( 3 );
        end
        
        function value = get.box_xy_perimeter( obj )
            b = obj.box_dimensions;
            value = 2 .* sum( b( 1 : 2 ) );
        end
        
        function value = get.box_xy_area( obj )
            b = obj.box_dimensions;
            value = prod( b( 1 : 2 ) );
        end
        
        function value = get.box_volume( obj )
            c = obj.get_casting();
            value = c.envelope.volume;
        end
        
        function value = get.core_volume( obj )
            c = obj.get_cores();
            value = c.volume;
        end
        
        function value = get.feeder_count( obj )
            f = obj.get_feeders();
            value = f.count;
        end
        
        function value = get.casting_volume( obj )
            c = obj.get_casting();
            value = c.volume;
        end
        
        function value = get.casting_surface_area( obj )
            c = obj.get_casting();
            value = c.surface_area;
        end
    end
    
    properties
        process_manager ProcessManager
    end
    
    methods ( Access = private )
        function c = get_casting( obj )
            c = obj.process_manager.get( ProcessKey( Casting.NAME ) );
        end
        
        function c = get_cores( obj )
            c = obj.process_manager.get( ProcessKey( Cores.NAME ) );
        end
        
        function f = get_feeders( obj )
            f = obj.process_manager.get( ProcessKey( Feeders.NAME ) );
        end
        
        function t = get_feature_table( obj )
            s = obj.process_manager.compose_summary();
            m = table2map( s );
            p = containers.Map( 'keytype', 'char', 'valuetype', 'any' );
            p( 'Casting_hole_count' ) = m( 'Casting_hole_count' );
            p( 'Casting_flatness' ) = m( 'Casting_flatness' );
            p( 'Casting_ranginess' ) = m( 'Casting_ranginess' );
            p( 'Casting_solidity' ) = m( 'Casting_solidity' );
            p( 'Cores_count' ) = m( 'Cores_count' );
            p( 'Cores_volume_ratio' ) = m( 'Cores_volume' ) ./ m( 'Casting_volume' );
            p( 'Feeders_count' ) = m( 'Feeders_count' );
            p( 'Parting_area_ratio' ) = m( 'Parting_area' ) ./ obj.box_xy_area;
            p( 'Parting_count' ) = m( 'Parting_count' );
            p( 'Parting_length_ratio' ) = m( 'Parting_length' ) ./ obj.box_xy_perimeter;
            p( 'Parting_draw_ratio' ) = m( 'Parting_draw' ) ./ obj.box_z_length;
            t = map2table( p );
        end
    end
    
end

