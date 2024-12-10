%% testing gcp on binary tensors
sz = [100 100 100];
rank = 10;
tens_per_gen = 100;
data_tensors = cell(tens_per_gen,1);
data_Ms = cell(tens_per_gen, 1);

for jdx = 1:tens_per_gen
    [data_tensors{jdx,1}, data_Ms{jdx,1}, ~] = create_problem_binary(sz,rank);
end

%% decompositions
losses = ["normal", "huber (0.25)", "binary", "bernoulli-logit"];
num_losses = length(losses);
Ms_binary = cell(tens_per_gen,num_losses);
infos_binary = cell(tens_per_gen,num_losses);

t_start = tic;
for idx = 1:tens_per_gen
    sprintf("Tensor %d",idx)
    init = create_guess('Data', data_tensors{idx,1},'Num_Factors', rank);
    for jdx = 1:num_losses
        [Ms_binary{idx,jdx}, ~, infos_binary{idx,jdx}] = gcp_opt(data_tensors{idx,1}, rank, 'type', losses{1,jdx},...
            'printitn',0, 'init', init);
    end
end
toc(t_start);

%% harvest scores
scores = zeros(tens_per_gen,num_losses);
fits_full = zeros(tens_per_gen,num_losses);
fits_Ms = zeros(tens_per_gen,num_losses);
cossims = zeros(tens_per_gen,num_losses);
cors = zeros(tens_per_gen,num_losses);
times = zeros(tens_per_gen, num_losses);
for idx = 1:tens_per_gen
    for jdx = 1:num_losses
        scores(idx,jdx) = score(Ms_binary{idx,jdx}, data_Ms{idx,1});
        fits_full(idx,jdx) = fitScore(data_tensors{idx,1}, Ms_binary{idx,jdx});
        fits_Ms(idx,jdx) = fitScore(full(data_Ms{idx,1}), Ms_binary{idx,jdx});
        cossims(idx,jdx) = cosSim(data_tensors{idx,1}, Ms_binary{idx,jdx},3);
        cors(idx,jdx) = efficient_corcondia(data_tensors{idx,1}, Ms_binary{idx,jdx});
        times(idx,jdx) = infos_binary{idx,jdx}.mainTime;
    end
end
    