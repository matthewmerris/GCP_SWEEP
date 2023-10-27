%% Exploring GCP hypothesis using real-world, non-negative data of known rank

% Set data file paths
amino_path = '~/datasets/real-world-rank-known/amino/claus.mat';
dorrit_path = '~/datasets/real-world-rank-known/dorrit/dorrit.mat';
sugar_path = '~/datasets/real-world-rank-known/sugar/data.mat'; 

% all datasets are known to be of rank 4, verified via domain experts
nc = 3; 

%% load amino data
load(amino_path);
X_amino = tensor(X);
% adjust to be non-negative
min_val = min(X_amino(:));
adj_by = -1 * min_val + 10*eps;
X_amino = X_amino + adj_by;

%% Perform decompositions of amino data and collect metrics
losses = {'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);
runs = 100;
sz = size(X_amino);

amino_fits = zeros(runs,num_losses);
best_amino_fits = cell(num_losses,4);

amino_cossims = zeros(runs,num_losses);
best_amino_cossims = cell(num_losses,4);

amino_corcondias = zeros(runs,num_losses);
best_amino_corcondias = cell(num_losses,4);

amino_times = zeros(runs,num_losses);
best_amino_times = cell(num_losses,4);

amino_angles = cell(runs, num_losses);
% best_amino_angles = cell(num_losses, 4);

for i = 1:runs
    M_init = create_guess('Data', X_amino,'Num_Factors', nc);
%     M_init = create_guess('Data', X_amino,'Num_Factors', nc,'Factor_Generator', 'nvecs');
    for j = 1:num_losses
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_amino, nc, 'type', losses{j}, 'printitn', 0, 'init', M_init);
        % collect metrics
        amino_fits(i,j) = fitScore(X_amino, M1);
        if isempty(best_amino_fits{j,1}) || amino_fits(i,j) > best_amino_fits{j,1}
            best_amino_fits{j,1} = amino_fits(i,j);
            best_amino_fits{j,2} = M1;
            best_amino_fits{j,3} = out;
            best_amino_fits{j,4} = i;
        end
        
        amino_cossims(i,j) = cosSim(X_amino, M1, 3);
        if isempty(best_amino_cossims{j,1}) || amino_cossims(i,j) > best_amino_cossims{j,1}
            best_amino_cossims{j,1} = amino_cossims(i,j);
            best_amino_cossims{j,2} = M1;
            best_amino_cossims{j,3} = out;
            best_amino_cossims{j,4} = i;
        end

        amino_times(i,j) = out.mainTime;
        if isempty(best_amino_times{j,1}) || amino_times(i,j) > best_amino_times{j,1}
            best_amino_times{j,1} = amino_times(i,j);
            best_amino_times{j,2} = M1;
            best_amino_times{j,3} = out;
            best_amino_times{j,4} = i;
        end

        [amino_corcondias(i,j),~] = efficient_corcondia(X_amino, M1);
        if isempty(best_amino_corcondias{j,1}) || amino_corcondias(i,j) > best_amino_corcondias{j,1}
            best_amino_corcondias{j,1} = amino_corcondias(i,j);
            best_amino_corcondias{j,2} = M1;
            best_amino_corcondias{j,3} = out;
            best_amino_corcondias{j,4} = i;
        end

        amino_angles{i,j} = subspaceAngles(X_amino, M1);

    end
end
% clear X_amino;
%% visualize amino

% BEST METRICS OUT OF 100 RUNS PER LOSS FUNCTION
c = linspace(1,5,length(losses));
figure;
scatter(categorical(losses), cell2mat(best_amino_fits(:,1)),[],c, "filled");
title('Best Fit Scores Of 100 Runs - Amino');

figure;
scatter(categorical(losses), cell2mat(best_amino_cossims(:,1)),[],c, "filled");
title('Best Cosine Similarity Of 100 Runs - Amino');

figure;
scatter(categorical(losses), cell2mat(best_amino_corcondias(:,1)),[],c, "filled");
title('Best Corcondias Of 100 Runs - Amino');

% SUMMARY METRICS 100 RUNS
% Fit Scores - Top 3 Normal, Huber, Beta
figure;
plot(amino_fits);
legend(losses);
xlabel('Fit Score');
ylabel('Run');
title('Fit Score - 100 runs - Amino');

figure;
plot(amino_fits(:,1:2));
legend(losses{1:2});
xlabel('Fit Score');
ylabel('Run');
title('Fit Score - 100 runs - Amino');

% Cosine Similarity
figure;
plot(amino_cossims);
legend(losses);
xlabel('Cosine Similarity');
ylabel('Run');
title('Cosine Similarity - 100 runs - Amino');

figure;
plot(amino_cossims(:,1:2));
legend(losses{1:2});
xlabel('Cosine Similarity');
ylabel('Run');
title('Cosine Similarity - 100 runs - Amino');

% Corcondia Scores
figure;
plot(amino_corcondias);
legend(losses);
xlabel('Corcondia Score');
ylabel('Run');
title('Corcondia Scores - 100 runs - Amino');

figure;
plot(amino_corcondias(:,1:2));
legend(losses{1:2});
xlabel('Corcondia Score');
ylabel('Run');
title('Corcondia Scores - 100 runs - Amino');


%% load dorrit data
load(dorrit_path);
X_dorrit = tensor(EEM.data);
min_val = min(X_dorrit(:));
adj_by = -1 * min_val + 10*eps;
X_dorrit(isnan(X_dorrit(:)))=0;
X_dorrit = X_dorrit + adj_by;

nc = 4;

dorrit_fits = zeros(runs,num_losses);
best_dorrit_fits = cell(num_losses, 4);

dorrit_cossims = zeros(runs,num_losses);
best_dorrit_cossims = cell(num_losses, 4);

dorrit_times = zeros(runs,num_losses);
best_dorrit_times  = cell(num_losses, 4);

dorrit_corcondias = zeros(runs,num_losses);
best_dorrit_corcondias  = cell(num_losses, 4);

dorrit_angles = cell(runs, num_losses);

for i = 1:runs
    M_init = create_guess('Data', X_dorrit,'Num_Factors', nc);
%     M_init = create_guess('Data', X_dorrit,'Num_Factors', nc,'Factor_Generator', 'nvecs');
    for j = 1:num_losses
        % perform decomposition, GCP default init is 'rand'
        [M1,M0,out] = gcp_opt(X_dorrit, nc, 'type', losses{j}, 'printitn', 0, 'init', M_init);
        
        % collect metrics
        dorrit_fits(i,j) = fitScore(X_dorrit, M1);
        if isempty(best_dorrit_fits{j,1}) || dorrit_fits(i,j) > best_dorrit_fits{j,1}
            best_dorrit_fits{j,1} = dorrit_fits(i,j);
            best_dorrit_fits{j,2} = M1;
            best_dorrit_fits{j,3} = out;
            best_dorrit_fits{j,4} = i;
        end
        
        dorrit_cossims(i,j) = cosSim(X_dorrit, M1, 3);
        if isempty(best_dorrit_cossims{j,1}) || dorrit_cossims(i,j) > best_dorrit_cossims{j,1}
            best_dorrit_cossims{j,1} = dorrit_cossims(i,j);
            best_dorrit_cossims{j,2} = M1;
            best_dorrit_cossims{j,3} = out;
            best_dorrit_cossims{j,4} = i;
        end

        dorrit_times(i,j) = out.mainTime;
        if isempty(best_dorrit_times{j,1}) || dorrit_times(i,j) > best_dorrit_times{j,1}
            best_dorrit_times{j,1} = dorrit_times(i,j);
            best_dorrit_times{j,2} = M1;
            best_dorrit_times{j,3} = out;
            best_dorrit_times{j,4} = i;
        end

        [dorrit_corcondias(i,j),~] = efficient_corcondia(X_dorrit, M1);
        if isempty(best_dorrit_corcondias{j,1}) || dorrit_corcondias(i,j) > best_dorrit_corcondias{j,1}
            best_dorrit_corcondias{j,1} = dorrit_corcondias(i,j);
            best_dorrit_corcondias{j,2} = M1;
            best_dorrit_corcondias{j,3} = out;
            best_dorrit_corcondias{j,4} = i;
        end
        
        dorrit_angles{i,j} = subspaceAngles(X_dorrit, M1);
    end
end

%% build up versions of subspace angle info: 
% 1 - sum across mode
% 2 - average across modes
dorrit_angle_sums = zeros(runs, num_losses);
dorrit_angle_avgs = zeros(runs, num_losses);
dorrit_angle_stds = zeros(runs, num_losses);
for i = 1:runs
    for j = 1:num_losses
        dorrit_angle_sums(i,j) = sum(dorrit_angles{i,j});
        dorrit_angle_avgs(i,j) = mean(dorrit_angles{i,j});
        dorrit_angle_stds(i,j) = std(dorrit_angles{i,j});
    end
end

%% visualize dorrit

% BEST METRICS OUT OF 100 RUNS PER LOSS FUNCTION
c = linspace(1,5,length(losses));
c_mod = linspace(1,4,length(losses)-1);
figure;
scatter(categorical(losses), cell2mat(best_dorrit_fits(:,1)),[],c, "filled");
title('Best Fit Scores Of 100 Runs - Dorrit');

figure;
scatter(categorical(losses), cell2mat(best_dorrit_cossims(:,1)),[],c, "filled");
title('Best Cosine Similarity Of 100 Runs - Dorrit');

figure;
scatter(categorical(losses), cell2mat(best_dorrit_corcondias(:,1)),[],c, "filled");
title('Best Corcondias Of 100 Runs - Dorrit');

figure;
scatter(categorical(losses(2:5)), cell2mat(best_dorrit_corcondias(2:5,1)),[],c_mod, "filled");
title('Best Corcondias Scores Of 100 Runs - Dorrit');

%% SUMMARY METRICS 100 RUNS
% Fit Scores - Top 3 Normal, Huber, Beta
figure;
plot(dorrit_fits);
legend(losses);
xlabel('Fit Score');
ylabel('Run');
title('Fit Score - 100 runs - Dorrit');

figure;
hold on;
plot(dorrit_fits(:,1));
plot(dorrit_fits(:,3));
legend(losses{1}, losses{3});
xlabel('Fit Score');
ylabel('Run');
title('Fit Score - 100 runs - Dorrit');

% Cosine Similarity
figure;
plot(dorrit_cossims);
legend(losses);
xlabel('Cosine Similarity');
ylabel('Run');
title('Cosine Similarity - 100 runs - Dorrit');

figure;
plot(dorrit_cossims(:,1:2));
legend(losses{1:2});
xlabel('Cosine Similarity');
ylabel('Run');
title('Cosine Similarity - 100 runs - Dorrit');

% Corcondia Scores
figure;
plot(dorrit_corcondias);
legend(losses);
xlabel('Corcondia Score');
ylabel('Run');
title('Corcondia Scores - 100 runs - Dorrit');

figure;
plot(dorrit_corcondias(:,2:5));
legend(losses{2:5});
xlabel('Corcondia Score');
ylabel('Run');
title('Corcondia Scores - 100 runs - Dorrit');
