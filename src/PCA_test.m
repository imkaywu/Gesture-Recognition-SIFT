clear;clc;
% x = [2.5000; 0.5000; 2.2000; 1.9000; 3.1000; 2.3000; 2.0000; 1.0000; 1.5000; 1.1000];
% y = [2.4000; 0.7000; 2.9000; 2.2000; 3.0000; 2.7000; 1.6000; 1.1000; 1.6000; 0.9000];
% x = x - mean(x);
% y = y - mean(y);
% cov_mat = cov([x, y]);
% [eig_vec, eig_val] = eig(cov_mat);

load('..\data\SIFT\sift_descriptor.mat');
sift_descriptor = sift_descriptor - repmat(mean(sift_descriptor, 2), 1, size(sift_descriptor, 2));
% rep_mat1 = repmat((1 : size(sift_descriptor, 1)), size(sift_descriptor, 1), 1);
% cov_mat1 = sift_descriptor(rep_mat1, :);
% rep_mat2 = repmat((1 : size(sift_descriptor, 1))', 1, size(sift_descriptor, 1));
% cov_mat2 = sift_descriptor(rep_mat2, :);
cov_mat = zeros(size(sift_descriptor, 1));
for i = 1 : size(sift_descriptor, 1)
    for j = 1 : size(sift_descriptor, 1)
        covariance = cov(sift_descriptor(i, :)', sift_descriptor(j, :)');
        cov_mat(i, j) = covariance(1, 2);
    end
end

[eig_vec, eig_val] = eig(cov_mat);
[eig_val, ind] = sort(diag(eig_val), 'descend');
eig_vec = eig_vec(:, ind);
dim = 2;
eig_vec = eig_vec(:, 1 : dim);
eig_val = diag(eig_val(1 : dim));
sift_feature = eig_vec' * sift_descriptor;
figure;
hold on;
for i = 1 : size(sift_feature, 2)
%     plot(sift_feature(1, i), sift_feature(2, i), '.');
    scatter3(sift_feature(1, i), sift_feature(2, i), sift_feature(3, i), '.');
end