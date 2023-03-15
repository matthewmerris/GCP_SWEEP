%% Clear the workspace
clear; clc;

% check for results directory, make it if not there
datafolder = "results";
if ~isfolder(datafolder)
    mkdir(datafolder)
end

% general experiment paramenters 
sz = [20, 20, 30];  % tensor size
num_runs = 100;        % number of runs, i.e. number of tensors generated
ttypes = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'}; % tensor generator types
ltypes = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'}; % GCP loss types

% prep a general output filepath seed, use datetime for uniqueness
formatOut = 'yyyy_mm_dd_HH_MM_SS_FFF';
dt = string(datetime("now"));

outputfile = datafolder + "/" + "nn_base_naive-size_" + strcat(num2str(sz)) + ...
            "-runs_" + num2str(num_runs) + "-" + dt + ".csv";

if ~isfile(outputfile)
    fprintf("Output file DNE ... creating\n");
    fileID = fopen(outputfile,"w");
    fprintf(fileID, "This will be a header row, most likely!\n");
    fclose(fileID);
else
    fprintf("Output file exists ... not creating\n");
end

% Get into the experiment
num_types = length(ttypes);     % number of generators
num_losses = length(ltypes);    % number of GCP loss functions
t_start = tic;
for type = 1:num_types
    for run = 1:num_runs
        % generate data tensor
        ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', ttypes{type});
        X = ten.Data;
        % perform decompositions with available loss functions
        for loss = 1:num_losses
        end
    end
end

t_total = toc(t_start);
