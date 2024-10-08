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
rando = rng(1339);
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
nf = 10;
                        %
% GCP losses | number of GCP loss functions
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);

% Instantiate general metrics containers
fits = zeros(num_gens, num_tensors, num_runs, num_losses);
cossims = zeros(num_gens, num_tensors, num_runs, num_losses);
times = zeros(num_gens, num_tensors, num_runs, num_losses);
corcondias = zeros(num_gens, num_tensors, num_runs, num_losses);
angles = cell(num_gens, num_tensors,num_runs, num_losses);
% ranks = zeros(num_tensors, num_gens);

% Instantiate 'BEST' results containers
best_fits = cell(num_gens, num_tensors, num_losses, 4);
best_cossims = cell(num_gens, num_tensors, num_losses, 4);
best_times = cell(num_gens, num_tensors, num_losses, 4);
best_corcondias = cell(num_gens, num_tensors, num_losses, 4);

%% Get into the experiment

parpool(16);

t_start = tic;
for i = 1:num_gens
    fprintf('Tensor Generator:\t%s\n', gens{i});
    % CONVERT FOLLOWING FOR-LOOP TO PARFOR-loop
    for j = 1:num_tensors
        % generate data tensor
        fprintf('Processing tensor: %d\n', j);
        ten = NN_tensor_generator_structured('Size', sz, 'Lambda_Gen', gens{i},...
                                                'Num_factors', nf);
        X = ten.Data;
        
        tmp_mdls = cell(num_runs, num_losses,2); % hold model and output info
        tmp_fits = zeros(num_runs, num_losses);
        tmp_cossims = zeros(num_runs, num_losses);
        tmp_times = zeros(num_runs, num_losses);
        tmp_corcondias = zeros(num_runs, num_losses);

        best_mdls = cell(num_losses,3);

        parfor k = 1:num_runs
            % generate solution initialization
            M_init = create_guess('Data', X,'Num_Factors', nf, ...
                'Factor_Generator', 'rand');     % default 'rand' initialization scheme

            % perform decompositions with available loss functions
            for l = 1:num_losses
                M0 = M_init;
                tic, [M1, M0, out] = gcp_opt(X, nf, 'type',losses{l}, 'printitn',0, 'init', M0);
                t = toc;
                tmp_fits(k,l) = fitScore(X,M1);
%                 if isempty(best_fits{i,j,l,1}) || fits(i,j,k,l) > best_fits{i,j,l,1}
%                     best_fits{i,j,l,1} = fits(i,j,k,l);
%                     best_fits{i,j,l,2} = M1;
%                     best_fits{i,j,l,3} = out;
%                     best_fits{i,j,l,4} = k;
%                 end
                
                tmp_cossims(k,l) = cosSim(X,M1,num_modes);
%                 if isempty(best_cossims{i,j,l,1}) || cossims(i,j,k,l) > best_cossims{i,j,l,1}
%                     best_cossims{i,j,l,1} = fits(i,j,k,l);
%                     best_cossims{i,j,l,2} = M1;
%                     best_cossims{i,j,l,3} = out;
%                     best_cossims{i,j,l,4} = k;
%                 end
                
                tmp_times(k,l) = out.mainTime;
%                 if isempty(best_times{i,j,l,1}) || times(i,j,k,l) > best_times{i,j,l,1}
%                     best_times{i,j,l,1} = fits(i,j,k,l);
%                     best_times{i,j,l,2} = M1;
%                     best_times{i,j,l,3} = out;
%                     best_times{i,j,l,4} = k;
%                 end

                [tmp_corcondias(k,l), ~] = efficient_corcondia(X,M1);
%                 if isempty(best_corcondias{i,j,l,1}) || corcondias(i,j,k,l) > best_corcondias{i,j,l,1}
%                     best_corcondias{i,j,l,1} = fits(i,j,k,l);
%                     best_corcondias{i,j,l,2} = M1;
%                     best_corcondias{i,j,l,3} = out;
%                     best_corcondias{i,j,l,4} = k;
%                 end

                angles{i,j,k,l} = subspaceAngles(X,M1);
                [tmp_mdls{k,l,:}] = deal(M1, out);
%                 tmp_mdls{k,l,1} = M1;
%                 tmp_mdls{k,l,2} = out;
            end
        end
        fits(i,j,:,:) = tmp_fits(:,:);
        cossims(i,j,:,:) = tmp_cossims(:,:);
        times(i,j,:,:) = tmp_times(:,:);
        corcondias(i,j,:,:) = tmp_corcondias(:,:);

        % update "best results" for a run of initializations for each of
        % the losses
        b_fits = zeros(num_losses,2);
        b_cossims = zeros(num_losses,2);
        b_times = zeros(num_losses,2);
        b_corcondias = zeros(num_losses,2);
        for l = 1:num_losses
            [b_fits(l,1),b_fits(l,2)] = max(tmp_fits(:,l));
            [b_cossims(l,1), b_cossims(l,2)] = max(tmp_cossims(:,l));
            [b_times(l,1), b_times(l,2)] = max(tmp_times(:,l));
            [b_corcondias(l,1), b_corcondias(l,2)] = max(tmp_corcondias(:,l));
        end
        % place fit, index (best run), model and output
        [best_fits{i,j,:,1}] = deal(b_fits(:,1));
        [best_fits{i,j,:,4}] = deal(b_fits(:,2));
        [best_cossims{i,j,:,1}] = deal(b_cossims(:,1));
        [best_cossims{i,j,:,4}] = deal(b_cossims(:,2));
        [best_times{i,j,:,1}] = deal(b_times(:,1));
        [best_times{i,j,:,4}] = deal(b_times(:,2));
        [best_corcondias{i,j,:,1}] = deal(b_corcondias(:,1));
        [best_corcondias{i,j,:,4}] = deal(b_corcondias(:,2));
        for l = 1:num_losses
            best_fits{i,j,l,2} = tmp_mdls{b_fits(l,2), l, 1};
            best_fits{i,j,l,3} = tmp_mdls{b_fits(l,2), l, 2};
            best_cossims{i,j,l,2} = tmp_mdls{b_cossims(l,2), l, 1};
            best_cossims{i,j,l,3} = tmp_mdls{b_cossims(l,2), l, 2};
            best_times{i,j,l,2} = tmp_mdls{b_times(l,2), l, 1};
            best_times{i,j,l,3} = tmp_mdls{b_times(l,2), l, 2};
            best_corcondias{i,j,l,2} = tmp_mdls{b_corcondias(l,2), l, 1};
            best_corcondias{i,j,l,3} = tmp_mdls{b_corcondias(l,2), l, 2};
        end
%         for l = 1:num_losses
%             best_fits{i,j,l,3} = tmp_mdls{b_fits(l,2), l, 2};
%             best_cossims{i,j,l,3} = tmp_mdls{b_cossims(l,2), l, 2};
%             best_times{i,j,l,3} = tmp_mdls{b_times(l,2), l, 2};
%             best_corcondias{i,j,l,3} = tmp_mdls{b_corcondias(l,2), l, 2};
%         end
    end
end

% Summerize the job size and time required

t_total = toc(t_start)
% fprintf('%d runs for each of %d generators. | %d total generated tensors.\n', num_runs, num_types, num_runs*num_types);
% fprintf('GCP decomps using %d loss functions took %f minutes. | %d total decompositions performed. \n',num_losses, t_total/60, num_runs*num_types*num_losses);

%% Save results in single .mat 
results_filename = sprintf('results/%d-gens_%d-tens_%d-init_%d-losses_structured', num_gens, num_tensors, ...
                            num_runs, num_losses)+ string(datetime("now"));
% save gens, losses, fits, cossims, times, corcondias, angles, ranks,
% best_fits, best_cossims, best_times, best_corcondias
save(results_filename, 'gens', 'losses', 'fits', 'cossims', 'times', 'corcondias','angles', ...
    'best_fits', 'best_cossims', 'best_times', 'best_corcondias','num_gens','num_tensors', ...
    'num_runs','num_losses');



