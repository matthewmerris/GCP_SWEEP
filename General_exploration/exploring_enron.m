%% Exploring the Enron Emails tensor from FROSTT
% Order:        4
% Dimensions:   6,066 x 5,699 x 244,268 x 1176
% open the files, all of em for now

raw_data = dlmread("./DEDICOM-style/enron_counts.csv");
enron = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;




%% Exploring Enron email Scan Statistics on Enron Graphs
% http://www.cis.jhu.edu/~parky/Enron
raw_data = dlmread("./DEDICOM-style/enron_logcounts.csv");
enron_log = sptensor(raw_data(:,1:3), raw_data(:,4));
clear raw_data;

%% Lets decompose!
sz = size(enron);
nc = 7;     % literature indicates 7 is a reasonable approximation of rank for enron email tensor
runs = 30;
losses = {'count' 'normal' 'huber (0.25)' 'rayleigh' 'gamma' 'beta (0.3)'}; % GCP loss types
num_losses = length(losses);

fits = zeros(runs,num_losses);
cossims = zeros(runs,num_losses);
times = zeros(runs,num_losses);
corcondias = zeros(runs,num_losses);

for i = 1:runs
    % generate a random initialization
    M_init = create_guess('Data', enron,'Num_Factors', 7);
    for j = 1:num_losses
        [M1, M0, out] = gcp_opt(enron, nc, 'type', losses{j},'init', M_init, 'printitn',0);
%         if eq(full(M0), full(M_init))
%             disp("woe is me");
%         end
        fits(i,j) = fitScore(enron, M1);
        cossims(i,j) = cosSim(enron, M1, 3);
        times(i,j) = out.mainTime;
        [corcondias(i,j),~] = efficient_corcondia(enron, M1);
    end
end

