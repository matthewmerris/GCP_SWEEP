%% Testing Arnoldi iteration initiliazation protocol for sparse tensors

% Generate a sparse CP-model tensor (i.e. known rank) and add some noise
sz = [100 100 10];
nc = 5;
A = cell(length(sz),1);
for n = 1:length(sz)
    A{n} = rand(sz(n), nc);
    for r = 1:nc
        p = randperm(sz(n));
        idx = p(1:round(.2*sz(n)));
        A{n}(idx,r) = 10 * A{n}(idx,r);
    end
end
tns_sol = ktensor(A);
tns_sol = normalize(tns_sol,'sort', 1);

tns = create_problem('Soln', tns_sol, 'Sparse_Generation', .9);
num_nnzs = nnz(tns.Data)
total_insertions = sum(tns.Data.vals)
org_lambda_vs_rescaled = tns_sol.lambda ./ tns.Soln.lambda

%% Alternate random problem creation
sz = [100 100 100];
nc = 25;

tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', 'Sparse_Generation', .8, 'Noise', 0.1);

% random intial guess
[M_rand,~,outp_rand] = cp_als(tns.Data, nc, 'tol', 1.0e-6, 'maxiters', 1000, 'printitn', 0);

% Arnoldi initial guess
init_arnoldi = cp_init_arnoldi(full(tns.Data), nc);
iscell(init_arnoldi)
[M_arnoldi,~,outp_arnoldi] = cp_als(full(tns.Data), nc, 'init', init_arnoldi, 'tol', 1.0e-6, 'maxiters', 1000, 'printitn', 0);

%%
fits_rand = outp_rand.fits(outp_rand.fits > 0);
fits_arnoldi = outp_arnoldi.fits(outp_arnoldi.fits > 0);
hold on;
plot(fits_rand);
plot(fits_arnoldi);
hold off;

%% Try a more direct, naive problem generation

raw_data = dlmread('~/datasets/real-world-rank-unknown/FROSTT/Enron/DEDICOM-style/enron_counts.csv');
enron = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;
size(enron)
%%
nc = 200;
% random intial guess
[M_rand,~,outp_rand] = cp_als(enron, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 100);

% Arnoldi initial guess
init_arnoldi = cp_init_arnoldi(full(enron), nc);
[M_arnoldi,~,outp_arnoldi] = cp_als(enron, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 100);

%% Run a series of random experiments: rand init, nvecs init, arnoldi init
sz = [100 100 100];
nc = 10;
num_runs = 5;

tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', 'Sparse_Generation', .8, 'Noise', 0);

fits_random_nvec_arno =cell(num_runs, 3);

for idx = 1:num_runs
    [M_random,~,outp_random] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,1} = outp_random.fits;
    [M_nvecs,~,outp_nvecs] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0, 'init', 'nvecs');
    fits_random_nvec_arno{idx,2} = outp_nvecs.fits;
    init_arnoldi = cp_init_arnoldi(full(tns.Data), nc);
    [M_arnoldi,~,outp_arnoldi] = cp_als(tns.Data, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,3} = outp_arnoldi.fits;
end

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits_random_nvec_arno{jdx,1}(fits_random_nvec_arno{jdx,1} > 0), 'g');
    plot(fits_random_nvec_arno{jdx,2}(fits_random_nvec_arno{jdx,2} > 0), 'r');
    plot(fits_random_nvec_arno{jdx,3}(fits_random_nvec_arno{jdx,3} > 0), 'b');
end
hold off
    


