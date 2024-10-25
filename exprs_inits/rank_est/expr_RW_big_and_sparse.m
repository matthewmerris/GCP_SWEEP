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

%% Enron rank estimate - rank(8,6,6)
% rank(15,12,11) @ 1.0e-13 tolerance
num_modes = length(raw_Us{1,1});
[~,num_cols] = size(raw_Us{1,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{1}(1:15,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(1));
sgtitle(tmp_ttl);

%% vast3d rank estimate - rank(5,4,2)  ** 3rd mode CNs are unique in behavior (mode-3 is size 2, likely the culprit) **
% rank(8,10,3) @ 1.0e-13 tolerance
num_modes = length(raw_Us{2,1});
[~,num_cols] = size(raw_Us{2,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{2}(1:100,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(2));
sgtitle(tmp_ttl);

%% nell2 rank estimate - rank(5,4,3) ** really takes off at 5 on all **
% rank(9,8,9) @ 1.0e-13 tolerance
num_modes = length(raw_Us{3,1});
[~,num_cols] = size(raw_Us{3,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{3}(1:10,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(3));
sgtitle(tmp_ttl);

%% uber rank estimate - rank(6,8,12,6) @ 1.0e-13 tolerance
num_modes = length(raw_Us{4,1});
[~,num_cols] = size(raw_Us{4,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{4}(1:24,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(4));
sgtitle(tmp_ttl);

%% chi rank estimate - rank(3,7,6,9)
% rank(4,8,11,13) @ 1.0e-13 tolerance
num_modes = length(raw_Us{5,1});
[~,num_cols] = size(raw_Us{5,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{5}(1:12,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(5));
sgtitle(tmp_ttl);

%% chi_2019 rank estimate - rank(5,6,7,9)
% rank(5,8,13,8) @ 1.0e-13 tolerance
num_modes = length(raw_Us{6,1});
[~,num_cols] = size(raw_Us{6,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{6}(1:12,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(6));
sgtitle(tmp_ttl);

%% nips rank estimate - rank(3,6,3)
% rank(7,10,5) @ 1.0e-13 tolerance
num_modes = length(raw_Us{7,1});
[~,num_cols] = size(raw_Us{7,1}{1});
figure;
for mdx = 1:num_modes
    subplot(1,num_modes,mdx);
    plot(raw_CNs{7}(1:10,mdx));
    if mdx == 1
        ylabel("Condition Number");
    end
    xlabel("Columns");
end
tmp_ttl = sprintf(dataset_names(7));
sgtitle(tmp_ttl);