%% Exploring the Enron Emails tensor from FROSTT
% Order:        3
% Dimensions:   184 (sender) x 184 (receiver) x 44 (months)
% Data set constructed as per described in the DEDICOM paper
% http://www.cis.jhu.edu/~parky/Enron
% open the files, all of em for now

raw_data = dlmread('~/datasets/real-world-rank-unknown/FROSTT/Enron/DEDICOM-style/enron_counts.csv');
enron = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;




%% Exploring Enron email Scan Statistics on Enron Graphs
% http://www.cis.jhu.edu/~parky/Enron
raw_data = dlmread("./DEDICOM-style/enron_logcounts.csv");
enron_log = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;

%%

% Lets decompose!
sz = size(enron);
nc = 7;     % literature indicates 7 is a reasonable approximation of rank for enron email tensor
runs = 100;
losses = {'count' 'poisson-log' 'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);


%% old code
fits = zeros(runs,num_losses);
best_fits = cell(num_losses,4);

cossims = zeros(runs,num_losses);
best_cossims = cell(num_losses,4);

times = zeros(runs,num_losses);
best_times = cell(num_losses,4);

corcondias = zeros(runs,num_losses);
best_corcondias = cell(num_losses,4);

ss_angles = cell(runs, num_losses);

f_traces = {};

rng(1339);

t_start = tic;
for i = 1:runs
    % generate a random initialization
%     M_init = create_guess('Data', enron,'Num_Factors', 7);
    M_init = create_guess('Data', enron,'Num_Factors', 7,'Factor_Generator', 'rand');
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(enron, nc, 'type', losses{j},'init', M_init, 'printitn',0, 'maxiters', 5000);
        fits(i,j) = fitScore(enron, M1);
        if isempty(best_fits{j,1}) || fits(i,j) > best_fits{j,1}
            best_fits{j,1} = fits(i,j);
            best_fits{j,2} = M1;
            best_fits{j,3} = out;
            best_fits{j,4} = i;
        end
        cossims(i,j) = cosSim(enron, M1, 3);
        if isempty(best_cossims{j,1}) || cossims(i,j) > best_cossims{j,1}
            best_cossims{j,1} = cossims(i,j);
            best_cossims{j,2} = M1;
            best_cossims{j,3} = out;
            best_cossims{j,4} = i;
        end


        times(i,j) = out.mainTime;
        if isempty(best_times{j,1}) || times(i,j) > best_times{j,1}
            best_times{j,1} = times(i,j);
            best_times{j,2} = M1;
            best_times{j,3} = out;
            best_times{j,4} = i;
        end
        
        [corcondias(i,j),~] = efficient_corcondia(enron, M1);
        if isempty(best_corcondias{j,1}) || corcondias(i,j) > best_corcondias{j,1}
            best_corcondias{j,1} = corcondias(i,j);
            best_corcondias{j,2} = M1;
            best_corcondias{j,3} = out;
            best_corcondias{j,4} = i;
        end

        angles{i,j} = subspaceAngles(full(enron), M1);

        if i == runs
            f_traces{j} = out.fest_trace;
        end
    end
end
toc(t_start);


%% graph some results

% plot fit scores
figure
plot(fits);
xlabel('Run');
ylabel('Fit Score');
title('Fit Scores - Enron 100 runs');
legend(losses);

% plot fit scores without rayleigh
figure
hold on
plot(fits(:,1:3));
plot(fits(:,5:6));
xlabel('Run');
ylabel('Fit Score');
title('Fit Scores - Enron 100 runs (no Rayleigh)');
legend(losses{1:3}, losses{5:6});
hold off

% plot cossims
figure
plot(cossims);
xlabel('Run');
ylabel('Cosine Similarity');
title('Cosine Similarity - Enron 100 runs');
legend(losses);

% plot cossims, omit beta b/c complex
figure
plot(cossims(:,1:5))
xlabel('Run');
ylabel('Cosine Similarity');
title('Cosine Similarity - Enron 100 runs (no Beta)');
legend(losses{1:5});

% plot corcondias
figure
plot(corcondias);
xlabel('Run');
ylabel('Corcondia Score');
title('Corcondia Score - Enron 100 runs');
legend(losses);

% plot corcondias without Huber
figure
hold on
plot(corcondias(:,1:2));
plot(corcondias(:,4:6));
xlabel('Run');
ylabel('Corcondia Score');
title('Corcondia Score (Huber omitted)- Enron 100 runs');
legend(losses{1:2},losses{4:6});
hold off

% plot corcondias Count, Normal, & Rayleigh
figure
hold on
plot(corcondias(:,1:2));
plot(corcondias(:,4));
xlabel('Run');
ylabel('Corcondia Score');
title('Corcondia Score (Count Normal Rayleigh)- Enron 100 runs');
legend(losses{1:2},losses{4});
hold off

% plot corcondias Count & Rayleigh
figure
hold on
plot(corcondias(:,1));
plot(corcondias(:,4));
xlabel('Run');
ylabel('Corcondia Score');
title('Corcondia Score (Count Normal Rayleigh)- Enron 100 runs');
legend(losses{1},losses{4});
hold off


% plot time
figure
plot(times);
xlabel('Run');
ylabel('Time (sec)');
title('Times - Enron 100 runs');
legend(losses);