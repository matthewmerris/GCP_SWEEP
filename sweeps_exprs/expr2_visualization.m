%% print out fits
for idx = 1:num_gens
    tmp_title = sprintf("FITS - Generator: %s\n", gens{1,idx});
    tmp_fit = squeeze(fits(idx,:,:))

end

%% box plots for 50 tensors, global FIT performance view
figure;
for idx = 1:num_gens
    subplot(1,num_gens,idx);
    tmp_title = sprintf("Generator: %s\n", gens{1,idx});
    tmp_fit = squeeze(fits(idx,:,:));
    boxplot(tmp_fit);
    xticklabels(losses);
    title(tmp_title);
end


%% print out cossims
for idx = 1:num_gens
    fprintf("COSSIMs - Generator: %s\n", gens{1,idx});
    squeeze(cossims(idx,:,:))
end

%% box plots for 50 tensors, global
figure;
for idx = 1:num_gens
    subplot(1,num_gens,idx);
    tmp_title = sprintf("Generator: %s\n", gens{1,idx});
    tmp_fit = squeeze(cossims(idx,:,:));
    boxplot(tmp_fit);
    xticklabels(losses);
    title(tmp_title);
end

%% print out corcondias
for idx = 1:num_gens
    fprintf("CORCONDIAs - Generator: %s\n", gens{1,idx});
    squeeze(corcondias(idx,:,:))
end

%% box plots for 50 tensors, global CORCONDIAs view
figure;
for idx = 1:num_gens
    subplot(1,num_gens,idx);
    tmp_title = sprintf("Generator: %s\n", gens{1,idx});
    tmp_fit = squeeze(corcondias(idx,:,:));
    boxplot(tmp_fit);
    xticklabels(losses);
    set(gcs)
    title(tmp_title);
end

%% print out times
for idx = 1:num_gens
    fprintf("TIMES - Generator: %s\n", gens{1,idx});
    squeeze(times(idx,:,:))
end

%% box plots for 50 tensors, global TIMES view
figure;
for idx = 1:num_gens
    subplot(1,num_gens,idx);
    tmp_title = sprintf("Generator: %s\n", gens{1,idx});
    tmp_fit = squeeze(times(idx,:,:));
    boxplot(tmp_fit);
    xticklabels(losses);
    title(tmp_title);
end

%% Master Metrics Boxplots (Generator x Metric subplot structure)
figure;
title("Generator x Metric - 5 losses (x-axises)");
num_metrics = 4;
for idx = 1:num_gens
    sp_idx = (idx-1)*num_metrics;
    for jdx = 1:num_metrics
        subplot(num_gens, num_metrics, sp_idx + jdx);
        if jdx == 1
            boxplot(squeeze(fits(idx,:,:)));
            if idx == 1
                title("Fit Scores");
            end
        elseif jdx == 2
            boxplot(squeeze(cossims(idx,:,:)));
            if idx ==1
                title("Cossim Scores");
            end
        elseif jdx == 3
            boxplot(squeeze(corcondias(idx,:,:)));
            if idx == 1
                title("Corcondia Scores");
            end
        elseif jdx == 4
            boxplot(squeeze(times(idx,:,:)));
        end
        xticklabels(losses);
    end
end


%% Metrics Boxplots for each generation method

num_metrics = 4;
for idx = 1:num_gens
    figure;
    tmp_title = sprintf("Generator: %s - All Metrics", gens{idx});
%     sgtitle(tmp_title);
    for jdx = 1:num_metrics
        subplot(1, num_metrics, jdx);
        if jdx == 1
            boxplot(squeeze(fits(idx,:,:)));
            title("Fit Scores");
            ylabel(tmp_title);
        elseif jdx == 2
            boxplot(squeeze(cossims(idx,:,:)));
            title("Cossim Scores");
        elseif jdx == 3
            boxplot(squeeze(corcondias(idx,:,:)));
            title("Corcondia Scores");
        elseif jdx == 4
            boxplot(squeeze(times(idx,:,:)));
            title("Times");
        end
        xticklabels(losses);
    end
    
end

%% construct tables for means of each metric -- FITS
mean_fits = zeros(num_gens,num_losses);
for idx = 1:num_gens
    tmp_means = mean(squeeze(fits(idx,:,:)));
    mean_fits(idx,:) = tmp_means;
end
mat2latextable(mean_fits, '%0.4f');


