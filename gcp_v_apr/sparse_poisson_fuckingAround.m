clear all;close all;clc
%% tryin a quick and dirty version for achieving cp-apr synth data gen (borrowed from Tensortoolbox.org)
% size and rank
sz = [100 80 60];
R = 10;

A = cell(3,1);
for n = 1:length(sz)
    A{n} = rand(sz(n), R);
    for r = 1:R
        p = randperm(sz(n));
        nbig = round( (1/R)*sz(n) );
        A{n}(p(1:nbig),r) = 100 * A{n}(p(1:nbig),r);
    end
end
lambda = rand(R,1);
S = ktensor(lambda, A);
S = normalize(S, 'sort', 1);

% create sparse test problem based on provided solution
nz = prod(sz) * .01;
info = create_problem('Soln', S, 'Sparse_Generation', nz);

% extract data and solution
X = info.Data;
M_true = info.Soln;

% create an initial guess based on HOSVD of actual data
% M_init = create_guess('Data', X, 'Factor_Generator', 'nvecs', 'Num_Factors', R);
% M_init = ktensor(M_init);

% create initial guess based on perturbation of solution
M_init = create_guess('Soln', M_true, 'Factor_Generator', 'pertubation', 'Pertubation', 0.05);
M_init = ktensor(M_init);
%% compare cp-als, cp-apr, gcp-opt
tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', 'count','printitn', 0, 'init', M_init); 
gcp_time = toc;
factor_match_score_gcp_opt = score(M_gcp, M_true, 'greedy', false)
fit_gcp = 1 - norm(X-full(M_gcp))/norm(X);
fprintf('Final fit: %e \n\n', fit_gcp);

tic, [M_als, M_0_als, out_cp] = cp_opt(X, R, 'init', M_init); 
cp_time = toc;
factor_match_score_cp_opt = score(M_als, M_true, 'greedy', false)
fit_cp = 1 - norm(X-full(M_als))/norm(X);
fprintf('Final fit: %e \n\n', fit_cp);

tic, [M_apr, M_0_apr, out_apr] = cp_apr(X, R, 'init', M_init, 'printitn', 10);
apr_time = toc;
factor_match_score_apr = score(M_apr, M_true, 'greedy', false)
fit_apr = 1 - norm(X-full(M_apr))/norm(X);
fprintf('Final fit: %e \n\n', fit_apr);

%%
figure
plot(factor_match_score_gcp_opt, gcp_time, '+')
hold on
plot(factor_match_score_cp_opt, cp_time, 'ro')
plot(factor_match_score_apr, apr_time, 'go')
hold off
legend('gcp_opt', 'cp_opt', 'cp_apr')
xlabel('Score')
ylabel('Time(secs)')
%%
figure
scatter3(factor_match_score_gcp_opt, fit_gcp, gcp_time, '+')
hold on 
scatter3(factor_match_score_cp_opt, fit_cp, cp_time, 'ro')
scatter3(factor_match_score_apr, fit_apr, apr_time, 'go')
hold off
legend('gcp_{opt}', 'cp_{opt}', 'cp_{apr}')
xlabel('Score')
ylabel('Fit')
zlabel('Time(secs)')