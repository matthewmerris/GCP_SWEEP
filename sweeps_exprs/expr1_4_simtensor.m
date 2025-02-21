%% Load data
data_path = sprintf("./datasets_simtensor/simtensor_datasets.mat");
load(data_path);

%% decompositions
losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
rank = 10;
num_losses = length(losses);
Ms_nonneg = cell(num_gens,num_tensors, num_losses);
infos_nonneg = cell(num_gens,num_tensors, num_losses);
sz = [100 100 100];
pgtol = 1e-3;

parpool(5);

%%
t_start = tic;
for idx = 1:num_gens
    for jdx = 1:num_tensors
        sprintf("Gen: %s, Tensor %d",gens{idx},jdx)
        tns = data_tensors{idx,jdx};
%         init = arnoldi_cp_init(tns,rank);
        init = create_guess('Data',tns,'Factor_Generator','nvecs', 'Num_Factors', rank);
        parfor kdx = 1:num_losses
            [Ms_nonneg{idx,jdx,kdx},~,infos_nonneg{idx,jdx,kdx}] = gcp_opt(tns, rank, ...
                'type', losses{1,kdx}, 'printitn',0, 'init',init, 'pgtol', pgtol);
        end
    end
end
toc(t_start);

%% shutdown parpool
poolobj = gcp('nocreate');
delete(poolobj);

%% collect metrics
fits = zeros(num_gens, num_tensors, num_losses);
cossims = zeros(num_gens, num_tensors, num_losses);
corcondias = zeros(num_gens, num_tensors, num_losses);
times = zeros(num_gens, num_tensors, num_losses);

for idx = 1:num_gens
    for jdx = 1:num_tensors
        for kdx = 1:num_losses
            fits(idx,jdx,kdx) = fitScore(data_tensors{idx,jdx}, Ms_nonneg{idx,jdx,kdx});
            cossims(idx,jdx,kdx) = cosSim(data_tensors{idx,jdx}, Ms_nonneg{idx,jdx,kdx},3);
            corcondias(idx,jdx,kdx) = efficient_corcondia(data_tensors{idx,jdx}, Ms_nonneg{idx,jdx,kdx});
            times(idx,jdx,kdx) = infos_nonneg{idx,jdx,kdx}.mainTime;
        end
    end
end

%% save results
results_filename = sprintf('results/expr1_simtensor_adjusted');
save(results_filename, 'Ms_nonneg', 'infos_nonneg','losses','sz','rank',...
    'fits','corcondias','cossims','times','gens');

%% exploring negative fit scores
normXs_gamma = zeros(num_tensors, num_losses);
normMs_gamma = zeros(num_tensors, num_losses);

for idx = 1:num_tensors
    for jdx = 1:num_losses
        normXs_gamma(idx,jdx) = norm(data_tensors{3,idx});
        normMs_gamma(idx,jdx) = norm(full(Ms_nonneg{3,idx,jdx}));
    end
end
