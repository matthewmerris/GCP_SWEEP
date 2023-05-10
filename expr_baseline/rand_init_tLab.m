sz = [100, 100, 100];
ten = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'gamma');
X = ten.Data;
[est_rank0, factors0] = estRank(X);
[est_rank1,~,~] = rankest(double(X));
factors1 = cpd_rnd(sz,est_rank1);

%%
M_init0 = ktensor(factors0);
M_init1 = ktensor(factors1);

%%
tic, [M_gcp0, M_00, out_gcp0] = gcp_opt(X, est_rank, 'type','huber (0.25)', 'printitn',0, 'init', M_init0);
t_svt = toc;
fit_svt = 1 - norm(X-full(M_gcp0))/norm(X);

tic, [M_gcp1, M_01, out_gcp1] = gcp_opt(X, est_rank, 'type','huber (0.25)', 'printitn',0, 'init', M_init1);
t_rand = toc;
fit_rand = 1 - norm(X-full(M_gcp1))/norm(X);