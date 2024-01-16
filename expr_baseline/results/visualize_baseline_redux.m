%% create 'cleaned' version of resulst (i.e. fits > 1)
cl_best_fits = best_fits;
cl_best_fits(cl_best_fits > 1) = NaN;

cl_best_cossims = best_cossims;
cl_best_cossims(cl_best_cossims > 1) = NaN;

cl_best_times = best_times;
cl_best_cossims(cl_best_cossims > 1) = NaN;

cl_best_corcondias = best_corcondias;
cl_best_corcondias(cl_best_corcondias > 1) = NaN;

%% same, but split into individual figures for each generator type
for i=1:num_gens
    % brute force plot and boxplot to be same size in subplot
    % see https://www.mathworks.com/help/matlab/ref/subplot.html
    plt = figure;
    plot(squeeze(best_fits(i,:,:)));
    gen = strcat('Generator - ',gens{i});
    legend(losses);
    ylabel('Fit Score');
    ax1 = gca;    
    bx_plt = figure;
    boxplot(squeeze(best_fits(i,:,:)),'Labels', losses);
    ax2 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    ax1_copy = copyobj(ax1, fnew);
    subplot(1,2,1,ax1_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(1,2,2,ax2_copy);
    sgtitle(gen);

    % clean up
    figure(plt);
    close;
    figure(bx_plt);
    close;
end

%% make clean version of above
for i=1:num_gens
    % brute force plot and boxplot to be same size in subplot
    % see https://www.mathworks.com/help/matlab/ref/subplot.html
    plt = figure;
    plot(squeeze(cl_best_fits(i,:,:)));
    gen = strcat('Generator - ',gens{i}, ' (clean)');
    legend(losses);
    ylabel('Fit Score');
    ax1 = gca;    
    bx_plt = figure;
    boxplot(squeeze(cl_best_fits(i,:,:)),'Labels', losses);
    ax2 = gca;

    % build the plot & boxplot figure
    fnew = figure;
    ax1_copy = copyobj(ax1, fnew);
    subplot(1,2,1,ax1_copy(1));
    legend(losses);
    ylabel('Fit Score');
    copies = copyobj(ax2, fnew);
    ax2_copy = copies(1);
    subplot(1,2,2,ax2_copy);
    sgtitle(gen);

    % clean up
    figure(plt);
    close;
    figure(bx_plt);
    close;
end
%% make standard plots and boxplots of raw results (grouped by metric)