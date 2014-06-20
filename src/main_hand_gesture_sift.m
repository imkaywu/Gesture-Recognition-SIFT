function accuracy = main_hand_gesture_sift
    %---------------------------------------------------------
    % data：
    %  - sift_frame：4 x N matrix, N is the number of sift, sift_frame(1 : 2, i) stores the x, y coordinates of ith sift.
    %  - sift_descritor：128 x N matrix, N is the number of sift, sift_descriptor(:, i) is the ith sift
    %  - sift_descriptor_num: 1 x M, M is the number of images, sift_descriptor_num(i) stores the number of sift in ith image
    % function：
    %  - divide_data: divide the sift into training and test set
    %   * label_train, label_test: indicate which gesture type this image belongs to
    %  - sift_cluster: cluster sift using k-means
    %  - sift_cluster_LBP: cluster sift using vector quantization
    %  - sift2hist: transform sift into a histogram
    %----------------------------------------------------------
    clear;clc;
    cd 'G:\Projects\Hand Gesture\Kay''s code';  %存储代码的目录
    [gesture, gesture_num, gesture_type] = load_gesture;
    %% k-means and bag-of-features
    load('..\data\SIFT\sift_frame.mat');
    load('..\data\SIFT\sift_descriptor.mat');
    load('..\data\SIFT\sift_descriptor_num.mat');
    percent = 0.7;
    cluster_num = 10;
    iter = 5;
    accuracy = zeros(gesture_type);
    
    for i = 1 : iter
        [sift_frame_train, sift_frame_test, sift_descriptor_train, sift_descriptor_test, sift_descriptor_num_train, sift_descriptor_num_test, label_train, label_test, test_set] = divide_dataset(sift_frame, sift_descriptor, sift_descriptor_num, gesture_num, percent);
        dictionary = sift_cluster(sift_descriptor_train, sift_descriptor_num_train, cluster_num);
%         [dictionary, ~] = sift_cluster_LBP(sift_descriptor_train, cluster_num);
        hist_train = sift2hist(sift_descriptor_train, sift_descriptor_num_train, dictionary);
        hist_test = sift2hist(sift_descriptor_test, sift_descriptor_num_test, dictionary);

        % a color for a cluster
%         cluster_color = [255, 0, 255; 0, 0, 255; 0, 255, 255; 0, 255, 0; 255, 255, 0;...
%                         255, 0, 0; 128, 0, 128; 0, 0, 128; 0, 128, 128; 0, 128, 0;...
%                         128, 128, 0; 128, 0, 0; 128, 128, 128; 192, 64, 192; 64, 64, 192;...
%                         64, 192, 192; 64, 192, 64; 192, 192, 64; 192, 64, 64; 192, 192, 192] / 255;
%             
%         for n = 9 : size(test_set, 1)
%             f_name = gesture{1, test_set(n)};
%             load(['hand1\', f_name]);
%             if(exist('dis1_d2_e2','var'))
%                 image_mat=dis1_d2_e2;
%             elseif(exist('dis2_d2_e2','var'))
%                 image_mat=dis2_d2_e2;
%             end
%             image_mat(image_mat > 0) = 1;
%             image_mat = blob_detector(image_mat);% eliminate background noise
%     
%             ind = find(f_name == '-');
%             dir = f_name(1 : ind - 1);
%             i_name = f_name(ind + 1 : size(f_name, 2) - 1);
%             left_right = f_name(size(f_name, 2));
%             if(left_right == '1')
%                 image = imread(['..\image\', dir, '\a_rectified', i_name, '.jpg']);
%             elseif(left_right == '2')
%                 image = imread(['..\image\', dir, '\b_rectified', i_name, '.jpg']);
%             end
%             image = im2double(rgb2gray(image));%相当于先double后除255
%             image = image(13 : 462, 5 : 634);
%             imshow(image);
%             hold on;
%             for j = 1 : sift_descriptor_num_test(n)
%                 %dist = EuclideanDistance(sift_descriptor_test(:, sum(sift_descriptor_num(1 : test_set(n) - 1)) + j), dictionary);
%                 dist = EuclideanDistance(sift_descriptor_test(:, sum(sift_descriptor_num_test(1 : n - 1)) + j), dictionary);
%                 [~, ind] = min(dist);
%                 plot(sift_frame_test(1, sum(sift_descriptor_num_test(1 : n - 1)) + j), sift_frame_test(2, sum(sift_descriptor_num_test(1 : n - 1)) + j), 'color', cluster_color(ind, :), 'line', '.');
%             end
%             if(exist('dis1_d2_e2','var'))
%                 clear dis1_d2_e2;
%             elseif(exist('dis2_d2_e2','var'))
%                 clear dis2_d2_e2;
%             end
%         end

        % train models
        cd 'E:\Program Files\MATLAB\R2010b\toolbox\libsvm-3.17\matlab';
        [bestc, bestg] = SVMcg(label_train, hist_train');%(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep)
        cmd = ['-c ' , num2str(bestc) , ' -g ' , num2str(bestg)];
        model = svmtrain(label_train, hist_train', cmd);
        % test models
        [label_predict, accuracy_rate, prob_estimates] = svmpredict(label_test, hist_test', model, '-q');
        cd 'G:\Projects\Hand Gesture\Kay''s code';
        accuracy_test = zeros(gesture_type);
        for n = 1 : size(label_test, 1)
            accuracy_test(label_predict( n ), label_test( n )) = accuracy_test(label_predict(n), label_test(n)) + 1;
        end
        accuracy_test = accuracy_test ./ repmat(sum(accuracy_test, 1), length(accuracy_test), 1);
%         for n = 1 : gesture_type
%             accuracy_test(:, n) = accuracy_test(:, n) / sum(accuracy_test(:, n));
%         end
        accuracy = accuracy + accuracy_test;
    end
    accuracy = accuracy / iter;
end

function [sift_frame_train, sift_frame_test, sift_descriptor_train, sift_descriptor_test, sift_descriptor_num_train, sift_descriptor_num_test, label_train, label_test, test_set] = divide_dataset(sift_frame, sift_descriptor, sift_descriptor_num, gesture_num, percent)
    train_num = floor(gesture_num * percent);
    train_set = [];
    test_set = [];
    sift_frame_train = [];
    sift_frame_test = [];
    sift_descriptor_train = [];
    sift_descriptor_test = [];
    label_train = [];
    label_test = [];
    for i = 1 : size(gesture_num, 1)
        perm = randperm(gesture_num(i))';
        train_perm = sum(gesture_num(1 : i - 1)) + perm(1 : train_num(i));
        test_perm = sum(gesture_num(1 : i - 1)) + perm(train_num(i) + 1 : end);
        train_set = [train_set; train_perm];
        test_set = [test_set; test_perm];
        label_train = [label_train; i * ones(train_num(i), 1)];
        label_test = [label_test; i * ones(gesture_num(i) - train_num(i), 1)];
    end
    sift_descriptor_num_train = sift_descriptor_num(train_set);
    sift_descriptor_num_test = sift_descriptor_num(test_set);
    
    for i = 1 : size(train_set, 1)
        sift_descriptor_train = [sift_descriptor_train, sift_descriptor(:, sum(sift_descriptor_num(1 : train_set(i) - 1)) + 1 : sum(sift_descriptor_num(1 : train_set(i))))];
        sift_frame_train = [sift_frame_train, sift_frame(:, sum(sift_descriptor_num(1 : train_set(i) - 1)) + 1 : sum(sift_descriptor_num(1 : train_set(i))))];
    end
    for i = 1 : size(test_set, 1)
        sift_descriptor_test = [sift_descriptor_test, sift_descriptor(:, sum(sift_descriptor_num(1 : test_set(i) - 1)) + 1 : sum(sift_descriptor_num(1 : test_set(i))))];
        sift_frame_test = [sift_frame_test, sift_frame(:, sum(sift_descriptor_num(1 : test_set(i) - 1)) + 1 : sum(sift_descriptor_num(1 : test_set(i))))];
    end
end

function hist = sift2hist(sift_descriptor, sift_descriptor_num, dictionary)
    hist = zeros(size(dictionary, 2), size(sift_descriptor_num, 2));
    for i = 1 : size(sift_descriptor_num, 2)
        dist = EuclideanDistance(sift_descriptor(:, sum(sift_descriptor_num(1 : i - 1)) + 1 : sum(sift_descriptor_num(1 : i))), dictionary);
        [~, index] = min(dist', [], 1);
        index = repmat(index, size(dictionary, 2), 1);
        hist_num = repmat((1 : size(dictionary, 2))', 1, size(index, 2));
        hist(:, i) = sum(index == hist_num, 2);
    end
end