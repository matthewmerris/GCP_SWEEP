%% Exploring GCP hypothesis using real-world, non-negative data of known rank

% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/data.mat'; 

% all datasets are known to be of rank 4, verified via domain experts
nc = 3; 

%% load amino data
load(amino_path);
X_amino = tensor(X);
% adjust to be non-negative
min_val = min(X_amino(:));
adj_by = -1 * min_val + 10*eps;
X_amino = X_amino + adj_by;

%% Perform decompositions of amino data and collect metrics
losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);
runs = 100;
sz = size(X_amino);
rand_fit_results = zeros(runs,num_losses);
rand_cossim_results = zeros(runs,num_losses);
rand_time_results = zeros(runs,num_losses);
rand_corcondia_results = zeros(runs,num_losses);
for j = 1:num_losses
    rng('default');  % ensure a set of runs gets the same initialization for each loss
    for i = 1:runs
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_amino, nc, 'type', losses{j}, 'printitn', 0);
        % collect metrics
        rand_fit_results(i,j) = fitScore(X_amino, M1);
        rand_cossim_results(i,j) = cosSim(X_amino, M1, 3);
        rand_time_results(i,j) = out.mainTime;
        [rand_corcondia_results(i,j),~] = efficient_corcondia(X_amino, M1);
    end
end

%% load dorrit data
load(dorrit_path);
X_dorrit = tensor(EEM.data);
min_val = min(X_dorrit(:));
adj_by = -1 * min_val + 10*eps;
X_dorrit(isnan(X_dorrit(:)))=0;
X_dorrit = X_dorrit + adj_by;

nc = 4;

rand_fit_results_dorrit = zeros(runs,num_losses);
rand_cossim_results_dorrit = zeros(runs,num_losses);
rand_time_results_dorrit = zeros(runs,num_losses);
rand_corcondia_results_dorrit = zeros(runs,num_losses);
for j = 1:num_losses
    rng('default');  % ensure a set of runs gets the same initialization for each loss
    for i = 1:runs
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_dorrit, nc, 'type', losses{j}, 'printitn', 0);
        % collect metrics
        rand_fit_results_dorrit(i,j) = fitScore(X_dorrit, M1);
        rand_cossim_results_dorrit(i,j) = cosSim(X_dorrit, M1, 3);
        rand_time_results_dorrit(i,j) = out.mainTime;
        [rand_corcondia_results_dorrit(i,j),~] = efficient_corcondia(X_dorrit, M1);
    end
end



