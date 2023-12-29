%% Clear the workspace & set up random seed
clear; clc;

%% ADD NESSARY PATH INFO (** BORAH SPECIFIC **)
% experimental code
expr_path = "/bsuhome/mmerris/GCP_SWEEP";
addpath(genpath(expr_path));

% dependencies
tt_path = "/bsuhome/mmerris/wares/matlab_tools/tensor_toolbox";
addpath(genpath(tt_path));
autoten_path = "/bsuhome/mmerris/wares/matlab_tools/AutoTen";
addpath(genpath(autoten_path));
normo_path = "/bsuhome/mmerris/wares/matlab_tools/NORMO";
addpath(genpath(normo_path));
nway_path = "/bsuhome/mmerris/wares/matlab_tools/NwayTBv3.5";
addpath(genpath(nway_path));

%% check for results directory, make it if not there
datafolder = "results";
if ~isfolder(datafolder)
    mkdir(datafolder)
end

%% general experiment paramenters
rng("shuffle"); % seed based on current time

% tensor size & number of modes
sz = [100, 100, 100]; 
num_modes = length(sz);
F = floor(max(sz)/2);

% tensor generators | number of generators
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
% gens = {'rand'};
num_gens = length(gens);

% number of tensors generated per generator 
num_tensors = 10;
num_runs = 10;          % number of runs, 1 run performs a GCP decomposition 
                        %
% GCP losses | number of GCP loss functions
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);

%% generate tensor, estimate rank, and generate initializations

tensors = cell(num_tensors, num_gens);
ranks = zeros(num_tensors, num_gens);
inits = cell(num_tensors, num_gens, num_runs);

parpool(16);
% - Generate tensors
t_start = tic;
for j=1:num_gens
    for i=1:num_tensors
        tensors{i,j} = NN_tensor_generator_whole('Size', sz, 'Gen_type', gens{j});
    end
end

% - Estimate ranks
for j=1:num_gens
    parfor i=1:num_tensors
        X = tensors{i,j}.Data;
        [nc, ~] = b_NORMO(double(X), F, 0.8,'shuffle');
        ranks(i,j) = nc;
    end
end

% - Generate initializations
% sc = parallel.pool.Constant(RandStream('mrg32k3a'));
for j=1:num_gens
    for i=1:num_tensors
        ten = tensors{i,j};
        X = ten.Data;
        nc = ranks(i,j);
%         stream = sc.Value;
%         stream.Substream = i;
        fprintf("Gen: %d \t Tensor: %d\n",j,i);
        % generate requisite initializations
        for k=1:num_runs
            inits{i,j,k} = create_guess('Data', X,'Num_Factors', nc, ...
                'Factor_Generator', 'rand');     % default 'rand' initialization scheme
        end
    end
end
toc(t_start)
fprintf("Data Generation Complete\n");
%%
% make parallel pool constants for generated tensors and initializations
c_tensors = parallel.pool.Constant(tensors);
c_inits = parallel.pool.Constant(inits);

fits = zeros(num_gens, num_tensors, num_runs, num_losses);
cossims = zeros(num_gens, num_tensors, num_runs, num_losses);
times = zeros(num_gens, num_tensors, num_runs, num_losses);
corcondias = zeros(num_gens, num_tensors, num_runs, num_losses);
angles = cell(num_gens, num_tensors,num_runs, num_losses);
models = cell(num_gens, num_tensors, num_runs,num_losses);

tic;
for j=1:num_gens
    parfor i=1:num_tensors
        fprintf("Gen: %d \t Tensor: %d\n",j,i);
        % generate requisite initializations
        % retrieve the data
        tmp_tn = c_tensors.Value{i,j};
        X = tmp_tn.Data;
        for k=1:num_runs
            % retrieve initialization
            M_init = c_inits.Value{i,j,k};
            for l=1:num_losses
                M_0 = M_init;
                % do decomposition
                tic, [M1, M0, out] = gcp_opt(X, nc, 'type',losses{l}, 'printitn',0, 'init', M_0);
                t = toc;
                % calculate metrics
                fit = fitScore(X,M1);
                cossim = cosSim(X,M1,num_modes);
                time = out.mainTime;
                [corcondia, ~] = efficient_corcondia(X,M1);
                ss_angles = subspaceAngles(X,M1);
            end
        end
    end
end
toc;

%% set up results containers

%% perform decompositions
