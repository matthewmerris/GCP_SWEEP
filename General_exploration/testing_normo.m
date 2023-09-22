%% testing NORMO rank estimation (binary search version, starts at F)
rando = rng("default");
F = 50;
sz = [100 100 100];
losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types
gens = {'rand'}; %,'randn', 'rayleigh', 'beta', 'gamma'};
num_losses = length(losses);
num_gens = length(gens);
runs = 4;

ranks = zeros(runs, num_gens);
ranks_time = zeros(runs, num_gens);
fits = zeros(runs, num_losses);
corcondias = zeros(runs, num_losses);

tic;
for i = 1:num_gens
    for j = 1:runs
        % generate tensor
        X = NN_tensor_generator_whole("Size", sz, "Gen_type", gens{i});
        data = double(X.Data);
        % estimate rank
        [ranks(j,i), ranks_time(j,i)] = b_NORMO(data, F, 0.7, rando);
        % initialize solution
        Minit = cp_als(X.Data, ranks(j,i), 'maxiters', 10, 'printitn', 0);
        for k = 1:num_losses
            % perform decomposition
            [M1,M0,out] = gcp_opt(X.Data, ranks(j,i), 'type', losses{k}, 'printitn', 0, 'init', Minit); 
            % collect metrics
            fits(j,k) = fitScore(X.Data, M1);
            corcondias(j,k) = efficient_corcondia(X.Data, M1);
        end
    end
end
total_time = toc;
disp("total time:\n");
disp(total_time);

%%

