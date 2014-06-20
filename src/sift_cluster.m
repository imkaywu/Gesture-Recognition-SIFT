function dictionary = sift_cluster(sift_descriptor, sift_descriptor_num, k)
    %----------------------------------------------------------------------
    % cluster sift using k-means clustering, store the dictionary
    %----------------------------------------------------------------------
    niters = 100;
    ThrError = 0.009;   %Threshold
    sift_dim = 128;
    centers = zeros(sift_dim, k);
    sift_feature = sift_descriptor(:, 1 : sift_descriptor_num(1));
    perm = randperm(sift_descriptor_num(1));
    perm = perm(1 : k);
    centers = sift_feature(:, perm);
    
    nimages = size(sift_descriptor_num, 2);
    for n = 1 : niters
        % Save old centers to check for termination
        old_centers = centers;
        tempc = zeros(sift_dim, k);
        num_points = zeros(1, k);
        
        for f = 1 : nimages
            sift_feature = sift_descriptor(:, sum(sift_descriptor_num(1 : f - 1)) + 1 : sum(sift_descriptor_num(1 : f)));
            
            id = eye(k);
            dist = EuclideanDistance(sift_feature, centers);
            % Assign each point to nearest centre
            [~, index] = min(dist', [], 1); % dist: sift_feature_num x k, index is a row vector
            post = id(index, :); % matrix, if word i is in cluster j, post(i,j)=1, else 0;

            num_points = num_points + sum(post, 1);

            for j = 1 : k
                tempc(:, j) =  tempc(:, j) + sum(sift_feature(:, find(post(:, j))), 2);
            end
        end

        for j = 1 : k
            if num_points(j) > 0
                centers(:, j) =  tempc(:, j) / num_points(j);
            end
        end
        
        if n > 1    % Test for termination
            if max(max(abs(centers - old_centers))) < ThrError
                dictionary = centers;
                save('..\data\SIFT\dictionary.mat', 'dictionary');  % save the settings of descriptor in opts.globaldatapath
                disp('terminated with meeting the threshold');
                break;
            elseif(n == niters)
                disp('terminated without meeting the threshold');
            end
            fprintf('----The %d th interation finished---- \n',n);
        end
    end
end