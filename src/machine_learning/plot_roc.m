function [ axh, aucs ] = plot_roc( classes, labels, score, highlighted_classes )

if nargin < 4
    highlighted_classes = classes;
end

%colors = get_colors();

gray = [ 0.7 0.7 0.7 ];
tex_gray = sprintf( '\\color[rgb]{%f %f %f}', gray );
blue = [ 0.3 0.5 0.75 ];

fh = figure( 'color', 'w' );
fh.Position = [ 10, 10, 720, 480 ];
axh = axes( fh );
axh.Box = 'off';
axh.XLim = [ 0 100 ];
axh.XTick = 0 : 25 : 100;
axh.XAxis.TickLabelFormat = '%.0f';
axh.XLabel.String = sprintf( 'False Positive Rate %s%%', tex_gray );
axh.YLim = [ 0 100 ];
axh.YTick = 0 : 25 : 100;
axh.YAxis.TickLabelFormat = '%.0f';
axh.YLabel.String = {'True','Positive',sprintf( 'Rate %s%%', tex_gray )};
axh.YLabel.Rotation = 0;
axh.YLabel.HorizontalAlignment = 'left';
axh.YLabel.VerticalAlignment = 'middle';
axh.FontSize = 18;
axh.LineWidth = 1;
hold( axh, 'on' );
axis( 'square' );
thresholds = cell( length( classes ), 1 );
aucs = cell( length( classes ), 1 );
optrocpt = cell( length( classes ), 1 );
for i = 1 : length( classes )
    class = classes( i );
    [ roc_x, roc_y, thresholds{ i }, aucs{ i }, optrocpt{ i } ] ...
        = perfcurve( labels, score( :, i ), class );
    ph = plot( axh, 100 .* roc_x, 100 .* roc_y );
    %ph.Color = colors( mod( i - 1, numel( colors ) ) + 1, : );
    ph.LineWidth = 2;
    if ismember( class, highlighted_classes )
        ph.Color = blue;
    else
        ph.Color = gray;
    end
    if numel( classes ) == 2
        break;
    end
end
lh = line( axh, axh.XLim, axh.YLim );
lh.LineStyle = ':';
lh.Color = gray;
lh.LineWidth = 1;
% lh = legend( axh, num2str( classes ) );
% lh.Location = 'east';


axh.YLabel.Position( 1 ) = axh.YLabel.Position( 1 ) - axh.YLabel.Extent( 3 );

end

