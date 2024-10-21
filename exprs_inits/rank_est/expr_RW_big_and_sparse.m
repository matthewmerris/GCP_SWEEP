% Set data file paths
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';
vast3d_path = '~/datasets/FROSTT/vast_2015_mini/vast-2015-mc1-3d.tns';
nell2_path = '~/datasets/FROSTT/nell2/nell-2.tns';
uber_path = '~/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';
chi_path = '~/datasets/real-world-rank-unknown/tensor_data_chicago_crime/chicago_crime.mat';
chi_2019_path = '~/datasets/real-world-rank-unknown/tensor_data_chicago_crime/chicago_crime_2019.mat';
nips_path = '~/datasets/FROSTT/nips/nips.tns';
dataset_names = [ "enron","vast3d","nell2","uber", "chicago", "chicago_2019", "nips"];
dataset_paths = {enron_path, vast3d_path, nell2_path, uber_path, chi_path, chi_2019_path, nips_path};
num_tensors = length(dataset_paths);

%%
raw_times = zeros(num_tensors,1);
raw_Us = cell(num_tensors,1);
raw_CNs = cell(num_tensors,1);
raw_CN_ratios = cell(num_tensors,1);
rng(1339);
for kdx = 1:num_tensors
    sprintf("Dataset: %s", dataset_names(kdx))
    if strcmp(dataset_names(kdx),"enron")
        load(dataset_paths{kdx});
        tns = sptensor(Enron);
    elseif strcmp(dataset_names(kdx),"uber")
        load(dataset_paths{kdx});
        tns = sptensor(uber);
    elseif strcmp(dataset_names(kdx),"chicago") || strcmp(dataset_names(kdx),"chicago_2019")
        load(dataset_paths{kdx});
        tns = sptensor(X);
    elseif strcmp(dataset_names{kdx}, "lbnl")
        tns = load_frostt(dataset_paths{kdx});
        tns = tns(:,:,:,:,1:86400);
    elseif strcmp(dataset_names{kdx}, "nips")
        tns = load_frostt(dataset_paths{kdx});
        tns = squeeze(tns(:,:,:,1));
    elseif strcmp(dataset_names(kdx),"vast5d") || strcmp(dataset_names(kdx),"vast3d") ...
            || strcmp(dataset_names(kdx),"nell2") || strcmp(dataset_names(kdx),"del4d") ...
            || strcmp(dataset_names(kdx),"del3d")
        tns = load_frostt(dataset_paths{kdx});
    else
        disp("Trouble now: dataset(s) requested DNE");
    end
    
    % construct mode bases with Arnoldi
    k = max(size(tns));
    if k > 100
        k = 100;
    end
    modes = ndims(tns);
    t_construct = tic;
    Us = arnoldi_cp_init(tns,k);
    t_construct = toc(t_construct);
    raw_times(kdx,1) = t_construct;
    raw_Us{kdx,1} = Us;

    % collect condition number per number of columns
    % for each constructed basis
    cond_nums = zeros(k, modes);
    for jdx = 1:modes
        for idx = 1:k
            cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
        end
    end
    raw_CNs{kdx,1} = cond_nums;

    % collect condition number ratios, i.e. the ratio
    % cond(n+1 columns) / cond(n columns)
    cond_ratios = zeros(k-1,modes);
    for jdx = 1:modes
        for idx = 1:(k-1)
            cond_ratios(idx,jdx) = cond_nums(idx+1,jdx) / cond_nums(idx,jdx);
        end
    end
    raw_CN_ratios{kdx,1} = cond_ratios;
    

end

%% SAVE: cond_nums, cond_ratios, Us, t_construct
results_path = sprintf("results/expr_RW_big_and_sparse_" + string(datetime("now")));
save(results_path, "raw_times", "raw_Us", "raw_CNs", "raw_CN_ratios", "dataset_names");

%% start with Enron
num_modes = length(raw_Us{1,1});
[~,num_cols] = size(raw_Us{1,1}{1});
figure;
subplot(1,num_modes,1);
plot(raw_CNs{1}(1:10,1));
subplot(1,num_modes,2);
plot(raw_CNs{1}(1:10,2));
subplot(1,num_modes,3);
plot(raw_CNs{1}(1:10,3));
