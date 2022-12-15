% some basic params
sz = [10 10 10];
R = 3;
num_runs = 1000;
dims = length(sz);

% losses = {'normal' 'rayleigh' 'gamma' 'huber (0.25)' 'beta (0.3)'};
losses = {'beta (0.3)' 'gamma' 'huber (0.25)' 'normal','rayleigh'}; % 
num_losses = length(losses);
counter = 0;

% Non-negative factor generator types
gen_types = {'rand'}; % 'randn', 'rayleigh', 'beta', 'gamma'

for k=1:length(gen_types)
    % run suite of increasingly perturbed experiments
    for pturb_lvl = 0:0.2:1
        % containers for results
        times_opt = zeros(1, num_runs);
        times_gcp = zeros(num_losses, num_runs);

        fits_opt = zeros(1, num_runs);
        fits_gcp = zeros(num_losses, num_runs);

        scores_opt = zeros(1, num_runs);
        scores_gcp = zeros(num_losses, num_runs);

        % loglikes_opt = zeros(1, num_runs);
        % loglikes_gcp = zeros(num_losses, num_runs);

        cossim_opt = zeros(1, num_runs);
        cossim_gcp = zeros(num_losses, num_runs);

        % perform a series of runs on a naively generated artificial tensor

        for run = 1:num_runs
            % create a problem
            info = NN_tensor_generator('Size', sz, 'Num_factors', R, ...
                                        'Factor_Gen', gen_types{k});
            X = info.Data;
            M_true = info.Soln;
            % perturb solution factors for initial guess
            if pturb_lvl == 1
                M_init = create_guess('Soln',info.Soln, 'Factor_Generator', 'pertubation',...
                                    'Pertubation', 0.99999);
            else
                M_init = create_guess('Soln',info.Soln, 'Factor_Generator', 'pertubation',...
                                    'Pertubation', pturb_lvl);
            end      
            
            % feed problem and guess to gcp, cp-opt
            for i = 1:num_losses
                % decompose and compare with gcp
                tic, [M_gcp, M_0, out_gcp] = gcp_opt(X, R, 'type', losses{i},'printitn', 0, 'init', M_init); 
                times_gcp(i,run) = toc;
                scores_gcp(i,run) = score(M_gcp, M_true, 'greedy', false);
                fits_gcp(i,run) = 1 - norm(X-full(M_gcp))/norm(X);
        %         loglikes_gcp(i,run) = tt_loglikelihood(X, M_gcp);
                cossim_gcp(i,run) = cosSim(X, M_gcp, ndims(X));
            end
        end


        % one plot to rule them all, higher scores are better
        figure;
        subplot(2,3,1)
        scatter(categorical(losses), mean(fits_gcp,2))
    %     ylim([-inf, 1.01]);
        title('Fit - mean')

        subplot(2,3,4)
        boxplot(fits_gcp.', losses)
        title('Fit')

        subplot(2,3,2);
        scatter(categorical(losses), mean(scores_gcp,2));
    %     ylim([-0.01, 1.01]);
        title('Score - mean')

        subplot(2,3,5);
        boxplot(scores_gcp.', losses);
        title('Score')

        subplot(2,3,3);
        scatter(categorical(losses), mean(cossim_gcp,2));
    %     ylim([-0.01, 1.01]);
        title('Cos Similarity - mean');

        subplot(2,3,6);
        boxplot(cossim_gcp.', losses)
        title('Cos Similarity')
        counter = counter + 1;
        sgtitle("Non-negative Data ("+ gen_types{k} + ") - Perturbation: " + pturb_lvl);
    end
    
end