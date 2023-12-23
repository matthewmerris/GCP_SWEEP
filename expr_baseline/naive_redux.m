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
sc = rng("shuffle"); % seed based on current time

% tensor size & number of modes
sz = [100, 100, 100]; 
num_modes = length(sz);
F = floor(max(sz)/2);

% tensor generators | number of generators
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
% gens = {'rand'};
num_gens = length(gens);

% number of tensors generated per generator 
num_tensors = 100;
num_runs = 100;          % number of runs, 1 run performs a GCP decomposition 
                        %
% GCP losses | number of GCP loss functions
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);

%% generate tensor, initial solutions, and rank estimate

tensors = cell(num_tensors, num_gens);
inits = cell(num_tensors, num_gens, num_runs);
ranks = zeros(num_tensors, num_gens);
tic;
for j=1:num_gens
    for i=1:num_tensors
        fprintf("Gen: %d \t Tensor: %d\n",j,i);
        % generate synthetic tensor
        ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', gens{j});
        tensors{i,j} = ten;
        
        % Estimate number of components, ie. rank
        X = ten.Data;
        [nc, ~] = b_NORMO(double(X), F, 0.8);
        ranks(j,i) = nc;
        

        % generate requisite initializations
        for k=1:num_runs
            inits{i,j,k} = create_guess('Data', X,'Num_Factors', nc, ...
                'Factor_Generator', 'rand');     % default 'rand' initialization scheme
        end
    end
end
toc;

%% set up results containers

%% perform decompositions
