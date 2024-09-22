% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/sugar.mat';
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';
eem_path = '~/datasets/real-world-rank-known/eem/EEM18.mat';
uber_path = '~/datasets/real-world-rank-unknown/tensor_data_uber/uber.mat';

%% load amino data
load(amino_path);
tns = tensor(X);
% % adjust to be non-negative
% min_val = min(X_amino(:));
% adj_by = -1 * min_val + 10*eps;
% X_amino = X_amino + adj_by;

%% load dorrit
load(dorrit_path);
tns = tensor(EEM.data);
min_val = min(tns(:));
adj_by = -1 * min_val + 10*eps;
tns(isnan(tns(:)))=0;
tns = tns + adj_by;
%% load sugar - issue constructing krylov subspace, singular matrices for the factors
load(sugar_path);
tns = tensor(X);
min_val = min(tns(:));
adj_by = -1 * min_val + 10*eps;
tns(isnan(tns(:)))=0;
tns = tns + adj_by;

%% load enron
load(enron_path);
tns = Enron;

%% load eem
load(eem_path);
tns = tensor(X);
%% load uber
load(uber_path);
tns = sptensor(uber);
%%
k = max(size(tns));
modes = ndims(tns);
t_construct = tic;
Us = arnoldi_cp_init(tns,k);
t_construct = toc(t_construct);
cond_nums = zeros(k, modes);

for jdx = 1:modes
    for idx = 1:k
        cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
    end
end

%% looking for the inflection, looks like the cond_ratio is giving best indication of possible rank
cond_ratios = zeros(k-1,modes);
% cond_scaled_diff = zeros(k-1,modes);
for jdx = 1:modes
    for idx = 1:(k-1)
        cond_ratios(idx,jdx) = cond_nums(idx+1,jdx) / cond_nums(idx,jdx);
%         cond_scaled_diff(idx,jdx) = 100 * (cond_nums(idx+1, 3) - cond_nums(idx,3));
    end
end

mode_ks = zeros(modes,1);
for jdx = 1:modes
    tmp_k = 0;
    for idx = 1:(k-1)
        if cond_ratios(idx,jdx) > 1.000001
            tmp_k = idx;
            break;
        end
    end
    mode_ks(jdx,1) = tmp_k;
end

%% plot condition numbers and condition number ratios
figure;
for cols = 1:modes
    for rows = 1:2
        subplot(2,modes, (modes * (rows -1) + cols));
        if rows == 1
            plot(cond_nums(1:460,cols));
        else
            plot(cond_ratios(1:460,cols));
        end
    end 
end

%% compare CORCONDIA (1), NORMO(2), and ARNOLDI (3) fits
ranks_enron = [12 11 21];
num_decomps = length(ranks_enron);
num_runs = 10;
M_inits = cell(num_decomps,1);
M_fins = cell(num_runs,num_decomps);
outs = cell(num_runs, num_decomps);

% isolate arnoldi initializations for each rank
for jdx = 1:num_decomps
    tmp_U = cell(modes, 1);
    for idx = 1:modes
        tmp_U{idx,1} = Us{idx,1}(:,1:ranks_enron(jdx));
    end
    M_inits{jdx,1} = tmp_U;
end

% perform decompositions
for kdx = 1:num_runs
    for jdx = 1:num_decomps
        [M_fins{kdx,jdx}, ~, outs{kdx,jdx}] = cp_als(tns, ranks_enron(jdx), 'init', M_inits{jdx,1}, 'printitn',0, 'maxiters', 1000);
    end
end





