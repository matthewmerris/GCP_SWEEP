% Set data file paths
enron_path = '~/datasets/real-world-rank-unknown/enron/enron_emails.mat';

%% load enron
load(enron_path);
tns = Enron;

%% Estimate ranks: AutoTen, Normo, TensorLab(elbow), and Arnoldi
ranks = zeros(4,1);
times = zeros(4,1);

t_auto = tic;
[M_auto, ranks(1,1), ~,~] = AutoTen(tns, max(size(tns)),1);
times(1,1) = toc(t_auto);
%%
[ranks(2,1), times(2,1)] = b_NORMO(double(tns), floor(max(size(tns)/2)));
%%
% t_elbo = tic;
% [ranks(3,10), ~, M_elbo] = rankest(full(tns).data);
% times(3,1) = toc(t_elbo);

[ranks_arno, U_arnoldi, times(4,1)] = arnoldi_rank_init(tns);

%% over estimate dimension of initialization according to the largest mode
% 
k = max(size(tns));
modes = ndims(tns);
t_construct = tic;
Us = cp_init_arnoldi(tns,k);
t_construct = toc(t_construct);
cond_nums = zeros(k, modes);

for jdx = 1:modes
    for idx = 1:k
        cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
    end
end

%% looking for the inflection, looks like the cond_ratio is giving best indication of possible rank
cond_ratios = zeros(k-1,modes);
% cond_scaled_diff = zeros(k-1,modes);
for jdx = 1:modes
    for idx = 1:(k-1)
        cond_ratios(idx,jdx) = cond_nums(idx+1,3) / cond_nums(idx,3);
%         cond_scaled_diff(idx,jdx) = 100 * (cond_nums(idx+1, 3) - cond_nums(idx,3));
    end
end

mode_ks = zeros(modes,1);
for jdx = 1:modes
    tmp_k = 0;
    for idx = 1:(k-1)
        if cond_ratios(idx,jdx) > 1.001
            tmp_k = idx;
            break;
        end
    end
    mode_ks(jdx,1) = tmp_k;
end

%% plot condition numbers and condition number ratios
figure;
for cols = 1:modes
    for rows = 1:2
        subplot(2,modes, (modes * (rows -1) + cols));
        if rows == 1
            plot(cond_nums(1:25,cols));
        else
            plot(cond_ratios(1:25,cols));
        end
    end 
end

%% compare CORCONDIA (1), NORMO(2), and ARNOLDI (3) fits
ranks_enron = [12 11 21];

num_decomps = length(ranks_enron);
num_runs = 10;
M_inits = cell(num_decomps,1);
M_fins = cell(num_runs,num_decomps);
outs = cell(num_runs, num_decomps);

% isolate arnoldi initializations for each rank
for jdx = 1:num_decomps
    tmp_U = cell(modes, 1);
    for idx = 1:modes
        tmp_U{idx,1} = Us{idx,1}(:,1:ranks_enron(jdx));
    end
    M_inits{jdx,1} = tmp_U;
end

% perform decompositions
for kdx = 1:num_runs
    for jdx = 1:num_decomps
        [M_fins{kdx,jdx}, ~, outs{kdx,jdx}] = cp_als(tns, ranks_enron(jdx), 'init', M_inits{jdx,1}, 'printitn',0, 'maxiters', 1000);
    end
end

%% plot fits for each rank estimation using the same arnoldi constructed initialization
ests = ['Corcondia' 'NORMO' 'Arnoldi'];
figure;
hold on;
for idx = 1:num_decomps
    plot(outs{1, idx}.fits(outs{1,idx}.fits > 0));
end
legend('Corcondia (12)', 'NORMO (11)', 'Arnoldi (21)');
hold off;



