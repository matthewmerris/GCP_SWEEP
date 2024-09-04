%% Run a series of random experiments on a SINGLE tensor: 
% Intitialization schemes: rand init, nvecs init, gevd, arnoldi init, & min
% krylov recursion.
sz = [50 50 50];
nc = 5;
num_runs = 4;
num_inits = 5;
modes = length(sz);
tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
    'Num_Factors', nc,'Sparse_Generation', .9, 'Noise', 0);

fits = cell(num_runs, num_inits);
times = zeros(num_runs, num_inits);

for idx = 1:num_runs
    t_rand = tic;
    init_rand = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'rand');
    times(idx, 1) = toc(t_rand);

    [M_rand,M0_rand,outp_random] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,1} = outp_random.fits;
    
    t_nvecs = tic;
    init_nvecs = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
    times(idx, 2) = toc(t_nvecs);
    
    [M_nvecs,M0_nvecs,outp_nvecs] = cp_als(tns.Data, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0, 'init', init_nvecs);
    fits{idx,2} = outp_nvecs.fits;
    
    tns_matlab = full(tns.Data);
    t_gevd = tic;
    [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
    times(idx, 3) = toc(t_gevd);
    
    [M_gevd, M0_gevd, outp_gevd] = cp_als(tns.Data, nc, 'init', init_gevd, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,3} = outp_gevd.fits;

    t_arno = tic;
    init_arnoldi = cp_init_arnoldi(full(tns.Data), nc);
    times(idx, 4) = toc(t_arno);
    
    [M_arnoldi,M0_arno,outp_arnoldi] = cp_als(tns.Data, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,4} = outp_arnoldi.fits;

    t_kryl = tic;
    [init_krylov, ~, ~] = min_krylov_recursion(tns.Data, nc);
    times(idx, 5) = toc(t_kryl);

    [M_kryl, M0_kryl, outp_kryl] = cp_als(tns.Data, nc, 'init', init_krylov, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,5} = outp_kryl.fits;
end

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits{jdx,1}(fits{jdx,1} > 0), 'g');
    plot(fits{jdx,2}(fits{jdx,2} > 0), 'r');
    plot(fits{jdx,3}(fits{jdx,3} > 0), 'b');
    plot(fits{jdx,4}(fits{jdx,4} > 0), 'm');
    plot(fits{jdx,5}(fits{jdx,5} > 0), 'y');
end
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov' );
hold off

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits{jdx,1}(1:40), 'g');
    plot(fits{jdx,2}(1:40), 'r');
    plot(fits{jdx,3}(1:40), 'b');
    plot(fits{jdx,4}(1:40), 'm');
    plot(fits{jdx,5}(1:40), 'y');
end
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov' );
hold off

%% collect best fit and num_iters needed
max_fits = zeros(num_inits,num_runs);
max_iters = zeros(num_inits,num_runs);
for jdx = 1:num_runs
    [max_fits(1,jdx), max_iters(1,jdx)] = max(fits{jdx,1}(fits{jdx,1} > 0));
    [max_fits(2,jdx), max_iters(2,jdx)] = max(fits{jdx,2}(fits{jdx,2} > 0));
    [max_fits(3,jdx), max_iters(3,jdx)] = max(fits{jdx,3}(fits{jdx,3} > 0));
    [max_fits(4,jdx), max_iters(4,jdx)] = max(fits{jdx,4}(fits{jdx,4} > 0));
    [max_fits(5,jdx), max_iters(5,jdx)] = max(fits{jdx,5}(fits{jdx,5} > 0));
end
max_fits
max_iters
figure;
scatter(max_iters',max_fits', 'filled')
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov' );

%% Initialization times
figure;
hold on;
plot(times(:,1)', 'g', 'LineWidth', 2);
plot(times(:,2)', 'r', 'LineWidth', 2);
plot(times(:,3)', 'b', 'LineWidth', 2);
plot(times(:,4)', 'm', 'LineWidth', 2);
plot(times(:,5)', 'y', 'LineWidth', 2);
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov' );
hold off;