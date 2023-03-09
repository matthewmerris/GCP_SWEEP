%% Clear the workspace
clear; clc;

%% Create unique directory for experiment run
% dirPath = './GSdata_AT_' + string(datetime("now"));
% mkdir(dirPath);

%%
% mkdir("./GSdata_" + string(datetime("now")));


%%
% some basic params
sz = [20 20 30];
% R = 5;
num_runs = 100;

% gen_types = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
gen_types = {'rand'};
num_gens = length(gen_types);
losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'};
% losses = {'normal' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);

% containers for results **(move if incorporating cp_opt results)**;
F_maxes = zeros(num_gens*num_runs,1);
Rank_ests = zeros(num_gens*num_runs,1);
% perform a series of runs on a naively generated artificial tensor
t_start = tic;
for type = 1:num_gens
    % *************>   move results container initialization here
    times_gcp = zeros(num_losses, num_runs);
    fits_gcp = zeros(num_losses, num_runs);
    cossim_gcp = zeros(num_losses, num_runs);
    for run = 1:num_runs
        % Generate tensor
        info = NN_tensor_generator_whole('Size', sz, 'Gen_type', gen_types{type});
        X = info.Data;
        % Estimate rank using AutoTen
        F_max = ((sz(1) + 1) * (sz(2) + 1)) / 16;
        F_maxes((type-1)*num_runs + run) = F_max;
        
        [factors,c, est_rank, loss] = AutoTen(X,F_max,1);
        Rank_ests((type-1)*num_runs + run) = est_rank;
    end
    
end
t_total = toc(t_start);
fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_gens, num_runs*num_gens);
fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_gens*num_losses);
% display(num_runs + ' runs, took ' + t_total + 'seconds.');
% display(num_runs + ' runs, using ' + num_gens + ' generators, applying ' + num_losses + ' took ' + t_total + 'seconds.');


