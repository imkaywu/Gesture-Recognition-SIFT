function label_map = blob_detector( binary_map )
    [ y , x ] = find( binary_map == 1 );
%     y_start = min( y );
%     y_end = max( y );
%     x_end = max( x );
    [row, col] = size(binary_map);
%     label_map = zeros(row, col);
    label = 1;
    addRowSta = 0;
    addRowEnd = 0;
    addColSta = 0;
    addColEnd = 0;
    
    if(min(y) == 1)
        row = row + 1;
        binary_map_temp = zeros(row, col);
        binary_map_temp(2 : end, :) = binary_map;
        binary_map = binary_map_temp;
        addRowSta = 1;
    end
    if((~addRowSta && max(y) == row) || (addRowSta && max(y) == row - 1))
        row = row + 1;
        binary_map( row , : ) = 0;
        addRowEnd = 1;
    end
    if(min(x) == 1)
        col = col + 1;
        binary_map_temp = zeros(row, col);
        binary_map_temp (:, 2 : end) = binary_map;
        binary_map = binary_map_temp;
        addColSta = 1;
    end
    if((~addColSta && max(x) == col) || (addColSta && max(x) == col - 1))
        col = col + 1;
        binary_map( : , max(x) + 1 ) = 0;
        addColEnd = 1;
    end
    label_map = zeros(size(binary_map));
    [ y , ~ ] = find( binary_map == 1 );
    y_start = min( y );
    y_end = max( y );
    % blob label
    for i = y_start : y_end
        for j = find( binary_map( i ,: ) , 1 ) : find( binary_map( i ,: ) , 1 , 'last' )
            if( binary_map( i , j ) > 0 )
                label_neighbor = label_map( i - 1 : i + 1 , j - 1 : j + 1 );
                if( sum( sum( label_neighbor ) ) == 0 )
                    label_map( i , j ) = label( end );
                    label = [ label , label(end)+1 ];
                else
                    label_temp = unique( label_neighbor( label_neighbor > 0 ) );
                    label_map( i , j ) =label_temp( 1 );
                    if( size( label_temp , 1 ) > 1 )
                        label_temp = label_temp( 2 : end );
                        label( label_temp( label( label_temp ) > label_map( i , j ) ) ) = label_map( i , j );
                    end
                end
            end
        end
    end
    % combine labels
    if(addRowSta)
        label_map(1,:) = [];
    end
    if( addRowEnd )
        label_map( end , : ) = [];
    end
    if(addColSta)
        label_map(:,1) =[];
    end
    if( addColEnd )
        label_map( : , end ) = [];
    end
    label = label( 1 : end - 1 );
    for i = 1 : size( label , 2 )
        while( 1 )
            if( label( label( i ) ) == label( i ) )
                break;
            else
                label( i ) = label( label( i ) );
            end
        end
    end
    
    for i = 1 : size(label , 2 )
        label_map( label_map == i ) = label( i );
    end
    % find the dominant blob
    label_temp = unique( label );
    blob_max = 0;
    for i = 1 : size(label_temp , 2)
        if( blob_max < sum( sum( label_map == label_temp( i ) ) ) )
            blob_max = sum( sum( label_map == label_temp( i ) ) );
            label = label_temp( i );
        end
    end
    
    label_map( label_map ~= label ) = 0;
    label_map( label_map == label ) = 1;
end