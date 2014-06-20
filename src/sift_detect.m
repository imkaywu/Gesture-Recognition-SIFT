function [frame, descriptor, I] = sift_detect(gesture, image_index)
    if(iscell(gesture))
        f_name = gesture{image_index};
    else
        [~,length]=max(gesture(image_index,:)==' ');
        if(length~=1)
            f_name = gesture(image_index,1:length-1);
        else
            f_name = gesture(image_index,:);
        end
    end
    load(['..\hand\',f_name,'.mat']);
    if(exist('dis1_d2_e2','var'))
        image_mat=dis1_d2_e2;
    elseif(exist('dis2_d2_e2','var'))
        image_mat=dis2_d2_e2;
    end
    image_mat(image_mat > 0) = 1;
    image_mat = blob_detector(image_mat);% eliminate background noise
    
    ind = find(f_name == '-');
    dir = f_name(1 : ind - 1);
    i_name = f_name(ind + 1 : end - 1);
    left_right = f_name(end);
    if(left_right == '1')
        image = imread(['..\image\', dir, '\a_rectified', i_name, '.jpg']);
    elseif(left_right == '2')
        image = imread(['..\image\', dir, '\b_rectified', i_name, '.jpg']);
    end 
    image = double(rgb2gray(image));
    %image = im2double(rgb2gray(image));相当于先double后除255
    image = image(13 : 462, 5 : 634);
    I = image / 255;
    
    cd 'G:\Research\Basis\SIFT\sift-0.9';
    [frame, descriptor] = sift(I);
    cd 'G:\Projects\Hand Gesture\Kay''s code';
    delete_index = [];
    for i = 1 : size(frame, 2)
        if(~image_mat(round(frame(2, i)), round(frame(1, i))))
            delete_index = [delete_index, i];
        end
    end
    frame(:, delete_index) = [];
    descriptor(:, delete_index) = [];
    
    if(exist('dis1_d2_e2','var'))
        clear dis1_d2_e2;
    elseif(exist('dis2_d2_e2','var'))
        clear dis2_d2_e2;
    end
end