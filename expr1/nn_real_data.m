% some basic params
size = [100 100 100];
R = 5;
num_runs = 1;

losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'};
num_losses = length(losses);

% containers for results
times_opt = zeros(1, num_runs);
times_gcp = zeros(num_losses, num_runs);

fits_opt = zeros(1, num_runs);
fits_gcp = zeros(num_losses, num_runs);

scores_opt = zeros(1, num_runs);
scores_gcp = zeros(num_losses, num_runs);

% perform a series of runs on a naively generated artificial tensor

for run = 1:num_runs
    % create a problem
%     info = create_problem('Size', size, 'Num_factors', R, 'Factor_Generator', 'rand');
    info = NN_tensor_generator('Size', size, 'Num_factors', R);
    X = info.Data;
    M_true = info.Soln;
    viz(M_true, 'Figure', 1);
    % create a guess
    M_init = create_guess('Data', X, 'Num_factors', R,'Factor_Generator', 'nvecs');
    M_init = ktensor(M_init);
    
    % feed problem and guess to gcp, cp-opt
    for i = 1:num_losses
        % decompose and compare with gcp
        %tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0, 'init', M_init); 
        tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0);
        times_gcp(i,run) = toc;
        scores_gcp(i,run) = score(M_gcp, M_true, 'greedy', false);
        fits_gcp(i,run) = 1 - norm(X-full(M_gcp))/norm(X);
        fprintf('Final fit: %e \n\n', fits_gcp(i,run));
        viz(M_gcp, 'Figure', i+1);
    end
end


