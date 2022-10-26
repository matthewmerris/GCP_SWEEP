% some basic params
size = [50 50 50];
R = 5;
num_runs = 100;

losses = {'normal' 'huber (0.25)'};
num_losses = length(losses);

% containers for results
times_opt = zeros(1, num_runs);
times_gcp = zeros(num_losses, num_runs);

fits_opt = zeros(1, num_runs);
fits_gcp = zeros(num_losses, num_runs);

scores_opt = zeros(1, num_runs);
scores_gcp = zeros(num_losses, num_runs);

% loglikes_opt = zeros(1, num_runs);
% loglikes_gcp = zeros(num_losses, num_runs);

cossim_opt = zeros(1, num_runs);
cossim_gcp = zeros(num_losses, num_runs);

% perform a series of runs on a naively generated artificial tensor

for run = 1:num_runs
    % create a problem
    info = create_problem('Size', size, 'Num_factors', R);
    X = info.Data;
    M_true = info.Soln;
    % create a guess
    M_init = create_guess('Data', X, 'Num_factors', R,'Factor_Generator', 'nvecs');
    M_init = ktensor(M_init);
    % feed problem and guess to gcp, cp-opt
    for i = 1:num_losses
        % decompose and compare with gcp
        tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0, 'init', M_init); 
        times_gcp(i,run) = toc;
        scores_gcp(i,run) = score(M_gcp, M_true, 'greedy', false);
        fits_gcp(i,run) = 1 - norm(X-full(M_gcp))/norm(X);
%         loglikes_gcp(i,run) = tt_loglikelihood(X, M_gcp);
        cossim_gcp(i,run) = cosSim(X, M_gcp, ndims(X));
%         fprintf('Final fit: %e \n\n', fits_gcp(i,run));
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