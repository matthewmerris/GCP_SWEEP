%% generate a problem and gather relevant details

% sz = [100 100 100];
% nc = 20;
% modes = length(sz);
% tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
%      'Num_Factors', nc,'Sparse_Generation', .99, 'Noise', 0);

% chi_4d_path = '~/datasets/FROSTT/chicago/chicago-crime-comm.tns';
% tns = load_frostt(chi_4d_path);
% 
uber_path = '~/datasets/FROSTT/uber/uber.tns';
tns = load_frostt(uber_path);
% 
%  
% 
sz = size(tns);
modes = length(sz);
%%

k = max(sz);
t_construct = tic;
Us = cp_init_arnoldi(tns,k);
t_construct = toc(t_construct);
cond_nums = zeros(k, modes);

for jdx = 1:modes
    for idx = 1:k
        cond_nums(idx, jdx) = cond(Us{jdx}(:,1:idx));
    end
end
 %% visualize cond_nums for each mode
nc = 20;
figure;
for jdx = 1:modes
    subplot(1,modes, jdx);
    semilogy(cond_nums(1:k,jdx));
    xlabel('Num\_cols');
    ylabel('Cond #');
    title('Mode: ', jdx);
    grid on;
end

 %% visualize cond_nums for each mode
nc = 20;
figure;
for jdx = 1:modes
    subplot(1,modes, jdx);
    plot(cond_nums(1:26,jdx)); 
    xlabel('Num\_cols');
    ylabel('Cond #');
    title('Mode: ', jdx);
    grid on;
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

%% plot cond num ratios
figure;
for jdx = 1:modes
    subplot(1, modes, jdx);
    top = (mode_ks(jdx,1) + 5);
    plot(cond_ratios(1:top));
    xlabel('Num\_cols');
    ylabel('Ratio of cond #s');
    xticks(0:25:top);
    title('Mode: ',jdx);
end

%% build initialization
Us1 = cell(modes,1);
max_k = max(mode_ks);
for idx =1:modes
    Us1{idx} = Us{idx}(:,1:max_k);
end
t_decomp = tic;
[M1,~,out1] = cp_als(tns, max_k, 'init', Us1, 'printitn',100, 'maxiters', 1000);
t_decomp = toc(t_decomp);


%% for chi 4d rank_1 = 32 vs rank_2 = 40, lets compare fits!
r1 = 32;
r2 = 40;
Us1 = cell(modes,1);
Us2 = cell(modes,1);
for idx = 1:modes
    Us1{idx} = Us{idx}(:,1:r1);
    Us2{idx} = Us{idx}(:,1:r2);
end
[M1,~,out1] = cp_als(tns, r1, 'init', Us1, 'printitn',100, 'maxiters', 1000);
[M2,~,out2] = cp_als(tns, r2, 'init', Us2, 'printitn',100, 'maxiters', 1000);

%% sptenmat is the way, forward cycle gives result as unfold, but in sparse format

