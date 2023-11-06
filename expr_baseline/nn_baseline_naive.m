%% Clear the workspace & set up random seed
clear; clc;
rando = rng('default');

%% check for results directory, make it if not there
datafolder = "results";
if ~isfolder(datafolder)
    mkdir(datafolder)
end

%% general experiment paramenters

% tensor size & number of modes
sz = [20, 20, 30]; 
num_modes = length(sz);

% tensor generators | number of generators
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
num_gens = length(gens);

% number of tensors generated per generator 
num_tensors = 10;
num_runs = 10;          % number of runs, 1 run performs a GCP decomposition 
                        %
% GCP losses | number of GCP loss functions
losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'};
num_losses = length(losses);

% Instantiate general metrics containers
fits = zeros(num_gens, num_tensors, num_runs, num_losses);
cossims = zeros(num_gens, num_tensors, num_runs, num_losses);
times = zeros(num_gens, num_tensors, num_runs, num_losses);
corcondias = zeros(num_gens, num_tensors, num_runs, num_losses);
angles = cell(num_gens, num_tensors,num_runs, num_losses);
ranks = zeros(num_tensors, num_gens);

% Instantiate 'BEST' results containers
best_fits = cell(num_gens, num_tensors, num_losses, 4);
best_cossims = cell(num_gens, num_tensors, num_losses, 4);
best_times = cell(num_gens, num_tensors, num_losses, 4);
best_corcondias = cell(num_gens, num_tensors, num_losses, 4);

%% prep a general output filepath seed, use datetime for uniqueness (POSSIBLE DELETE)
% formatOut = 'yyyy_mm_dd_HH_MM_SS_FFF';
% dt = string(datetime("now"));
% 
% outputfile = datafolder + "/" + "nn_base_naive-size_" + strcat(num2str(sz)) + ...
%             "-runs_" + num2str(num_runs) + "-" + dt + ".csv";
% 
% if ~isfile(outputfile)
%     fprintf("Output file DNE ... creating\n");
%     fileID = fopen(outputfile,"w");
%     % HEADER: Generator, Run, Loss, Time, Fit, Log-Like, Cos Sim
%     fprintf(fileID, "Generator,Run,Loss,Time,Fit,Cos Sim\n"); % Log-Like, 
%     fclose(fileID);
% else
%     fprintf("Output file exists ... not creating\n");
% end

%% Get into the experiment

t_start = tic;
for i = 1:num_gens
    % CONVERT FOLLOWING FOR-LOOP TO PARFOR-loop
    for j = 1:num_tensors
        % generate data tensor
        ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', gens{i});
        X = ten.Data;
        % Estimate number of components, ie. rank
        [nc, ~] = b_NORMO(double(X), F, 0.7, rando);
        ranks(j,i) = nc;
        for k = 1:num_runs
            % generate solution initialization
            M_init = create_guess('Data', X,'Num_Factors', ranks(j,i), ...
                'Factor_Generator', 'rand');     % default 'rand' initialization scheme

            % perform decompositions with available loss functions
            for l = 1:num_losses
                tic, [M1, M0, out] = gcp_opt(X, nc, 'type',losses{l}, 'printitn',0, 'init', M_init);
                t = toc;
                fits(i,j,k,l) = fitScore(X,M1);
                if isempty(best_fits{i,j,l,1}) || fits(i,j,k,l) > best_fits{i,j,l,1}
                    best_fits{i,j,l,1} = fits(i,j,k,l);
                    best_fits{i,j,l,2} = M1;
                    best_fits{i,j,l,3} = out;
                    best_fits{i,j,l,4} = k;
                end
                
                cossims(i,j,k,l) = cosSim(X,M1,num_modes);
                if isempty(best_cossims{i,j,l,1}) || cossims(i,j,k,l) > best_cossims{i,j,l,1}
                    best_cossims{i,j,l,1} = fits(i,j,k,l);
                    best_cossims{i,j,l,2} = M1;
                    best_cossims{i,j,l,3} = out;
                    best_cossims{i,j,l,4} = k;
                end
                
                times(i,j,k,l) = out.mainTime;
                if isempty(best_times{i,j,l,1}) || times(i,j,k,l) > best_times{i,j,l,1}
                    best_times{i,j,l,1} = fits(i,j,k,l);
                    best_times{i,j,l,2} = M1;
                    best_times{i,j,l,3} = out;
                    best_times{i,j,l,4} = k;
                end

                [corcondias(i,j,k,l), ~] = efficient_corcondia(X,M1);
                if isempty(best_corcondias{i,j,l,1}) || corcondias(i,j,k,l) > best_corcondias{i,j,l,1}
                    best_corcondias{i,j,l,1} = fits(i,j,k,l);
                    best_corcondias{i,j,l,2} = M1;
                    best_corcondias{i,j,l,3} = out;
                    best_corcondias{i,j,l,4} = k;
                end

                angles{i,j,k,l} = subspaceAngles(X,M1);
            end
        end
    end
end

% Summerize the job size and time required

t_total = toc(t_start);
% fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_types, num_runs*num_types);
% fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_types*num_losses);