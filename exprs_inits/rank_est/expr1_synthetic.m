%% Testing krylov-based rank estimation and intialization on synthetic
% sparse data tensors
ranks = [10 20 30 40 50 60 70 80 90];
% ranks = [5 10 15 20 25];
sz = [100 100 100];
num_tensors = length(ranks);
modes = length(sz);
k = max(sz);
est_ranks = zeros(num_tensors,1);
cond_nums_raw = cell(num_tensors,1);

for kdx = 1:num_tensors
    tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
      'Num_Factors', ranks(kdx),'Sparse_Generation', .9, 'Noise', 0);
%     tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
%       'Num_Factors', ranks(kdx), 'Noise', 0);
    Us = arnoldi_cp_init(tns.Data, k);
    % calculate condition numbers according to the number of columns
    % included in the Krylov subspace factor matrices
    cond_nums = zeros(k, modes);
    for jdx = 1:modes
        for idx = 1:k
            cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
        end
    end
    cond_nums_raw{kdx, 1} = cond_nums;
end

%% analyze cond_nums
% cond_num_thershold = 500000;
for kdx = 1:num_tensors
    tmp_ranks = zeros(modes,1);
    for jdx = 1:modes
        % perform sliding window analysis of condition numbers as the
        tempCNs = cond_nums_raw{kdx,1}(1:ranks(kdx)+10,jdx);
        % limit range of consideration based on condition num threshold
%         tempCNs = tempCNs(tempCNs < cond_num_thershold);
        inc_diff = diff(tempCNs);
        ttl_diff = tempCNs(end) - tempCNs(1);
        pcnt_diff = inc_diff ./ ttl_diff;
        idx =1;
        while sum(pcnt_diff(1:idx)) < 0.05 && idx <= length(pcnt_diff)
            idx = idx + 1;
        end
        tmp_ranks(jdx,1) = idx - 1;
    end
    est_ranks(kdx,1) = max(tmp_ranks);
%     figure;
%     plot(tempCNs);
end
