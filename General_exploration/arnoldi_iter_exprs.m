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

%% Run a series of random experiments on a SINGLE tensor: rand init, nvecs init, arnoldi init
sz = [100 100 100];
nc = 5;
num_runs = 10;
modes = length(sz);
tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', 'Sparse_Generation', .98, 'Noise', 0);

fits_random_nvec_arno =cell(num_runs, 3);
conds_init = cell(3,num_runs);
conds_final = cell(3, num_runs);

for idx = 1:num_runs
    [M_rand,M0_rand,outp_random] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,1} = outp_random.fits;
    [M_nvecs,M0_nvecs,outp_nvecs] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0, 'init', 'nvecs');
    fits_random_nvec_arno{idx,2} = outp_nvecs.fits;
    init_arnoldi = cp_init_arnoldi(full(tns.Data), nc);
    [M_arnoldi,M0_arno,outp_arnoldi] = cp_als(tns.Data, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,3} = outp_arnoldi.fits;
    % collect condition numbers of factor matrices
    for jdx = 1:modes
        conds_init_rand(jdx) = cond(M0_rand{jdx});
        conds_init_nvecs(jdx) = cond(M0_nvecs{jdx});
        conds_init_arno(jdx) = cond(M0_arno{jdx});
        conds_rand(jdx) = cond(M_rand{jdx});
        conds_nvecs(jdx) = cond(M_nvecs{jdx});
        conds_arno(jdx) = cond(M_arnoldi{jdx});
    end
    conds_init{1,idx} = conds_init_rand;
    conds_init{2,idx} = conds_init_nvecs;
    conds_init{3,idx} = conds_init_arno;
    conds_final{1,idx} = conds_rand;
    conds_final{2,idx} = conds_nvecs;
    conds_final{3,idx} = conds_arno;
end

%% Run a series of random experiments on MULTIPLE tensors: rand init, nvecs init, arnoldi init
sz = [50 50 50];
nc = 5;
num_runs = 10;
modes = length(sz);


fits_random_nvec_arno =cell(num_runs, 4);
conds_init = cell(4,num_runs);
conds_final = cell(4, num_runs);

for idx = 1:num_runs
    tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', 'Sparse_Generation', .98, 'Noise', 0);
    [M_rand,M0_rand,outp_random] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,1} = outp_random.fits;
    [M_nvecs,M0_nvecs,outp_nvecs] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0, 'init', 'nvecs');
    fits_random_nvec_arno{idx,2} = outp_nvecs.fits;
    init_arnoldi = cp_init_arnoldi(full(tns.Data), nc);
    [M_arnoldi,M0_arno,outp_arnoldi] = cp_als(tns.Data, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,3} = outp_arnoldi.fits;
    tns_matlab = full(tns.Data);
    [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
    [M_gevd, M0_gevd, outp_gevd] = cp_als(tns.Data, nc, 'init', init_gevd, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits_random_nvec_arno{idx,4} = outp_gevd.fits;
    % collect condition numbers of factor matrices
    for jdx = 1:modes
        conds_init_rand(jdx) = cond(M0_rand{jdx});
        conds_init_nvecs(jdx) = cond(M0_nvecs{jdx});
        conds_init_arno(jdx) = cond(M0_arno{jdx});
        conds_init_gevd(jdx) = cond(M0_gevd{jdx});
        conds_rand(jdx) = cond(M_rand{jdx});
        conds_nvecs(jdx) = cond(M_nvecs{jdx});
        conds_arno(jdx) = cond(M_arnoldi{jdx});
        conds_gevd(jdx) = cond(M_gevd{jdx});
    end
    conds_init{1,idx} = conds_init_rand;
    conds_init{2,idx} = conds_init_nvecs;
    conds_init{3,idx} = conds_init_arno;
    conds_init{4,idx} = conds_init_gevd;
    conds_final{1,idx} = conds_rand;
    conds_final{2,idx} = conds_nvecs;
    conds_final{3,idx} = conds_arno;
    conds_final{4,idx} = conds_gevd;
end

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits_random_nvec_arno{jdx,1}(fits_random_nvec_arno{jdx,1} > 0), 'g');
    plot(fits_random_nvec_arno{jdx,2}(fits_random_nvec_arno{jdx,2} > 0), 'r');
    plot(fits_random_nvec_arno{jdx,3}(fits_random_nvec_arno{jdx,3} > 0), 'b');
    plot(fits_random_nvec_arno{jdx,4}(fits_random_nvec_arno{jdx,4} > 0), 'y');
end
hold off

%% subplot of
figure;
rows = ceil(num_runs/2);
for jdx = 1:num_runs
    subplot(rows,2,jdx);
    hold on;
%     plot(fits_random_nvec_arno{jdx,1}(fits_random_nvec_arno{jdx,1} > 0), 'g');
%     plot(fits_random_nvec_arno{jdx,2}(fits_random_nvec_arno{jdx,2} > 0), 'r');
%     plot(fits_random_nvec_arno{jdx,3}(fits_random_nvec_arno{jdx,3} > 0), 'b');
    plot(fits_random_nvec_arno{jdx,1}(1:30), 'g');
    plot(fits_random_nvec_arno{jdx,2}(1:30), 'r');
    plot(fits_random_nvec_arno{jdx,3}(1:30), 'b');
    plot(fits_random_nvec_arno{jdx,4}(1:30), 'y');
    legend('rand', 'nvecs','arnoldi', 'gevd');
    title('Run: ', jdx);
    hold off;
end

%% collect best fit and num_iters needed
max_fits = zeros(3,num_runs);
max_iters = zeros(3,num_runs);
for jdx = 1:num_runs
    [max_fits(1,jdx), max_iters(1,jdx)] = max(fits_random_nvec_arno{jdx,1}(fits_random_nvec_arno{jdx,1} > 0));
    [max_fits(2,jdx), max_iters(2,jdx)] = max(fits_random_nvec_arno{jdx,2}(fits_random_nvec_arno{jdx,2} > 0));
    [max_fits(3,jdx), max_iters(3,jdx)] = max(fits_random_nvec_arno{jdx,3}(fits_random_nvec_arno{jdx,3} > 0));
    [max_fits(4,jdx), max_iters(4,jdx)] = max(fits_random_nvec_arno{jdx,4}(fits_random_nvec_arno{jdx,4} > 0));
end
max_fits
max_iters
figure;
scatter(max_iters',max_fits', 'filled')
legend('rand', 'nvecs','arnoldi','gevd');
%% condition numbers
% current run of interest
roi = 6;
display('rand:')
conds_init{1,roi}
conds_final{1,roi}
display('nvecs:')
conds_init{2,roi}
conds_final{2,roi}
display('arnoldi: ')
conds_init{3,roi}
conds_final{3,roi}
display('gevd')
conds_init{4,roi}
conds_final{4,roi}

%% lets play with FROSTT tensors, specifically count data tensors
chicago_4d_path = '~/datasets/FROSTT/chicago/chicago-crime-comm.tns';
chi_4d = load_frostt(chicago_4d_path);
chicago_5d_path = '~/datasets/FROSTT/chicago/chicago-crime-geo.tns';
chi_5d = load_frostt(chicago_5d_path);
lbnl_path = '~/datasets/FROSTT/lbnl_network/lbnl-network.tns';
lbnl = load_frostt(lbnl_path);
uber_path = '~/datasets/FROSTT/uber/uber.tns';
uber = load_frostt(uber_path);

%% Chicago 4d - inits: rand, stochastic, nvecs, arnoldi
nc = 10;
X = uber;
[M_rand,M0_rand, out_rand] = gcp_opt(X, nc, 'type', 'count', 'opt', 'adam', 'printitn', 10);
M_init_sto = create_guess('Data',X, 'Num_Factors', nc, 'Factor_Generator', 'stochastic');
[M_sto, M0_sto, out_sto] = gcp_opt(X, nc, 'type', 'count', 'opt', 'adam', 'printitn', 10, 'init', M_init_sto);
M_init_nvecs = create_guess('Data',X, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
[M_nvecs, M0_nvecs, out_nvecs] = gcp_opt(X, nc, 'type', 'count', 'opt', 'adam', 'printitn', 10, 'init', M_init_nvecs);
M_init_arnoldi = cp_init_arnoldi(full(X), nc);
[M_arno, M0_arno, out_arno] = gcp_opt(X, nc, 'type', 'count', 'opt', 'adam', 'printitn', 10, 'init', M_init_arnoldi);

%% check fitscores 
display('Rand Fit Score: ')
fitsc_rand = fitScore(X, M_rand)
display('Sto Fit Score: ')
fitsc_sto = fitScore(X, M_sto)
display('NVECs Fit Score: ')
fitsc_nvecs = fitScore(X, M_nvecs)
display('Arnoldi Fit Score: ')
fitsc_arno = fitScore(X, M_arno)

%% retooling fit score for ktensor
n = ndims(chi_4d);
U_mttkrp = mttkrp(chi_4d, M_arno.U, n);
iprod = sum(sum(M_arno.U{n} .* U_mttkrp) .* M_arno.lambda');
normX = norm(chi_4d);
if normX == 0
    fit = norm(M_arno)^2 - 2 * iprod;
else
    normRes = sqrt(normX^2 + norm(M_arno)^2 - 2 * iprod);
    fit = 1 - (normRes / normX);
end



