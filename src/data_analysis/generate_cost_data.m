function cost_data = generate_cost_data( cost_advisor_file, training_data, stl_folder )

cam = CostAdvisorModel( cost_advisor_file );
row_count = height( training_data );
cost_data = [];
for i = 1 : row_count
    row = training_data( i, : );
    casting = read_casting( row, stl_folder );
    prepare_cam( cam, casting, row );
    cost_data = [ cost_data; analyze( cam, casting.name ) ]; %#ok<AGROW>
    fprintf( "%i/%i\n", i, row_count );
end
cost_data = cell2table( cost_data );
cost_data.Properties.VariableNames = { ...
    'name' ...
    'material' ...
    'class' ...
    'grade' ...
    'complexity' ...
    'tooling_cost' ...
    'fixturing_cost' ...
    'part_cost' ...
    };

end


function c = read_casting( row, stl_folder )

name = string( row.name{1} );
file = fullfile( stl_folder, name + ".stl" );

c = Casting();
c.input_file = file;
c.run();

end


function prepare_cam( cam, casting, row )

cam.box_dimensions = casting.envelope.lengths;
cam.casting_surface_area = casting.surface_area;
cam.casting_volume = casting.volume;
cam.core_volume = row.Cores_volume_ratio .* casting.volume;
cam.quantity_ordered = 1;

end


function data = analyze( cam, name )

complexities = VariableCycle( uint32( cam.shape_complexity_tags ) );
classes = VariableCycle( cam.classes );
grades = VariableCycle( cam.grades );
materials = VariableCycle( cam.materials );

row_count = prod( [ ...
    complexities.count ...
    classes.count ...
    grades.count ...
    materials.count ...
    ] );
var_count = 8;
data = cell( row_count, var_count );

i = 1;
while true
    cam.material = materials.next;
    while true
        cam.class = classes.next;
        while true
            cam.grade = grades.next;
            while true
                cam.shape_complexity = complexities.next;
                costs = num2cell( extract_costs( cam ) );
                v = { ...
                    name ...
                    cam.material ...
                    cam.class ...
                    cam.grade ...
                    cam.shape_complexity ...
                    };
                data( i, : ) = [ v costs ];
                i = i + 1;
                if complexities.at_end; break; end
            end
            if grades.at_end; break; end
        end
        if classes.at_end; break; end
    end
    if materials.at_end; break; end
end

end


function data = extract_costs( cam )

tooling = cam.tooling_part_cost;
fixture = cam.check_fixture_part_cost ...
    + cam.straightening_fixture_part_cost;
part = cam.ndt_part_cost ...
    + cam.processing_part_cost ...
    + cam.material_part_cost;
data = [ tooling fixture part ];

end

