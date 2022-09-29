clear all;close all;clc
%% tryin a quick and dirty version for achieving cp-apr synth data gen
% size and rank
% sz = [100 80 60];
% R = 10;
% 
% nd = length(sz);
% paramRange = [0.5 60];
% factorRange = paramRange.^(1/nd);
% minFactorRatio = 95/100;
% lambdaDamping = 0.8;
% rng(21);
% info = create_problem('Size', sz, ...
%     'Num_Factors', R, ...
%     'Factor_Generator', @(m,n)factorRange(1)+(rand(m,n)>minFactorRatio)*(factorRange(2)-factorRange(1)), ...
%     'Lambda_Generator', @(m,n)ones(m,1)*(lambdaDamping.^(0:n-1)'))%, ...
%     %'Sparse_Generation', 0.2);
% 
% M_true = normalize(arrange(info.Soln));
% X = info.Data;
% viz(M_true, 'Figure',3);

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

% create dense test problem based on provided solution
info = create_problem('Soln', S, 'Factor_Generator', 'rand');

% extract data and solution
X = info.Data;
M_true = info.Soln;

% create a guess to initialize each of the decomps with
M_init = create_guess('Soln', M_true, 'Factor_Generator', 'rand');
M_init = ktensor(M_init);

%% compare cp-als, cp-apr, gcp-opt
tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', 'count','printitn', 10, 'init', M_init); toc
factor_match_score_gcp = score(M_gcp, M_true, 'greedy', true)
fprintf('Final fit: %e \n\n', 1 - norm(X-full(M_gcp))/norm(X));

tic, [M_als, M_0_als, out_als] = cp_opt(X, R, 'init', M_init); toc
factor_match_score_als = score(M_als, M_true, 'greedy', true)
fprintf('Final fit: %e \n\n', 1 - norm(X-full(M_als))/norm(X));

tic, [M_apr, M_0_apr, out_apr] = cp_apr(X, R, 'init', M_init, 'printitn', 10); toc
factor_match_score_apr = score(M_apr, M_true, 'greedy', true)
fprintf('Final fit: %e \n\n', 1 - norm(X-full(M_apr))/norm(X));
