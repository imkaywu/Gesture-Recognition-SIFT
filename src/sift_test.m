%------------------------------------------------------------------------
% verify the validivity of the algorithm of sift using matching
%------------------------------------------------------------------------
clear;
clc;
[gesture, gesture_num, ~] = load_gesture;
gesture1 = 1;   % 1 - 14
gesture2 = 1;   % 1 - 14

for i = sum(gesture_num(1 : gesture1 - 1)) + 1 : sum(gesture_num(1 : gesture1))
    [frame1, descriptor1, image1] = sift_detect(gesture, i);
    for j = sum(gesture_num(1 : gesture2 - 1)) + 1 : sum(gesture_num(1 : gesture2))
        [frame2, descriptor2, image2] = sift_detect(gesture, j);
        imshow([image1, image2]);
        hold on;
        num = sift_match(frame1, descriptor1, frame2, descriptor2, size(image1, 2));    % used to match sift keypoints
    end
end