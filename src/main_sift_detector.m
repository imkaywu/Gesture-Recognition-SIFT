function main_sift_detector
    %----------------------------------------------------------------
    % detect and store sift (already done, no need to use this function unless new images are added)
    % function:
    %  - [frame, descriptor] = sift(I): detect sift, implemented by a UCLA PhD student, file in ../sift-0.9
    %----------------------------------------------------------------
    clear;clc;
    cd 'G:\Projects\Hand Gesture\Kay''s code';
    [gesture, ~, ~] = load_gesture;
    disp('------');
    disp('sift detector');
    sift_frame = [];
    sift_descriptor = [];
    sift_descriptor_num = [];
    
    for image_index=1 : size(gesture, 2)
        [frame, descriptor, I] = sift_detect(gesture, image_index);
        sift_frame = [sift_frame, frame];
        sift_descriptor = [sift_descriptor, descriptor];
        sift_descriptor_num = [sift_descriptor_num, size(descriptor, 2)];
    end
    save('..\data\SIFT\sift_frame.mat', 'sift_frame');
    save('..\data\SIFT\sift_descriptor.mat', 'sift_descriptor');
    save('..\data\SIFT\sift_descriptor_num.mat', 'sift_descriptor_num');
end