%% Run a series of random experiments on a SINGLE tensor: 
% Intitialization schemes: rand init, nvecs init, gevd, arnoldi init, & min
% krylov recursion.
rng(1339);
sz = [100 100 100];
ranks = [10 20 30 40 50];
num_runs = 10;              % number of runs of 'random' class of inits
num_inits = 5;              % rand, arno, min_krylov, nvecs, gevd
modes = length(sz);
num_tensors = length(ranks);
tol = 1.0e-6;
max_iters = 1000;



decomps = cell(num_tensors,num_runs,num_inits,3);
init_times = zeros(num_tensors, num_runs, num_inits);

% fits = cell(num_runs, num_inits);
% conds_init = cell(num_inits,num_runs);
% conds_final = cell(num_inits, num_runs);

for jdx = 1:num_tensors
    nc = ranks(jdx);
    tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
        'Num_Factors', nc,'Sparse_Generation', 0.8, 'Noise', 0);
    for idx = 1:num_runs
        sprintf("Tensor %d - run %d", jdx, idx)
        
        % ********************* form initializations and init_times
        t_rand = tic;
        init_rand = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'rand');
        init_times(jdx, idx, 1) = toc(t_rand);
        
        t_arno = tic;
        init_arnoldi = arnoldi_cp_init(tns.Data, nc);
        init_times(jdx, idx, 2) = toc(t_arno);
    
        t_kryl = tic;
        [init_krylov, ~, ~] = min_krylov_recursion(tns.Data, nc);
        init_times(jdx, idx, 3) = toc(t_kryl);
        if idx == 1
            t_nvecs = tic;
            init_nvecs = create_guess('Data',tns.Data, 'Num_Factors', nc, 'Factor_Generator', 'nvecs');
            init_times(jdx, idx, 4) = toc(t_nvecs);
            
            tns_matlab = full(tns.Data);
            t_gevd = tic;
            [init_gevd,ot_gevd] = cpd_gevd(tns_matlab.data, nc);
            init_times(jdx, idx, 5) = toc(t_gevd);
        else
            init_times(jdx, idx,4) = init_times(jdx, idx-1,4);
            init_times(jdx, idx,5) = init_times(jdx, idx-1,5);
        end
        
        % ********************* perform decompositions
        if idx == 1
            [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_rand);
            [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_arnoldi);
            [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_krylov);
            [decomps{jdx,idx,4,1},decomps{jdx,idx,4,2},decomps{jdx,idx,4,3}] ...  
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_nvecs);
            [decomps{jdx,idx,5,1},decomps{jdx,idx,5,2},decomps{jdx,idx,5,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_gevd);
        else
            [decomps{jdx,idx,1,1},decomps{jdx,idx,1,2},decomps{jdx,idx,1,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_rand);
            [decomps{jdx,idx,2,1},decomps{jdx,idx,2,2},decomps{jdx,idx,2,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_arnoldi);
            [decomps{jdx,idx,3,1},decomps{jdx,idx,3,2},decomps{jdx,idx,3,3}] ... 
                = cp_als(tns.Data, nc, 'tol', tol, 'maxiters', max_iters, 'printitn', 0, 'init', init_krylov);
        end
        
        % collect condition numbers of factor matrices
%         for jdx = 1:modes
%             conds_init_rand(jdx) = cond(M0_rand{jdx});
%             conds_init_nvecs(jdx) = cond(M0_nvecs{jdx});
%             conds_init_gevd(jdx) = cond(M0_gevd{jdx});
%             conds_init_arno(jdx) = cond(M0_arno{jdx});
%             conds_init_kryl(jdx) = cond(M0_kryl{jdx});
%             conds_rand(jdx) = cond(M_rand{jdx});
%             conds_nvecs(jdx) = cond(M_nvecs{jdx});
%             conds_gevd(jdx) = cond(M_gevd{jdx});
%             conds_arno(jdx) = cond(M_arnoldi{jdx});
%             conds_kryl(jdx) = cond(M_kryl{jdx});
%         end
%         conds_init{1,idx} = conds_init_rand;
%         conds_init{2,idx} = conds_init_nvecs;
%         conds_init{3,idx} = conds_init_gevd;
%         conds_init{4,idx} = conds_init_arno;
%         conds_init{5,idx} = conds_init_kryl;
%         conds_final{1,idx} = conds_rand;
%         conds_final{2,idx} = conds_nvecs;
%         conds_final{3,idx} = conds_gevd;
%         conds_final{4,idx} = conds_arno;
%         conds_final{5,idx} = conds_kryl;

    end
end

%% plot times vs rank
avg_times = zeros(num_tensors, num_inits);
for jdx = 1:num_tensors
    for idx = 1:num_inits
        avg_times(jdx,idx) = mean(init_times(jdx,:,idx));
    end
end
figure;
hold on;
for jdx = 1:num_inits
    plot(ranks, avg_times(:,jdx));
end
legend('rand', 'arnoldi', 'min_krylov', 'nvecs', 'gevd');
hold off;

%% isolate best fits
best_fits = cell(num_tensors, num_inits);
for jdx = 1:num_tensors
    for kdx = 1:num_inits
        if kdx < 4
            best_fit = 0;
            fit_index = 1;
            for idx = 1:num_runs
                tmp = max(decomps{jdx,idx,kdx,3}.fits);
                if  tmp > best_fit
                    best_fit = tmp;
                    fit_index = idx;
                end
            end
            best_fits{jdx,kdx} = decomps{jdx,1,kdx,3}.fits(decomps{jdx,1,kdx,3}.fits > 0);
        else
            best_fits{jdx,kdx} = decomps{jdx,1,kdx,3}.fits(decomps{jdx,1,kdx,3}.fits > 0);
        end
    end
end

%% Plot 1st 100 iterations
for idx = 1:num_tensors
    figure;
    hold on;
    for jdx = 1:num_inits
        semilogy(best_fits{idx,jdx});
    end
    ttl = sprintf("Fit Score Convergence - Rank %d", ranks(idx));
    title(ttl);
    xlabel("Iterations");
    ylabel("Fit Score");
    legend('rand', 'arnoldi', 'min_krylov', 'nvecs', 'gevd');
    hold off;
end

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits{jdx,1}(fits{jdx,1} > 0), 'g');
    plot(fits{jdx,2}(fits{jdx,2} > 0), 'r');
    plot(fits{jdx,3}(fits{jdx,3} > 0), 'b');
    plot(fits{jdx,4}(fits{jdx,4} > 0), 'm');
    plot(fits{jdx,5}(fits{jdx,5} > 0), 'c');
end
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov' );
hold off

%% plot results
figure
hold on
for jdx = 1:num_runs
    plot(fits{jdx,1}(1:40), 'g', 'LineWidth', 2);
    plot(fits{jdx,2}(1:40), 'r', 'LineWidth', 2);
    plot(fits{jdx,3}(1:40), 'b', 'LineWidth', 2);
    plot(fits{jdx,4}(1:40), 'm', 'LineWidth', 2);
    plot(fits{jdx,5}(1:40), 'c', 'LineWidth', 2);
end
legend('rand', 'nvecs', 'gevd', 'arnoldi', 'min_krylov');
hold off

%% subplot of
figure;
cols = 8;
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
results_filename = sprintf('results/expr1_', num_runs)+ string(datetime("now"));
save(results_filename, "num_runs", "modes", "num_inits", "fits", "times", "conds_final", "conds_init");