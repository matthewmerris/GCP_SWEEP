sz = [100, 100, 100];
num_modes = length(sz);
num_tensors = 50;
gens = {'rand' 'randn' 'rayleigh' 'beta' 'gamma'};
num_gens = length(gens);
F = floor(max(sz)/2);

tensors = cell(num_tensors, num_gens);
ranks = zeros(num_tensors, num_gens);
inits = cell(num_tensors, num_gens);    % initialization via NVECs, no retries needed

%% start parallel pool
parpool(16);

%% - Generate tensors
t_start = tic;
for j=1:num_gens
    for i=1:num_tensors
        tensors{i,j} = NN_tensor_generator_whole('Size', sz, 'Gen_type', gens{j});
    end
end
%%
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
        inits{i,j} = create_guess('Data', X, 'Num_Factors', nc,...
            'Factor_Generator', 'nvecs');
    end
    fprintf("Gen: %s tensors complete.\n",gens{j});
end
toc(t_start)

% close parallel pool
delete(gcp('nocreate'));

fprintf("Data Generation Complete\n");

%% save data
results_filename = sprintf("datasets_unstructured/expr2_021025_normo_nvecs");
save(results_filename, 'sz', 'gens', 'num_tensors', 'num_gens', 'num_modes',...
    'tensors', 'ranks', 'inits');