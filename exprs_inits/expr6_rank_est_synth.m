%% Testing krylov-based rank estimation and intialization on synthetic
% sparse data tensors
ranks = [10 20 30 40 50];
% ranks = [80 85 90 95 100];
sz = [500 500 500];
num_tensors = length(ranks);
modes = length(sz);
k = max(sz) + 10;
est_ranks = zeros(num_tensors,1);
cond_nums_raw = cell(num_tensors,1);
cond_ratios_raw = cell(num_tensors,1);


for kdx = 1:num_tensors
    tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
      'Num_Factors', ranks(kdx),'Sparse_Generation', .9, 'Noise', 0);
%     tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
%       'Num_Factors', ranks(kdx), 'Noise', 0);
    Us = cp_init_arnoldi(tns.Data, k);
    % calculate condition numbers
    cond_nums = zeros(k, modes);
    for jdx = 1:modes
        for idx = 1:k
            cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
        end
    end
    cond_nums_raw{kdx, 1} = cond_nums;
    % evaluate cond number ratios
    cond_ratios = zeros(k-1,modes);
    for jdx = 1:modes
        for idx = 1:(k-1)
            cond_ratios(idx,jdx) = cond_nums(idx+1,3) / cond_nums(idx,3);
        end
    end
    cond_ratios_raw{kdx,1} = cond_ratios;

    mode_ks = zeros(modes,1);
    for jdx = 1:modes
        tmp_k = 0;
        for idx = 1:(k-1)
            if cond_ratios(idx,jdx) > 1.5
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
    est_ranks(kdx) = max_k;
end

%%
figure;
% num_tensors = 10;
for kdx = 1:num_tensors
    for jdx = 1:modes
        subplot(num_tensors, modes, (modes * (kdx -1) + jdx));
        plot(cond_nums_raw{kdx,1}(1:(ranks(kdx)+ min(ranks)/2),jdx));
        if kdx == 1
            col_title = sprintf("Mode - %d", jdx);
            title(col_title);
        end
    end
end
sgtitle('Condition Number');

%%
figure;
for jdx = 1:modes
    subplot(1,modes,jdx);
    plot(cond_ratios_raw{1,1}(1:(ranks(1)+2),jdx));
    title('Mode - ', jdx);
end
sgtitle('Condition Number Ratios');