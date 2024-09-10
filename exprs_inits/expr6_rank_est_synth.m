%% Testing krylov-based rank estimation and intialization on synthetic
% sparse data tensors
ranks = [10 15 20 25 30 35 40 45 50];
sz = [100 100 100];
num_tensors = length(ranks);
modes = length(sz);
k = max(sz);

for rank = ranks
    tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
      'Num_Factors', nc,'Sparse_Generation', .99, 'Noise', 0);
    Us = cp_init_arnoldi(tns.Data, k);
    % calculate condition numbers
    cond_nums = zeros(k, modes);
    for jdx = 1:modes
        for idx = 1:k
            cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
        end
    end
    % evaluate cond number ratios
    cond_ratios = zeros(k-1,modes);
    % cond_scaled_diff = zeros(k-1,modes);
    for jdx = 1:modes
        for idx = 1:(k-1)
            cond_ratios(idx,jdx) = cond_nums(idx+1,3) / cond_nums(idx,3);
    %         cond_scaled_diff(idx,jdx) = 100 * (cond_nums(idx+1, 3) - cond_nums(idx,3));
        end
    end
    
    mode_ks = zeros(modes,1);
    for jdx = 1:modes
        tmp_k = 0;
        for idx = 1:(k-1)
            if cond_ratios(idx,jdx) > 1.001
                tmp_k = idx;
                break;
            end
        end
        mode_ks(jdx,1) = tmp_k;
    end
    % build initialization and store estimated rank (max_k)
    Us1 = cell(modes,1);
    max_k = max(mode_ks);
    for idx =1:modes
        Us1{idx} = Us{idx}(:,1:max_k);
    end
end

