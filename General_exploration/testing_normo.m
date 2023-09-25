%% testing NORMO rank estimation (binary search version, starts at F)
rando = rng("default");
F = 50;
sz = [100 100 100];
losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types
<<<<<<< HEAD
gens = {'rand','randn', 'rayleigh', 'beta', 'gamma'};
num_losses = length(losses);
num_gens = length(gens);
runs = 10;
=======
gens = {'rayleigh'}; % {'rand','randn', 'rayleigh', 'beta', 'gamma'};
num_losses = length(losses);
num_gens = length(gens);
runs = 1;
>>>>>>> 37ca3d0dd555d768333fb35f8a8201a3167594db

ranks = zeros(runs, num_gens);
ranks_time = zeros(runs, num_gens);
fits = zeros(num_gens, runs, num_losses);
corcondias = zeros(num_gens, runs, num_losses);

<<<<<<< HEAD
start_time = tic;
=======
t_start = tic;
>>>>>>> 37ca3d0dd555d768333fb35f8a8201a3167594db
for i = 1:num_gens
    disp("Tensor Generation Type: " + gens{i});
    for j = 1:runs
        % generate tensor
        X = NN_tensor_generator_whole("Size", sz, "Gen_type", gens{i});
        data = double(X.Data);
        % estimate rank
        [ranks(j,i), ranks_time(j,i)] = b_NORMO(data, F, 0.7, rando);
        % initialize solution
        Minit = cp_als(X.Data, ranks(j,i), 'maxiters', 2, 'printitn', 0);
%         Minit = create_guess('Data', X.Data, 'Num_Factors', ranks(j,i), 'Factor_Generator', 'nvecs');
        for k = 1:num_losses
            % perform decomposition
            [M1,M0,out] = gcp_opt(X.Data, ranks(j,i), 'type', losses{k}, 'printitn', 0, 'init', Minit); 
            % collect metrics, index map: tensor gen X runs X loss type
            fits(i,j,k) = fitScore(X.Data, M1);
            corcondias(i,j,k) = efficient_corcondia(X.Data, M1);
        end
    end
end
<<<<<<< HEAD
total_time = toc(start_time);
=======
total_time = toc(t_start);
>>>>>>> 37ca3d0dd555d768333fb35f8a8201a3167594db
disp("total time:\n");
disp(total_time / 60);

%%

