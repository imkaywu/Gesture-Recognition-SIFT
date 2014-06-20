function num = sift_match(frame1, descriptor1, frame2, descriptor2, col)
    %------------------------------------------------------------------
    % method invoked by sift_test.m
    %------------------------------------------------------------------
    cd 'G:\Research\Basis\SIFT\sift-0.9';
    matches = siftmatch(descriptor1, descriptor2);
    cd 'G:\Projects\Hand Gesture\Kay''s code';
    for i = 1 : size(frame1, 2)
        plot(frame1(1, i), frame1(2, i), 'r.');
    end
    for i = 1 : size(frame2, 2)
        plot(col + frame2(1, i), frame2(2, i), 'r.');
    end
    for i = 1 : size(matches, 2)
        plot(frame1(1, i), frame1(2, i), 'g.');
        plot(col + frame2(1, i), frame2(2, i), 'g.');
        plot([frame1(1, i), col + frame2(1, i)], [frame1(2, i), frame2(2, i)], 'b-');
    end
    num = size(matches, 2);
end