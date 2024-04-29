%% Exploring the Enron Emails tensor from FROSTT
% Order:        3
% Dimensions:   184 (sender) x 184 (receiver) x 44 (months)
% Data set constructed as per described in the DEDICOM paper
% http://www.cis.jhu.edu/~parky/Enron
% open the files, all of em for now

raw_data = dlmread('~/datasets/real-world-rank-unknown/FROSTT/Enron/DEDICOM-style/enron_counts.csv');
enron = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;

%% Experiment parameters
sz = size(enron);
nc = 11;     % NORMO paper estimate for enron tensor
num_runs = 100;
losses = {'count' 'poisson-log' 'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);
factor_init = 'rand';


%% Set up results containers
inits = cell(num_runs);
fest_traces = cell(num_runs, num_losses);

fits = zeros(num_runs, num_losses);          
cossims = zeros(num_runs, num_losses);
times = zeros(num_runs, num_losses);
corcondias = zeros(num_runs, num_losses);
rmses = zeros(num_runs, num_losses);
objectives = zeros(num_runs, num_losses);
angles = cell(num_runs, num_losses);
%%
best_fits = zeros(num_losses,1);
best_cossims = zeros(num_losses,1);
best_times = zeros(num_losses,1);
best_corcondias = zeros(num_losses,1);
best_rmses = zeros(num_losses,1);
best_objectives = zeros(num_losses,1);


%% off to the races

parpool(16);

% Generate initializations
for i = 1:num_runs
    inits{i} = create_guess('Data', enron,'Num_Factors', nc,'Factor_Generator', factor_init);
end

t_start = tic;
parfor i = 1:num_runs
    % generate a random initialization
%     M_init = create_guess('Data', enron,'Num_Factors', 7);
    M_init = inits{i};
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(enron, nc, 'type', losses{j},'init', M_init, 'printitn',0, 'maxiters', 5000);
        fits(i,j) = fitScore(enron, M1);
        cossims(i,j) = cosSim(enron, M1, 3);
        times(i,j) = out.mainTime;
        [corcondias(i,j),~] = efficient_corcondia(enron, M1);
        rmses(i,j) = rms_err(enron,M1);
        objectives(i,j) = out.fest_trace(end);
        fest_traces{i,j} = out.fest_trace;
        angles{i,j} = subspaceAngles(full(enron), M1);
    end
    fprintf("Run %d complete.\n", i);
end
toc(t_start);

delete(gcp("nocreate"));

%% collect best metrics

for i = 1:num_losses
    best_fits(i) = squeeze(max(fits(:,i)));
    best_cossims(i) = squeeze(max(cossims(:,i)));
    best_times(i) = squeeze(min(times(:,i)));
    best_corcondias(i) = squeeze(max(corcondias(:,i)));
    best_rmses(i) = squeeze(min(rmses(:,i)));
    best_objectives(i) = squeeze(min(objectives(:,i)));
end

%% save results
results_filename = sprintf('results/Enron-%s-init_%d-losses_%d-runs', ...b
    factor_init, num_losses, num_runs)+ string(datetime("now"));
save(results_filename, 'losses', 'fits', 'cossims', 'times',...
    'corcondias','angles', 'rmses','objectives',...
    'best_fits', 'best_cossims','best_times', 'best_objectives',...
    'best_corcondias', 'best_rmses','num_runs',...
    'num_losses');

data_filename = strcat(results_filename,'_data.mat');
m = matfile(data_filename,'Writable',true);
m.inits = inits;
m.fest_traces = fest_traces;