%% load Chicago Crime data
% chicago_4d_path = '~/datasets/FROSTT/chicago/chicago-crime-comm.tns';
% tns = load_frostt(chicago_4d_path);

% chicago_5d_path = '~/datasets/FROSTT/chicago/chicago-crime-geo.tns';
% chi_5d = load_frostt(chicago_5d_path);

sz = size(tns);
modes = length(sz);
nc = 32;

num_inits = 5;
num_runs = 1;

fits = cell(num_runs, num_inits);
times = zeros(num_runs, num_inits);
conds_init = cell(num_inits,num_runs);
conds_final = cell(num_inits, num_runs);

for idx = 1:num_runs
    sprintf("Expr 3 - run %d", idx)
    t_rand = tic;
    init_rand = create_guess('Data',tns, 'Num_Factors', nc, 'Factor_Generator', 'rand');
    times(idx, 1) = toc(t_rand);

    [M_rand,M0_rand,outp_random] = cp_als(tns, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,1} = outp_random.fits;
    
    t_nvecs = tic;
    init_nvecs = create_guess('Data',tns, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
    times(idx, 2) = toc(t_nvecs);
    
    [M_nvecs,M0_nvecs,outp_nvecs] = cp_als(tns, nc, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0, 'init', init_nvecs);
    fits{idx,2} = outp_nvecs.fits;
    
    tns_matlab = full(tns);
    t_gevd = tic;
    [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
    times(idx, 3) = toc(t_gevd);
    
    [M_gevd, M0_gevd, outp_gevd] = cp_als(tns, nc, 'init', init_gevd, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,3} = outp_gevd.fits;

    t_arno = tic;
    init_arnoldi = cp_init_arnoldi(full(tns), nc);
    times(idx, 4) = toc(t_arno);
    
    [M_arnoldi,M0_arno,outp_arnoldi] = cp_als(tns, nc, 'init', init_arnoldi, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,4} = outp_arnoldi.fits;

    t_kryl = tic;
    [init_krylov, ~, ~] = min_krylov_recursion(tns, nc);
    times(idx, 5) = toc(t_kryl);

    [M_kryl, M0_kryl, outp_kryl] = cp_als(tns, nc, 'init', init_krylov, 'tol', 1.0e-8, 'maxiters', 1000, 'printitn', 0);
    fits{idx,5} = outp_kryl.fits;
    % collect condition numbers of factor matrices
    for jdx = 1:modes
        conds_init_rand(jdx) = cond(M0_rand{jdx});
        conds_init_nvecs(jdx) = cond(M0_nvecs{jdx});
        conds_init_gevd(jdx) = cond(M0_gevd{jdx});
        conds_init_arno(jdx) = cond(M0_arno{jdx});
        conds_init_kryl(jdx) = cond(M0_kryl{jdx});
        conds_rand(jdx) = cond(M_rand{jdx});
        conds_nvecs(jdx) = cond(M_nvecs{jdx});
        conds_gevd(jdx) = cond(M_gevd{jdx});
        conds_arno(jdx) = cond(M_arnoldi{jdx});
        conds_kryl(jdx) = cond(M_kryl{jdx});
    end
    conds_init{1,idx} = conds_init_rand;
    conds_init{2,idx} = conds_init_nvecs;
    conds_init{3,idx} = conds_init_gevd;
    conds_init{4,idx} = conds_init_arno;
    conds_init{5,idx} = conds_init_kryl;
    conds_final{1,idx} = conds_rand;
    conds_final{2,idx} = conds_nvecs;
    conds_final{3,idx} = conds_gevd;
    conds_final{4,idx} = conds_arno;
    conds_final{5,idx} = conds_kryl;

end

%% plot results
figure;
cols = 2;
rows = ceil(num_runs/cols);
for jdx = 1:num_runs
    subplot(rows,cols,jdx);
    hold on;
    plot(fits{jdx,1}(fits{jdx,1} > 0), 'g', 'LineWidth', 2);
    plot(fits{jdx,2}(fits{jdx,2} > 0), 'r', 'LineWidth', 2);
    plot(fits{jdx,3}(fits{jdx,3} > 0), 'b', 'LineWidth', 2);
    plot(fits{jdx,4}(fits{jdx,4} > 0), 'm', 'LineWidth', 2);
    plot(fits{jdx,5}(fits{jdx,5} > 0), 'c', 'LineWidth', 2);
    legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov');
    title('Run: ', jdx);
    hold off;
end

%% plot early iterations results
figure;
cols = 2;
rows = ceil(num_runs/cols);
for jdx = 1:num_runs
    subplot(rows,cols,jdx);
    hold on;
    plot(fits{jdx,1}(1:40), 'g', 'LineWidth', 2);
    plot(fits{jdx,2}(1:40), 'r', 'LineWidth', 2);
    plot(fits{jdx,3}(1:40), 'b', 'LineWidth', 2);
    plot(fits{jdx,4}(1:40), 'm', 'LineWidth', 2);
    plot(fits{jdx,5}(1:40), 'c', 'LineWidth', 2);
    legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov');
    title('Run: ', jdx);
    hold off;
end

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

% identify max run for each initialization
[max_rand, i_rand] = max(max_fits(1,:))
[max_arno,i_arno] = max(max_fits(4,:))
[max_kryl,i_kyrl] = max(max_fits(5,:))

%% compute 'condition number score'
cond_scores_init = zeros(num_runs,num_inits);
cond_scores_final = zeros(num_runs,num_inits);

for idx = 1:num_runs
    % norm of cond scores for initial models
    cond_scores_init(idx,1) = norm(conds_init{1,idx});
    cond_scores_init(idx,2) = norm(conds_init{2,idx});
    cond_scores_init(idx,3) = norm(conds_init{3,idx});
    cond_scores_init(idx,4) = norm(conds_init{4,idx});
    cond_scores_init(idx,5) = norm(conds_init{5,idx});
    % norm of cond scores for final models
    cond_scores_final(idx,1) = norm(conds_final{1,idx});
    cond_scores_final(idx,2) = norm(conds_final{2,idx});
    cond_scores_final(idx,3) = norm(conds_final{3,idx});
    cond_scores_final(idx,4) = norm(conds_final{4,idx});
    cond_scores_final(idx,5) = norm(conds_final{5,idx});
end

figure;
subplot(1,2,1);
semilogy(cond_scores_init, 'LineWidth',2);
legend('rand', 'nvecs', 'gevd','arnoldi', 'min_krylov');
grid on;
subplot(1,2,2);
semilogy(cond_scores_final, 'LineWidth',2);
legend('rand', 'nvecs', 'gevd','arnoldi', 'min_krylov');
grid on;

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

%% Save results
results_filename = sprintf('results/expr3_', num_runs)+ string(datetime("now"));
save(results_filename, "num_runs", "modes", "num_inits", "fits", "times", "conds_final", "conds_init");