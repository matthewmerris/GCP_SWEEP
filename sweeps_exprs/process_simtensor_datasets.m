num_tensors = 10;
% gens = ["rand","randn","randn_multi","gamma","ortho","sto","binary"];
gens = ["rand","randn","gamma","orthogonal","stochastic"];
num_gens = length(gens);

data_tensors = cell(num_gens, num_tensors);

%% nonneg - replace zeros with eps
for idx = 1:num_gens
    % prep general filepath
    data_dir = sprintf("./datasets_simtensor/expr1_datasets/");
    for jdx = 1:num_tensors
        data_path = sprintf("%s_%d.mat",gens{idx},jdx);
        data_path = data_dir + data_path;
        tmp_data = load(data_path);
%         data_tensors{idx,jdx} = tmp_data.X;
        tmp_tns = tmp_data.X.data;
        % add eps to all zero value entries
        tmp_tns(tmp_tns == 0) = eps;
        data_tensors{idx,jdx} = tensor(tmp_tns);
    end
end

%% adjust - add (min_val + eps) to all entries
for idx = 1:num_gens
    % prep general filepath
    data_dir = sprintf("./datasets_simtensor/expr1_datasets_adjust/");
    for jdx = 1:num_tensors
        data_path = sprintf("%s_%d.mat",gens{idx},jdx);
        data_path = data_dir + data_path;
        tmp_data = load(data_path);
        tmp_tns = tmp_data.X;
        min_val = min(tmp_tns.data,[],"all");
        tmp_tns = plus(tmp_tns, (-min_val + 10*eps));
        data_tensors{idx,jdx} = tmp_tns;
    end
end

%%
% save_path = data_dir + "simtensor_datasets.mat";
save_path = sprintf("./datasets_simtensor/simtensor_datasets.mat");
save(save_path, "data_tensors", "gens","num_tensors","num_gens");