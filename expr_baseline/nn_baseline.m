%% Clear the workspace
clear; clc;

%% Create unique directory for experiment run
dirPath = './GSdata_' + string(datetime("now"));
mkdir(dirPath);

%%
% mkdir("./GSdata_" + string(datetime("now")));


%%
% some basic params
sz = [100 100 100];
% R = 5;
num_runs = 1;

gen_types = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
num_gens = length(gen_types);
losses = {'normal' 'rayleigh' 'gamma' 'beta (0.3)'}; % 'huber (0.25)'
num_losses = length(losses);

% containers for results **(move if incorporating cp_opt results)**;
times_opt = zeros(1, num_runs);

fits_opt = zeros(1, num_runs);

% scores_opt = zeros(1, num_runs);
% scores_gcp = zeros(num_losses, num_runs);

% ***(encountering tensor toolbox error of unknown origin,
% *** around log likelihood, troubleshooting) ***

% loglikes_opt = zeros(1, num_runs);  

cossim_opt = zeros(1, num_runs);

% perform a series of runs on a naively generated artificial tensor
t_start = tic;
for type = 1:num_gens
    % *************>   move results container initialization here
    times_gcp = zeros(num_losses, num_runs);
    fits_gcp = zeros(num_losses, num_runs);
    cossim_gcp = zeros(num_losses, num_runs);
    loglikes_gcp = zeros(num_losses, num_runs);
    for run = 1:num_runs
        % Generate tensor
        info = NN_tensor_generator_whole('Size', sz, 'Gen_type', gen_types{type});
        X = info.Data;
        % Estimate rank and initialize guess (based on modal unfolding svd)
        [est_rank, factors] = estRank(X);
        % Perform GCP decompositions for all available loss functions
        for gcp_type = 1:num_losses
            % decompose
            tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, est_rank, 'type', losses{gcp_type},'printitn', 0, 'init', factors);
            % gather metrics
            times_gcp(gcp_type,run) = toc;
            %  CANT USE SCORE, DONT HAVE THE GENERATING K-TENSOR IN THIS
            %  EXPRIMENT *************************************
            %             scores_gcp(gcp_type,run) = score(M_gcp, M_true, 'greedy', false);
            fits_gcp(gcp_type,run) = 1 - norm(X-full(M_gcp))/norm(X);
            loglikes_gcp(gcp_type,run) = tt_loglikelihood(X, M_gcp);
            cossim_gcp(gcp_type,run) = cosSim(X, M_gcp, ndims(X));
        end
    end
    % ****************>  generate and save plots here, 
    figure;
    subplot(1,4,1)
    scatter(categorical(losses), mean(fits_gcp,2))
    title('Fit')
    subplot(1,4,2)
    scatter(categorical(losses), mean(cossim_gcp,2));
    title('Cos Similarity')
    subplot(1,4,3);
    scatter(categorical(losses), mean(loglikes_gcp,2));
    title('Log Likelihood')
    subplot(1,4,4);
    scatter(categorical(losses), mean(times_gcp,2));
    title('Time');
    figure_title = "Non-negative Data (" + gen_types{type} + ")";
    sgtitle(figure_title);
    saveas(gcf, dirPath + "/" + figure_title);
    
    % ****************>  save the data too.
    filepath = dirPath + '/gen_types.csv';
    writecell(gen_types, filepath);
    
    filepath = dirPath + '/losses.csv';
    writecell(losses, filepath);
    
    filepath = dirPath + '/generator_' + gen_types(type) + '_' + string(num_runs) + ' runs_times.csv';
    writematrix(times_gcp, filepath);
    
    filepath = dirPath + '/generator_' + gen_types(type) + '_' + string(num_runs) + ' runs_fits.csv';
    writematrix(fits_gcp, filepath);
    
    filepath = dirPath + '/generator_' + gen_types(type) + '_' + string(num_runs) + ' runs_cosSim.csv';
    writematrix(cossim_gcp, filepath);
    
end
t_total = toc(t_start);
fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_gens, num_runs*num_gens);
fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_gens*num_losses);
% display(num_runs + ' runs, took ' + t_total + 'seconds.');
% display(num_runs + ' runs, using ' + num_gens + ' generators, applying ' + num_losses + ' took ' + t_total + 'seconds.');
%% OLD CODE (expr 1)
for run = 1:num_runs
    % create a problem
%     info = create_problem('Size', size, 'Num_factors', R, 'Factor_Generator', 'rand');
    info = NN_tensor_generator('Size', size, 'Num_factors', R);
    X = info.Data;
    M_true = info.Soln;
    viz(M_true, 'Figure', 1);
    % create a guess
    M_init = create_guess('Data', X, 'Num_factors', R,'Factor_Generator', 'rand');
    M_init = ktensor(M_init);
    
    % feed problem and guess to gcp, cp-opt
    for i = 1:num_losses
        % decompose and compare with gcp
        tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0, 'init', M_init); 
        %tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0);
        times_gcp(i,run) = toc;
        scores_gcp(i,run) = score(M_gcp, M_true, 'greedy', false);
        fits_gcp(i,run) = 1 - norm(X-full(M_gcp))/norm(X);
        %         loglikes_gcp(i,run) = tt_loglikelihood(X, M_gcp);
        cossim_gcp(i,run) = cosSim(X, M_gcp, ndims(X));
%         fprintf('Final fit: %e \n\n', fits_gcp(i,run));
%         viz(M_gcp, 'Figure', i+1);
    end
end

%% one plot to rule them all, higher scores are better
figure;
subplot(1,3,1)
scatter(categorical(losses), mean(fits_gcp,2))
title('Fit')
subplot(1,3,2)
scatter(categorical(losses), mean(scores_gcp,2));
title('Score')
subplot(1,3,3);
scatter(categorical(losses), mean(cossim_gcp,2));
title('Cos Similarity');

sgtitle('Non-negative Data');