%% Set-up and results container
% GCP losses | number of GCP loss functions
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'};
num_losses = length(losses);
pgtol = 1e-3;


%results containers
fits = zeros(num_gens, num_tensors, num_losses);
cossims = zeros(num_gens, num_tensors, num_losses);
corcondias = zeros(num_gens, num_tensors, num_losses);
times = zeros(num_gens, num_tensors, num_losses);

Ms = cell(num_gens, num_tensors, num_losses);
infos = cell(num_gens, num_tensors, num_losses);

%%
parpool(num_losses);

%% Decompose
t_start = tic;
for idx = 1:num_gens
    for jdx = 1:num_tensors
        sprintf("Gen: %s, Tensor %d",gens{idx},jdx)
        tns = tensors{jdx,idx}; % was tensors{jdx,idx}.Data
        init = inits{jdx,idx};
        rnk = ranks(jdx,idx);
        parfor kdx = 1:num_losses
            [Ms{idx,jdx,kdx},~,infos{idx,jdx,kdx}] = gcp_opt(tns, rnk, ...
                'type', losses{1,kdx}, 'printitn',0, 'init', init, 'pgtol', pgtol);
        end
    end
end

for idx = 1:num_gens
    for jdx = 1:num_tensors
        for kdx = 1:num_losses
            fits(idx,jdx,kdx) = fitScore(tensors{jdx,idx}, Ms{idx,jdx,kdx});
            cossims(idx,jdx,kdx) = cosSim(tensors{jdx,idx}, Ms{idx,jdx,kdx},3);
            corcondias(idx,jdx,kdx) = efficient_corcondia(tensors{jdx,idx}, Ms{idx,jdx,kdx});
            times(idx,jdx,kdx) = infos{idx,jdx,kdx}.mainTime;
        end
    end
end

poolobj = gcp('nocreate');
delete(poolobj);

%%
results_filename = sprintf("results/expr2_022725_unstructured_normo_nvecs");
save(results_filename,'Ms', 'infos', 'fits','cossims','corcondias','times');
