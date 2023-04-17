%% Clear the workspace & set up random seed
clear; clc;
rng('default');

%% check for results directory, make it if not there
datafolder = "/home/mmerris/scratch/GCPSWEEPS_nn_results";
if ~isfolder(datafolder)
    mkdir(datafolder)
end

% general experiment paramenters 
sz = [20, 20, 30];  % tensor size
rank = 10;
num_runs = 1;        % number of runs, i.e. number of tensors generated
ttypes = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'}; % tensor generator types | 
ltypes = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types

% prep a general output filepath seed, use datetime for uniqueness
formatOut = 'yyyy_mm_dd_HH_MM_SS_FFF';
dt = string(datetime("now"));

outputfile = datafolder + "/" + "nn_base_naive-size_" + strcat(num2str(sz)) + ...
            "-runs_" + num2str(num_runs) + "-" + dt + ".csv";

if ~isfile(outputfile)
    fprintf("Output file DNE ... creating\n");
    fileID = fopen(outputfile,"w");
    % HEADER: Generator, Run, Loss, Time, Fit, Log-Like, Cos Sim
    fprintf(fileID, "Generator,Run,Loss,Time,Fit,Cos Sim\n"); % Log-Like, 
    fclose(fileID);
else
    fprintf("Output file exists ... not creating\n");
end

%% Get into the experiment

num_types = length(ttypes);     % number of generators
num_losses = length(ltypes);    % number of GCP loss functions
num_modes = length(sz);         % number of tensor modes
rng(13);
parpool(8);  % Set pool size for parfor (8 nodes, 28 cores/node = 228
t_start = tic;
for type = 1:num_types
    % CONVERT FOLLOWING FOR-LOOP TO PARFOR-loop
    for run = 1:num_runs
        % generate data tensor
        ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', ttypes{type});
        X = ten.Data;
        % Estimate rank and initialize guess (based on modal unfolding svd)
        [est_rank, factors] = estRank(X);
%         % generate random initial guess
%         factors = cell(num_modes,1);
%         % rng(12 + run);
%         for fct = 1:num_modes
%             factors{fct} = rand(sz(fct), rank)+.1;
%         end
        M_init = ktensor(factors);
        % perform decompositions with available loss functions
        for loss = 1:num_losses
            tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, est_rank, 'type',ltypes{loss}, 'printitn',0, 'init', factors);
            t = toc;
            fit = 1 - norm(X-full(M_gcp))/norm(X);
            % llike = tt_loglikelihood(X,M_gcp);
            cossim = cosSim(X, M_gcp, num_modes);
            % write results to file
            fileID = fopen(outputfile, "a");
            fprintf(fileID,"%s, %u, %s, %f, %f, %f, %f", ttypes{type}, run, ltypes{loss}, ...
                                                            t, fit, cossim);
            fprintf(fileID, '\n');
            fclose(fileID);
        end
    end
end

% Summerize the job size and time required

t_total = toc(t_start);
fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_types, num_runs*num_types);
fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_types*num_losses);
