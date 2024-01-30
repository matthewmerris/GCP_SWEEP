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
% rng("shuffle"); % seed based on current time
rng(1339);

% tensor size & number of modes
sz = [100, 100, 100]; 
num_modes = length(sz);
F = floor(max(sz)/2);

% tensor generators | number of generators
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
% gens = {'beta'};
% gens = {'rand'};
num_gens = length(gens);

% number of tensors generated per generator 
num_tensors = 100;
num_runs = 100;          % number of runs, 1 run performs a GCP decomposition 
                        %
% GCP losses | number of GCP loss functions
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);

%% generate tensor, estimate rank, and generate initializations

tensors = cell(num_tensors, num_gens);
ranks = zeros(num_tensors, num_gens);
inits = cell(num_tensors, num_gens, num_runs);

% start parallel pool
parpool(48);

% - Generate tensors
t_start = tic;
for j=1:num_gens
    for i=1:num_tensors
        tensors{i,j} = NN_tensor_generator_whole('Size', sz, 'Gen_type', gens{j});
    end
end

% *** NEED TO PRESERVE GLOBAL RANDOM STREAM STATE ***
globalStream = RandStream.getGlobalStream;
% - Estimate ranks
for j=1:num_gens
    parfor i=1:num_tensors
        X = tensors{i,j}.Data;
        [nc, ~] = b_NORMO(double(X), F, 0.8,'shuffle');
        ranks(i,j) = nc;
    end
end
% *** NEED TO RESTORE GLOBAL RANDOM STREAM STATE ***
RandStream.setGlobalStream(globalStream);

% - Generate initializations
for j=1:num_gens
    for i=1:num_tensors
        ten = tensors{i,j};
        X = ten.Data;
        nc = ranks(i,j);
%         fprintf("Gen: %d \t Tensor: %d\n",j,i);
        % generate requisite initializations
        for k=1:num_runs
            inits{i,j,k} = create_guess('Data', X,'Num_Factors', nc, ...
                'Factor_Generator', 'rand', 'Size', sz);     % default 'rand' initialization scheme
        end
    end
    fprintf("Gen: %s tensors complete.\n",gens{j});
end
toc(t_start)

% close parallel pool
% delete(gcp('nocreate'));

fprintf("Data Generation Complete\n");

%%
% start parallel pool
% parpool(48);

% make parallel pool constants for generated tensors and initializations
% c_tensors = parallel.pool.Constant(tensors);
% c_inits = parallel.pool.Constant(inits);
c_losses = parallel.pool.Constant(losses);
c_ranks = parallel.pool.Constant(ranks);

fits = zeros(num_gens, num_tensors, num_runs, num_losses);          % j,i,k,l
cossims = zeros(num_gens, num_tensors, num_runs, num_losses);       % j,i,k,l
times = zeros(num_gens, num_tensors, num_runs, num_losses);         % j,i,k,l
corcondias = zeros(num_gens, num_tensors, num_runs, num_losses);    % j,i,k,l
rmses = zeros(num_gens, num_tensors, num_runs, num_losses);         % j,i,k,l
angles = cell(num_gens, num_tensors,num_runs, num_losses);          % j,i,k,l
% models = cell(num_gens, num_tensors, num_runs,num_losses);          % j,i,k,l

best_fits = zeros(num_gens,num_tensors, num_losses);
best_cossims = zeros(num_gens,num_tensors, num_losses);
best_times = zeros(num_gens,num_tensors, num_losses);
best_corcondias = zeros(num_gens,num_tensors, num_losses);
best_rmses = zeros(num_gens,num_tensors, num_losses);


tic;
for j=1:num_gens
    % slice tensors, inits, and ranks(?) for memory considerations
    tmp_tensors = tensors(:,j);
    tmp_inits = inits(:,j,:);
    parfor i=1:num_tensors
        fprintf("Gen: %d \t Tensor: %d\n",j,i);
        % generate requisite initializations
        % retrieve the data
        tmp_tn = tmp_tensors{i};
        X = tmp_tn.Data;
        % retrieve the rank
        nc = c_ranks.Value(i,j);
        % models container
%         models = cell(num_runs,num_losses);
        for k=1:num_runs
            % retrieve initialization
            M_init = tmp_inits{i,1,k};
            for l=1:num_losses
                M_0 = ktensor(M_init);
                % do decomposition
                tic, [M1, M0, out] = gcp_opt(X, nc, 'type',c_losses.Value{l}, 'printitn',0, 'init', M_0);
                t = toc;
                % calculate metrics
                fit = fitScore(X,M1);
                fits(j,i,k,l) = fit;
                cossim = cosSim(X,M1,num_modes);
                cossims(j,i,k,l) = cossim;
                time = out.mainTime;
                times(j,i,k,l) = time;
                [corcondia, ~] = efficient_corcondia(X,M1);
                corcondias(j,i,k,l) = corcondia;
                rmses(j,i,k,l) = rms_err(X,M1);
                ss_angles = subspaceAngles(X,M1);
                angles{j,i,k,l} = ss_angles;
                % store model
%                models{j,i,k,l} = M1;
            end
        end
        % collect best metrics and models
    end
end
toc;

% close parallel pool
delete(gcp('nocreate'));

%% sorting out best_ metrics collecting
for j=1:num_gens
    for i=1:num_tensors
        best_fits(j,i,:) = max(squeeze(fits(j,i,:,:)));
        best_cossims(j,i,:) = max(squeeze(cossims(j,i,:,:)));
        best_times(j,i,:) = max(squeeze(times(j,i,:,:)));
        best_corcondias(j,i,:) = max(squeeze(corcondias(j,i,:,:)));
        best_rmses(j,i,:) = max(squeeze(rmses(j,i,:,:)));
    end
end
                

%% save results
results_filename = sprintf('results/%d-gens_%d-tens_%d-init_%d-losses_', num_gens, num_tensors, ...
                            num_runs, num_losses)+ string(datetime("now"));
save(results_filename, 'gens', 'losses', 'fits', 'cossims', 'times',...
    'corcondias','angles', 'ranks','rmses',...
    'best_fits', 'best_cossims','best_times', ...
    'best_corcondias', 'best_rmses','num_runs',...
    'num_losses','num_tensors', 'num_gens');

data_filename = strcat(results_filename,'_data.mat');
m = matfile(data_filename,'Writable',true);
m.tensors = tensors;
m.inits = inits;
% m.models = models;

