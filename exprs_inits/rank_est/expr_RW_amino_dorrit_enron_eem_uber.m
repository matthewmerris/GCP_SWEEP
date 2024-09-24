% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';
eem_path = '~/datasets/real-world-rank-known/eem/EEM18.mat';
uber_path = '~/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/sugar.mat';
dataset_names = ["amino" "dorrit" "enron" "eem" "uber" "sugar"];
dataset_paths = {amino_path, dorrit_path, enron_path, eem_path, uber_path, sugar_path};


%%
num_datasets = length(dataset_names);

rng(1339);
for kdx = 1:num_datasets
    load(dataset_paths{kdx});
    if strcmp(dataset_names(kdx),"amino")
        load(dataset_paths{kdx});
        tns = tensor(X);
        % % adjust to be non-negative
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns = tns + adj_by;
    elseif strcmp(dataset_names(kdx),"dorrit")
        load(dataset_paths{kdx});
        tns = tensor(EEM.data);
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns(isnan(tns(:)))=0;
        tns = tns + adj_by;
    elseif strcmp(dataset_names(kdx),"enron")
        load(dataset_paths{kdx});
        tns = Enron; 
    elseif strcmp(dataset_names(kdx),"eem")
        load(dataset_paths{kdx});
        tns = tensor(X);
    elseif strcmp(dataset_names(kdx),"uber")
        load(dataset_paths{kdx});
        tns = sptensor(uber);
    elseif strcmp(dataset_names(kdx),"sugar")
        load(sugar_path);
        tns = tensor(X);
        min_val = min(tns(:));
        adj_by = -1 * min_val + 10*eps;
        tns(isnan(tns(:)))=0;
        tns = tns + adj_by;
%         tns = reshape(tns,[268, 571,7]);
    else
        disp("Trouble now: dataset(s) requested DNE");
    end
    
    % construct mode bases with Arnoldi
    k = max(size(tns));
    modes = ndims(tns);
    t_construct = tic;
    Us = arnoldi_cp_init(tns,k);
    t_construct = toc(t_construct);

    % collect condition number per number of columns
    % for each constructed basis
    cond_nums = zeros(k, modes);
    for jdx = 1:modes
        for idx = 1:k
            cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
        end
    end

    % collect condition number ratios, i.e. the ratio
    % cond(n+1 columns) / cond(n columns)
    cond_ratios = zeros(k-1,modes);
    for jdx = 1:modes
        for idx = 1:(k-1)
            cond_ratios(idx,jdx) = cond_nums(idx+1,jdx) / cond_nums(idx,jdx);
        end
    end
    
    % SAVE: cond_nums, cond_ratios, Us, t_construct
    results_path = sprintf("results/expr_RW_%s_cond_nums_data_max_k",dataset_names(kdx) ...
        + string(datetime("now")));
    save(results_path, "cond_nums", "cond_ratios", "Us", "t_construct");
end
