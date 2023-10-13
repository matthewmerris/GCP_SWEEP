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
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);
runs = 100;
sz = size(X_amino);
amino_fits = zeros(runs,num_losses);
amino_cossims = zeros(runs,num_losses);
amino_corcondias = zeros(runs,num_losses);
amino_times = zeros(runs,num_losses);

for i = 1:runs
    M_init = create_guess('Data', X_amino,'Num_Factors', nc);
%     M_init = create_guess('Data', X_amino,'Num_Factors', nc,'Factor_Generator', 'nvecs');
    for j = 1:num_losses
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_amino, nc, 'type', losses{j}, 'printitn', 0, 'init', M_init);
        % collect metrics
        amino_fits(i,j) = fitScore(X_amino, M1);
        amino_cossims(i,j) = cosSim(X_amino, M1, 3);
        amino_times(i,j) = out.mainTime;
        [amino_corcondias(i,j),~] = efficient_corcondia(X_amino, M1);
    end
end
clear X_amino;

%% load dorrit data
load(dorrit_path);
X_dorrit = tensor(EEM.data);
min_val = min(X_dorrit(:));
adj_by = -1 * min_val + 10*eps;
X_dorrit(isnan(X_dorrit(:)))=0;
X_dorrit = X_dorrit + adj_by;

nc = 4;

dorrit_fits = zeros(runs,num_losses);
dorrit_cossims = zeros(runs,num_losses);
dorrit_times = zeros(runs,num_losses);
dorrit_corcondias = zeros(runs,num_losses);

for i = 1:runs
    M_init = create_guess('Data', X_dorrit,'Num_Factors', nc);
%     M_init = create_guess('Data', X_dorrit,'Num_Factors', nc,'Factor_Generator', 'nvecs');
    for j = 1:num_losses
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_dorrit, nc, 'type', losses{j}, 'printitn', 0, 'init', M_init);
        % collect metrics
        amino_fits(i,j) = fitScore(X_dorrit, M1);
        amino_cossims(i,j) = cosSim(X_dorrit, M1, 3);
        amino_times(i,j) = out.mainTime;
        [amino_corcondias(i,j),~] = efficient_corcondia(X_dorrit, M1);
    end
end



