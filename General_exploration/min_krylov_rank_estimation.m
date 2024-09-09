%% generate a problem and gather relevant details

sz = [10 10 10];
nc = 5;
modes = length(sz);
tns = create_problem('Size', sz, 'Factor_Generator', 'stochastic', ...
     'Num_Factors', nc,'Sparse_Generation', .99, 'Noise', 0);

% chi_4d_path = '/Users/matthewmerris/datasets/FROSTT/chicago/chicago-crime-comm.tns';
% tns = load_frostt(chi_4d_path);
% 
% uber_path = '/Users/matthewmerris/datasets/FROSTT/uber/uber.tns';
% tns = load_frostt(uber_path);



% sz = size(tns);
% modes = length(sz);
%%

k = 100;

Us = cp_init_arnoldi(full(tns),k);

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
%% looking for the inflection
cond_ratios = zeros(k-1,1);
cond_scaled_diff = zeros(k-1,1);
for idx = 1:(k-1)
    cond_ratios(idx,1) = cond_nums(idx+1,3) / cond_nums(idx,3);
    cond_scaled_diff(idx,1) = 100 * (cond_nums(idx+1, 3) - cond_nums(idx,3));
end
figure;
plot(cond_ratios(48:55,1));
figure;
plot(cond_scaled_diff(48:55,1));

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

%% figuring out if reshape and unfold can be interchangable
mode1_sz = zeros(2,1);
mode1_sz(1) = sz(1);
mode1_sz(2) = prod(sz(2:modes));
testie = sptensor(tns.Data);
testie = reshape(testie, mode1_sz);
tns = unfold(full(tns.Data),1);