%% Exploring GCP hypothesis using real-world, non-negative data of known rank

% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/data.mat'; 

% all datasets are known to be of rank 4, verified via domain experts
% some indication that amino and dorrit may be rank 3
nc = 4; 

%% load amino data
load(amino_path);
X_amino = tensor(X);
% adjust to be non-negative
min_val = min(X_amino(:));
adj_by = -1 * min_val + 10*eps;
X_amino = X_amino + adj_by;

%% Perform decompositions of amino data and collect metrics
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)' 'Poisson' 'Poisson-log'}; % GCP loss types
num_losses = length(losses);
num_runs = 100;
sz = size(X_amino);
factor_init = 'rand';

%% Set up results containers
amino_inits = cell(num_runs);
amino_fest_traces = cell(num_runs, num_losses);

amino_fits = zeros(num_runs,num_losses);
amino_cossims = zeros(num_runs, num_losses);
amino_times = zeros(num_runs, num_losses);
amino_corcondias = zeros(num_runs, num_losses);
amino_rmses = zeros(num_runs, num_losses);
amino_objectives = zeros(num_runs, num_losses);
amino_angles = cell(num_runs, num_losses);

best_amino_fits = zeros(num_losses,1);
best_amino_cossims = zeros(num_losses,1);
best_amino_times = zeros(num_losses,1);
best_amino_corcondias = zeros(num_losses,1);
best_amino_rmses = zeros(num_losses,1);
best_amino_objectives = zeros(num_losses,1);

%% Gather results
% Generate initializations
for i = 1:num_runs
    amino_inits{i} = create_guess('Data', X_amino,'Num_Factors', nc,'Factor_Generator', factor_init);
end

parpool(16);
c_losses = parallel.pool.Constant(losses);
t_start = tic;
parfor i = 1:num_runs
    % generate a random initialization
%     M_init = create_guess('Data', enron,'Num_Factors', 7);
    M_init = amino_inits{i};
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(X_amino, nc, 'type', c_losses.Value{j},'init', M_init, ...
            'opt', 'adam','printitn',0, 'maxiters', 5000);
        amino_fits(i,j) = fitScore(X_amino, M1);
        amino_cossims(i,j) = cosSim(X_amino, M1, 3);
        amino_times(i,j) = out.mainTime;
        [amino_corcondias(i,j),~] = efficient_corcondia(X_amino, M1);
        amino_rmses(i,j) = rms_err(X_amino,M1);
        amino_objectives(i,j) = out.fest_trace(end);
        amino_fest_traces{i,j} = out.fest_trace;
        amino_angles{i,j} = subspaceAngles(full(X_amino), M1);
    end
    fprintf("Run %d complete.\n", i);
end
toc(t_start);

% gather best results
for i = 1:num_losses
    best_amino_fits(i) = squeeze(max(amino_fits(:,i)));
    best_amino_cossims(i) = squeeze(max(amino_cossims(:,i)));
    best_amino_times(i) = squeeze(min(amino_times(:,i)));
    best_amino_corcondias(i) = squeeze(max(amino_corcondias(:,i)));
    best_amino_rmses(i) = squeeze(min(amino_rmses(:,i)));
    best_amino_objectives(i) = squeeze(min(amino_objectives(:,i)));
end

delete(gcp("nocreate"));



%% Save amino results
amino_results_path = sprintf('results/amino_rand-init_%d-runs_%d-losses',num_runs, num_losses) ...
    + string(datetime("now"));
save(amino_results_path, 'losses', 'amino_fits', 'amino_cossims', ...
     'amino_times', 'amino_corcondias', 'amino_rmses', 'amino_objectives', ...
     'amino_fest_traces','amino_angles', ...
     'best_amino_fits', 'best_amino_cossims', 'best_amino_times', ...
     'best_amino_corcondias', 'best_amino_rmses', 'best_amino_objectives', ...
     'amino_inits');

%% Dorrit Experiment
load(dorrit_path);
X_dorrit = tensor(EEM.data);
min_val = min(X_dorrit(:));
adj_by = -1 * min_val + 10*eps;
X_dorrit(isnan(X_dorrit(:)))=0;
X_dorrit = X_dorrit + adj_by;

dorrit_inits = cell(num_runs);
dorrit_fest_traces = cell(num_runs, num_losses);

dorrit_fits = zeros(num_runs,num_losses);
dorrit_cossims = zeros(num_runs, num_losses);
dorrit_times = zeros(num_runs, num_losses);
dorrit_corcondias = zeros(num_runs, num_losses);
dorrit_rmses = zeros(num_runs, num_losses);
dorrit_objectives = zeros(num_runs, num_losses);
dorrit_angles = cell(num_runs, num_losses);

best_dorrit_fits = zeros(num_losses,1);
best_dorrit_cossims = zeros(num_losses,1);
best_dorrit_times = zeros(num_losses,1);
best_dorrit_corcondias = zeros(num_losses,1);
best_dorrit_rmses = zeros(num_losses,1);
best_dorrit_objectives = zeros(num_losses,1);

% Generate initializations
for i = 1:num_runs
    dorrit_inits{i} = create_guess('Data', X_dorrit,'Num_Factors', nc,'Factor_Generator', factor_init);
end

parpool(16);
c_losses = parallel.pool.Constant(losses);
t_start = tic;
parfor i = 1:num_runs
    % generate a random initialization
%     M_init = create_guess('Data', enron,'Num_Factors', 7);
    M_init = dorrit_inits{i};
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(X_dorrit, nc, 'type', c_losses.Value{j},'init', M_init, ...
            'opt', 'adam','printitn',0, 'maxiters', 5000);
        dorrit_fits(i,j) = fitScore(X_dorrit, M1);
        dorrit_cossims(i,j) = cosSim(X_dorrit, M1, 3);
        dorrit_times(i,j) = out.mainTime;
        [dorrit_corcondias(i,j),~] = efficient_corcondia(X_dorrit, M1);
        dorrit_rmses(i,j) = rms_err(X_dorrit,M1);
        dorrit_objectives(i,j) = out.fest_trace(end);
        dorrit_fest_traces{i,j} = out.fest_trace;
        dorrit_angles{i,j} = subspaceAngles(full(X_dorrit), M1);
    end
    fprintf("Run %d complete.\n", i);
end
toc(t_start);

delete(gcp("nocreate"));

% gather best results
for i = 1:num_losses
    best_dorrit_fits(i) = squeeze(max(dorrit_fits(:,i)));
    best_dorrit_cossims(i) = squeeze(max(dorrit_cossims(:,i)));
    best_dorrit_times(i) = squeeze(min(dorrit_times(:,i)));
    best_dorrit_corcondias(i) = squeeze(max(dorrit_corcondias(:,i)));
    best_dorrit_rmses(i) = squeeze(min(dorrit_rmses(:,i)));
    best_dorrit_objectives(i) = squeeze(min(dorrit_objectives(:,i)));
end

% Save dorrit results
dorrit_results_path = sprintf('results/dorrit_rand-init_%d-runs_%d-losses',num_runs, num_losses) ...
    + string(datetime("now"));
save(dorrit_results_path, 'losses', 'dorrit_fits', 'dorrit_cossims', ...
     'dorrit_times', 'dorrit_corcondias', 'dorrit_rmses', 'dorrit_objectives', ...
     'dorrit_fest_traces','dorrit_angles', ...
     'best_dorrit_fits', 'best_dorrit_cossims', 'best_dorrit_times', ...
     'best_dorrit_corcondias', 'best_dorrit_rmses', 'best_dorrit_objectives', ...
     'dorrit_inits');

%% Sugar experiments
load(sugar_path);
X_sugar = tensor(reshape(X,268,571,7));
min_val = min(X_sugar(:));
adj_by = -1 * min_val + 10*eps;
X_sugar = X_sugar + adj_by;

losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)' 'Poisson' 'Poisson-log'}; % GCP loss types
num_losses = length(losses);
num_runs = 100;
sz = size(X_sugar);
factor_init = 'rand';

%% containers and results generation
sugar_inits = cell(num_runs);
sugar_fest_traces = cell(num_runs, num_losses);

sugar_fits = zeros(num_runs,num_losses);
sugar_cossims = zeros(num_runs, num_losses);
sugar_times = zeros(num_runs, num_losses);
sugar_corcondias = zeros(num_runs, num_losses);
sugar_rmses = zeros(num_runs, num_losses);
sugar_objectives = zeros(num_runs, num_losses);
sugar_angles = cell(num_runs, num_losses);

best_sugar_fits = zeros(num_losses,1);
best_sugar_cossims = zeros(num_losses,1);
best_sugar_times = zeros(num_losses,1);
best_sugar_corcondias = zeros(num_losses,1);
best_sugar_rmses = zeros(num_losses,1);
best_sugar_objectives = zeros(num_losses,1);

% Generate initializations
for i = 1:num_runs
    sugar_inits{i} = create_guess('Data', X_sugar,'Num_Factors', nc,'Factor_Generator', factor_init);
end

parpool(16);
c_losses = parallel.pool.Constant(losses);
t_start = tic;
parfor i = 1:num_runs
    % generate a random initialization
%     M_init = create_guess('Data', enron,'Num_Factors', 7);
    M_init = sugar_inits{i};
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(X_sugar, nc, 'type', c_losses.Value{j},'init', M_init, ...
            'opt', 'adam','printitn',0, 'maxiters', 5000);
        sugar_fits(i,j) = fitScore(X_sugar, M1);
        sugar_cossims(i,j) = cosSim(X_sugar, M1, 3);
        sugar_times(i,j) = out.mainTime;
        [sugar_corcondias(i,j),~] = efficient_corcondia(X_sugar, M1);
        sugar_rmses(i,j) = rms_err(X_sugar,M1);
        sugar_objectives(i,j) = out.fest_trace(end);
        sugar_fest_traces{i,j} = out.fest_trace;
        sugar_angles{i,j} = subspaceAngles(full(X_sugar), M1);
    end
    fprintf("Run %d complete.\n", i);
end
toc(t_start);
delete(gcp("nocreate"));

% gather best results
for i = 1:num_losses
    best_sugar_fits(i) = squeeze(max(sugar_fits(:,i)));
    best_sugar_cossims(i) = squeeze(max(sugar_cossims(:,i)));
    best_sugar_times(i) = squeeze(min(sugar_times(:,i)));
    best_sugar_corcondias(i) = squeeze(max(sugar_corcondias(:,i)));
    best_sugar_rmses(i) = squeeze(min(sugar_rmses(:,i)));
    best_sugar_objectives(i) = squeeze(min(sugar_objectives(:,i)));
end

% Save sugar results
sugar_results_path = sprintf('results/sugar_rand-init_%d-runs_%d-losses',num_runs, num_losses) ...
    + string(datetime("now"));
save(sugar_results_path, 'losses', 'sugar_fits', 'sugar_cossims', ...
     'sugar_times', 'sugar_corcondias', 'sugar_rmses', 'sugar_objectives', ...
     'sugar_fest_traces','sugar_angles', ...
     'best_sugar_fits', 'best_sugar_cossims', 'best_sugar_times', ...
     'best_sugar_corcondias', 'best_sugar_rmses', 'best_sugar_objectives', ...
     'sugar_inits');