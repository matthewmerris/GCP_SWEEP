clear all;close all;clc

% Initialization details and results containers
% size and rank
sz = [100 80 60];
R = 10;
num_runs = 500;

% zero out results are for:
% time
times_opt = zeros(1, num_runs);
times_gcp = zeros(1, num_runs);
times_apr = zeros(1, num_runs);
% fit
fits_opt = zeros(1, num_runs);
fits_gcp = zeros(1, num_runs);
fits_apr = zeros(1, num_runs);
% score
scores_opt = zeros(1, num_runs);
scores_gcp = zeros(1, num_runs);
scores_apr = zeros(1, num_runs);

% run multiple experiments
for run = 1:num_runs
    A = cell(3,1);
    for n = 1:length(sz)
        A{n} = rand(sz(n), R);
        for r = 1:R
            p = randperm(sz(n));
            nbig = round( (1/R)*sz(n) );
            A{n}(p(1:nbig),r) = 100 * A{n}(p(1:nbig),r);
        end
    end
    lambda = rand(R,1);
    S = ktensor(lambda, A);
    S = normalize(S, 'sort', 1);
    
    % create sparse test problem based on provided solution
    nz = prod(sz) * .01;
    info = create_problem('Soln', S, 'Sparse_Generation', nz);

    % extract data and solution
    X = info.Data;
    M_true = info.Soln;
    
    % create initial guess based on perturbation of solution
    M_init = create_guess('Soln', M_true, 'Factor_Generator', 'pertubation', 'Pertubation', 0.05);
    M_init = ktensor(M_init);
    
    % decompose and collect results
    % GCP
    tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', 'count','printitn', 0, 'init', M_init); 
    times_gcp(run) = toc;
    scores_gcp(run) = score(M_gcp, M_true, 'greedy', false);
    fits_gcp(run) = 1 - norm(X-full(M_gcp))/norm(X);
    fprintf('Final fit: %e \n\n', fits_gcp(run));
    % OPT
    tic, [M_als, M_0_als, out_cp] = cp_opt(X, R, 'init', M_init); 
    times_opt(run) = toc;
    scores_opt(run) = score(M_als, M_true, 'greedy', false);
    fits_opt(run) = 1 - norm(X-full(M_als))/norm(X);
    fprintf('Final fit: %e \n\n', fits_opt(run));
    % APR
    tic, [M_apr, M_0_apr, out_apr] = cp_apr(X, R, 'init', M_init, 'printitn', 10);
    times_apr(run) = toc;
    scores_apr(run) = score(M_apr, M_true, 'greedy', false);
    fits_apr(run) = 1 - norm(X-full(M_apr))/norm(X);
    fprintf('Final fit: %e \n\n', fits_apr(run));
end

%% Plot data - 1 (mean score vs mean time)
figure
plot(mean(scores_gcp), mean(times_gcp), '+')
hold on
plot(mean(scores_opt), mean(times_opt), 'ro')
plot(mean(scores_apr), mean(times_apr), 'go')
hold off
legend('gcp_opt', 'cp_opt', 'cp_apr')
xlabel('Score')
ylabel('Time(secs)')

%% Plot data - 2 (mean fit vs mean time)
figure
plot(mean(fits_gcp), mean(times_gcp), '+')
hold on
plot(mean(fits_opt), mean(times_opt), 'ro')
plot(mean(fits_apr), mean(times_apr), 'go')
hold off
legend('gcp_opt', 'cp_opt', 'cp_apr')
xlabel('Fit')
ylabel('Time(secs)')

%% Plot data - 3 (mean score vs mean fit vs mean time)
figure
scatter3(mean(scores_gcp), mean(fits_gcp), mean(times_gcp), '+')
hold on 
scatter3(mean(scores_opt), mean(fits_opt), mean(times_opt), 'ro')
scatter3(mean(scores_apr), mean(fits_apr), mean(times_apr), 'go')
hold off
legend('gcp_{opt}', 'cp_{opt}', 'cp_{apr}')
xlabel('Score')
ylabel('Fit')
zlabel('Time(secs)')

%% Plot data - 4 (mean scores w/ error bar)
figure
errorbar(mean(scores_gcp), std(scores_gcp), '+')
hold on
errorbar(mean(scores_opt), std(scores_opt), 'ro')
errorbar(mean(scores_apr), std(scores_apr), 'go')
hold off