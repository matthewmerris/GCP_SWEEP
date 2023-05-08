%% Clear the workspace & set up random seed
clear; clc;
rng('default');

%% check for results directory, make it if not there
datafolder = "results";
if ~isfolder(datafolder)
    mkdir(datafolder)
end

% general experiment paramenters 
sz = [20, 20, 30];  % tensor size
rank = 10;
num_runs = 1;        % number of runs, i.e. number of tensors generated
ttypes = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'}; % tensor generator types | 
ltypes = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types
itypes = {'rand', 'randn', 'orthogonal', 'stochastic', 'nvecs'};

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

num_inits = length(itypes);
num_types = length(ttypes);     % number of generators
num_losses = length(ltypes);    % number of GCP loss functions
num_modes = length(sz);         % number of tensor modes
rng(13);
t_start = tic;
for init_type = 1:num_inits
    for type = 1:num_types
        % CONVERT FOLLOWING FOR-LOOP TO PARFOR-loop
        for run = 1:num_runs
            % generate data tensor
            ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', ttypes{type});
            X = ten.Data;
            % Estimate rank and initialize guess (based on modal unfolding svd)
            [est_rank, ~] = estRank(X);
            if strcmp(itypes{init_type}, 'nvecs')
                factors = initializeCP(X,'Factor_Generator', itypes{init_type}, 'Num_Factors', est_rank, 'Data',X);
            else
                factors = initializeCP(X,'Factor_Generator', itypes{init_type}, 'Num_Factors', est_rank);
            end
            
            %M_init = ktensor(factors);
            % perform decompositions with available loss functions
            for loss = 1:num_losses
                tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, est_rank, 'type',ltypes{loss}, 'printitn',0, 'init', factors);
                t = toc;
                fit = 1 - norm(X-full(M_gcp))/norm(X);
                cossim = cosSim(X, M_gcp, num_modes);
                % write results to file
                fileID = fopen(outputfile, "a");
                fprintf(fileID,"%s,%s,%u,%s,%f,%f,%f,%f,%d,%d", ttypes{type}, itypes{init_type},run, ltypes{loss}, ...
                                                                t, fit, cossim, est_rank,out_gcp.lbfgsout.totalIterations);
                fprintf(fileID, '\n');
                fclose(fileID);
            end
        end
    end
end
% Summerize the job size and time required

t_total = toc(t_start);
fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_types, num_runs*num_types);
fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_types*num_losses);