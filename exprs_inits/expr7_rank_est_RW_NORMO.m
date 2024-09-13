% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/sugar.mat';
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';
eem_path = '~/datasets/real-world-rank-known/eem/EEM18.mat'
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
tns = tensor(X);

%% load sugar - issue constructing krylov subspace, singular matrices for the factors
load(sugar_path);
tns = tensor(X);

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
Us = cp_init_arnoldi(tns,k);
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
        cond_ratios(idx,jdx) = cond_nums(idx+1,3) / cond_nums(idx,3);
%         cond_scaled_diff(idx,jdx) = 100 * (cond_nums(idx+1, 3) - cond_nums(idx,3));
    end
end

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

%% plot condition numbers and condition number ratios
figure;
for cols = 1:modes
    for rows = 1:2
        subplot(2,modes, (modes * (rows -1) + cols));
        if rows == 1
            plot(cond_nums(1:500,cols));
        else
            plot(cond_ratios(1:500,cols));
        end
    end 
end
