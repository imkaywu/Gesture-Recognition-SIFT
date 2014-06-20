function [mu, Distortion] = sift_cluster_LBP(sift_descriptor, k)
    %------------------------------------------------------------------------
    % cluster the sift using vector quantization, same with k-means
    %------------------------------------------------------------------------
    
    %------------------------------------------------------------------------
    % step 1: Arbitrarily choose K samples as the initial cluster centers
    %------------------------------------------------------------------------
    [d, n] = size(sift_descriptor);
    oldmu = Inf * ones(d, k);
    c = zeros(1, n); % 1*n calculated membership vector where c(j) \in 1..K
    D = zeros(k, n);
    
    p = randperm(n);  % initial d*K  codevectors
    mu = sift_descriptor(:, p(1 : k));

    tic
    pp = 1;
    iter = 1; 
    Dis(iter) = 8000000;
    threshold = 0.001;
    while(pp > threshold)
        %------------------------------------------------------------------------
        % step 2: distribute the samples x to the chosen cluster domains
        %         based on which cluster center is nearest
        %------------------------------------------------------------------------
        iter = iter + 1;
        for j = 1 : k,                        % for every cluster
            center = mu(:, j);              % get cluster center
            if ~isequal(center, oldmu(:, j)) % has it moved ? 
                D(j, :) = EuclideanDistance(center, sift_descriptor); % calculate EuclideanDistance from sift_descriptor to center
            end
        end
        oldmu = mu;
        [Dmin, index] = min(D);
        %moved = sum(index ~= c);
        c = index;
        %------------------------------------------------------------------------
        % step 3: Update the cluster centers
        %------------------------------------------------------------------------
        for i = 1 : k
            ci = find(c == i);
            mu(:, i)=mean(sift_descriptor(:, ci), 2);
        end
        Dis(iter) = sum(Dmin) / size(Dmin, 2); % average distortion
        pp=(Dis(iter - 1) - Dis(iter)) / Dis(iter - 1); % used for stop condition
    end
    toc
    Distortion=Dis(iter); % average distortion for the last iteration
    % PSNR_means = 10 * log10(255.^2*16 ./Dis) % calculate the PSNR
end