% some basic params
size = [100 100 100];
R = 100;
num_runs = 10;

losses = {'normal' 'bernoulli-odds' 'bernoulli-logit'};
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

for run = 1:num_runs
    % create a problem
    X, M_true, info = create_problem_binary(size, R);
    X = full(X);
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