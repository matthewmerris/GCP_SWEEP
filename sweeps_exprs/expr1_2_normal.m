%% Experiment 1 structured - normal
sz = [100 100 100];
rank = 10;
tens_per_gen = 100;
data_tensors = cell(tens_per_gen,1);
data_Ms = cell(tens_per_gen, 1);
rng(1339);

for jdx = 1:tens_per_gen
    [info, ~] = create_problem('Size',sz,'Num_Factors', rank, 'Factor_Generator', 'randn');
    data_tensors{jdx} = info.Data;
    data_Ms{jdx} = info.Soln;
end

%% decompositions
losses = ["normal", "huber (0.25)"];
num_losses = length(losses);
Ms_normal = cell(tens_per_gen, num_losses);
infos_normal = cell(tens_per_gen, num_losses);

t_start = tic;
for idx = 1:tens_per_gen
    sprintf("Tensor %d",idx)
%     init = arnoldi_cp_init(data_tensors{idx,1},rank);
    init = create_guess('Data', data_tensors{idx,1},'Num_Factors', rank);
    for jdx = 1:num_losses
        [Ms_normal{idx,jdx},~,infos_normal{idx,jdx}] = gcp_opt(data_tensors{idx,1}, rank, ...
            'type', losses{1,jdx}, 'printitn',0, 'init',init, 'pgtol', 1e-2);
    end
end
toc(t_start);

%% harvest metrics
scores = zeros(tens_per_gen,num_losses);
fits_full = zeros(tens_per_gen,num_losses);
fits_Ms = zeros(tens_per_gen,num_losses);
cossims = zeros(tens_per_gen,num_losses);
cors = zeros(tens_per_gen,num_losses);
times = zeros(tens_per_gen, num_losses);
for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        scores(idx,jdx) = score(Ms_normal{idx,jdx}, data_Ms{idx,1});
        fits_full(idx,jdx) = fitScore(data_tensors{idx,1}, Ms_normal{idx,jdx});
        fits_Ms(idx,jdx) = fitScore(full(data_Ms{idx,1}), Ms_normal{idx,jdx});
        cossims(idx,jdx) = cosSim(data_tensors{idx,1}, Ms_normal{idx,jdx},3);
        cors(idx,jdx) = efficient_corcondia(data_tensors{idx,1}, Ms_normal{idx,jdx});
        times(idx,jdx) = infos_normal{idx,jdx}.mainTime;
    end
end

%% Save results
initialization = "rand";
results_filename = sprintf('results/expr1_2_normal_%dtensors_%s_init',tens_per_gen,initialization);
save(results_filename, 'sz', 'rank','tens_per_gen','data_tensors','data_Ms', 'losses','Ms_normal','infos_normal',...
    'scores','fits_Ms','fits_full','cossims','cors','times');