%% fill in missing parameters
losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
num_losses = length(losses);
rng(1339)
max_epochs = 30;
%% prep the data

raw_data_1 = cell(num_gens * num_tensors,7);
raw_data_2 = cell(num_gens * num_tensors * num_losses, 8);  % hard coding feature vector length
raw_data_3 = cell(num_gens * num_tensors * num_losses, 12);  % hard coding feature vector length
for idx = 1:num_gens
    for jdx = 1:num_tensors
        row_idx = (idx-1)*num_tensors + jdx;
        tmp_tns = tensors{jdx,idx};
        tns_data = tmp_tns.data(:);
        m1 = mean(tns_data);
        m2 = var(tns_data);
        m3 = skewness(tns_data);
        m4 = kurtosis(tns_data);
        % M1 features (6 total, 1 label)
        raw_data_1{row_idx, 1} = m1;
        raw_data_1{row_idx, 2} = m2;
        raw_data_1{row_idx, 3} = m3;
        raw_data_1{row_idx, 4} = m4;
        raw_data_1{row_idx, 5} = ranks(jdx,idx);
        raw_data_1{row_idx, 6} = "unknown";
        raw_data_1{row_idx, 7} = gens{idx};
        for kdx = 1:num_losses
            row_idx = kdx + (idx -1)*(num_tensors*num_losses) + (jdx -1)*num_losses;
            % M2 features (7 total, 1 label)
            raw_data_2{row_idx, 1} = fits(idx, jdx, kdx);
            raw_data_2{row_idx, 2} = cossims(idx, jdx, kdx);
            raw_data_2{row_idx, 3} = corcondias(idx, jdx, kdx);
            raw_data_2{row_idx, 4} = times(idx, jdx, kdx);
            raw_data_2{row_idx, 5} = ranks(jdx,idx);
            raw_data_2{row_idx, 6} = "unknown";
            raw_data_2{row_idx, 7} = losses{kdx};
            raw_data_2{row_idx, 8} = gens{idx};

            % M3 features (11 total, 1 label)
            raw_data_3{row_idx, 1} = m1;
            raw_data_3{row_idx, 2} = m2;
            raw_data_3{row_idx, 3} = m3;
            raw_data_3{row_idx, 4} = m4;
            raw_data_3{row_idx, 5} = fits(idx, jdx, kdx);
            raw_data_3{row_idx, 6} = cossims(idx, jdx, kdx);
            raw_data_3{row_idx, 7} = corcondias(idx, jdx, kdx);
            raw_data_3{row_idx, 8} = times(idx, jdx, kdx);
            raw_data_3{row_idx, 9} = ranks(jdx,idx);
            raw_data_3{row_idx, 10} = "unknown";
            raw_data_3{row_idx, 11} = losses{kdx};
            raw_data_3{row_idx, 12} = gens{idx};
        end
    end
end

%% construct tables & model (M1)
% M1 table
col_names_1 = {'Mean', 'Variance', 'Skewness', 'Kurtosis', 'Rank', 'Rank Status', 'Generator'};
tbl_1 = cell2table(raw_data_1,'VariableNames',col_names_1);

labelName = 'Generator';
tbl_1 = convertvars(tbl_1,labelName,"categorical");

categoricalInputs = 'Rank Status';
tbl_1 = convertvars(tbl_1, categoricalInputs, "categorical");

% convert categorical variables to one-hot and split variables
oh_1 = onehotencode(tbl_1(:,categoricalInputs));
tbl_1 = addvars(tbl_1,oh_1,After=categoricalInputs);
tbl_1(:,categoricalInputs) = [];

tbl_1 = splitvars(tbl_1);

% view class names & split out
classNames = categories(tbl_1{:,labelName});
numObservations = size(tbl_1,1);

numObservationsTrain = floor(0.7*numObservations);
numObservationsValidation = floor(0.15*numObservations);
numObservationsTest = numObservations - numObservationsTrain - numObservationsValidation;

idx = randperm(numObservations);
idxTrain = idx(1:numObservationsTrain);
idxValidation = idx(numObservationsTrain+1:numObservationsTrain + numObservationsValidation);
idxTest = idx(numObservationsTrain + numObservationsValidation + 1:end);

tblTrain_1 = tbl_1(idxTrain, :);
tblValidation_1 = tbl_1(idxValidation, :);
tblTest_1 = tbl_1(idxTest, :);

numFeatures_1 = size(tbl_1,2)-1;
numClasses = numel(classNames);

layers = [
    featureInputLayer(numFeatures_1,Normalization="zscore")
    fullyConnectedLayer(100)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];

% Specify Training options
miniBatchSize = 50;

options = trainingOptions("adam", ...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    ValidationData=tblValidation_1, ...
    Plots="training-progress", ...
    Metrics=["accuracy", "fscore"], ...
    Verbose=false, ...
    MaxEpochs=5*max_epochs);

% Train the network
[net_1, info_1] = trainnet(tblTrain_1,layers,"crossentropy",options);

% Test Network
scores_1 = minibatchpredict(net_1,tblTest_1(:,1:end-1),MiniBatchSize=miniBatchSize);
YPred_1 = scores2label(scores_1, classNames);
YTest_1 = tblTest_1{:,labelName};
accuracy_1 = sum(YPred_1 == YTest_1)/numel(YTest_1)

figure;
confusionchart(YTest_1,YPred_1);

%% construct tables & model (M2 & M3)
% prep tbl_2
col_names_2 = {'Fit Score', 'COSSIM', 'CORCONDIA', 'Time', 'Rank', 'Rank Status', 'Loss', 'Generator'};
tbl_2 = cell2table(raw_data_2, 'VariableNames',col_names_2);
labelName = 'Generator';
tbl_2 = convertvars(tbl_2, labelName, "categorical");
categoricalInputs = ["Loss", "Rank Status"];
tbl_2 = convertvars(tbl_2, categoricalInputs,"categorical");

for i = 1:numel(categoricalInputs)
    name = categoricalInputs(i);
    oh = onehotencode(tbl_2(:,name));
    tbl_2 = addvars(tbl_2,oh,After=name);
    tbl_2(:,name) = [];
end

tbl_2 = splitvars(tbl_2);

% prep tbl_3
col_names_3 = {'Mean', 'Variance', 'Skewness', 'Kurtosis', ...
    'Fit Score', 'COSSIM', 'CORCONDIA', 'Time', ...
    'Rank', 'Rank Status', 'Loss', 'Generator'};
tbl_3 = cell2table(raw_data_3, 'VariableNames',col_names_3);
labelName = 'Generator';
tbl_3 = convertvars(tbl_3, labelName, "categorical");
categoricalInputs = ["Loss", "Rank Status"];
tbl_3 = convertvars(tbl_3, categoricalInputs,"categorical");
% convert categorical variables to one-hot and split variables
for i = 1:numel(categoricalInputs)
    name = categoricalInputs(i);
    oh = onehotencode(tbl_3(:,name));
    tbl_3 = addvars(tbl_3,oh,After=name);
    tbl_3(:,name) = [];
end

tbl_3 = splitvars(tbl_3);

%% perform clustered split on tbl_2 & tbl_3
classNames = categories(tbl_2{:,labelName});
numObservations = size(tbl_2, 1);  % same # of observations in same order

numClumps = numObservations / num_losses;
numClumpsTrain = floor(0.7*numClumps);
numClumpsValidation = floor(0.15*numClumps);
numClumpsTest = numClumps - numClumpsTrain - numClumpsValidation;

clump_idx = randperm(numClumps);
clump_idxTrain = clump_idx(1:numClumpsTrain);
clump_idxValidation = clump_idx(numClumpsTrain+1:numClumpsTrain + numClumpsValidation);
clump_idxTest = clump_idx(numClumpsTrain + numClumpsValidation + 1:end);

train_idx = [];
for k = 1:numel(clump_idxTrain)
    start_idx = (clump_idxTrain(k) - 1) * num_losses + 1;
    end_idx = (clump_idxTrain(k) - 1) * num_losses + num_losses;
    train_idx = [train_idx start_idx:end_idx];
end
tblTrain_2 = tbl_2(train_idx,:);
tblTrain_3 = tbl_3(train_idx,:);

validation_idx = [];
for k = 1:numel(clump_idxValidation)
    start_idx = (clump_idxValidation(k) - 1) * num_losses + 1;
    end_idx = (clump_idxValidation(k) - 1) * num_losses + num_losses;
    validation_idx = [validation_idx start_idx:end_idx];
end
tblValidation_2 = tbl_2(validation_idx,:);
tblValidation_3 = tbl_3(validation_idx,:);

test_idx = [];
for k = 1:numel(clump_idxTest)
    start_idx = (clump_idxTest(k) - 1)*num_losses + 1;
    end_idx = (clump_idxTest(k) - 1)*num_losses + num_losses;
    test_idx = [test_idx start_idx:end_idx];
end
tblTest_2 = tbl_2(test_idx,:);
tblTest_3 = tbl_3(test_idx,:);

%% Define M2 architecture and train
numFeatures_2 = size(tbl_2,2)-1;
numClasses = numel(classNames);

layers = [
    featureInputLayer(numFeatures_2,Normalization="zscore")
    fullyConnectedLayer(100)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];

miniBatchSize = 50;
options = trainingOptions("adam", ...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    ValidationData=tblValidation_2, ...
    Plots="training-progress", ...
    Metrics=["accuracy", "fscore"], ...
    Verbose=false, ...
    MaxEpochs=max_epochs);

% Train the network
[net_2, info_2] = trainnet(tblTrain_2,layers,"crossentropy",options);

% Test Network
scores_2 = minibatchpredict(net_2,tblTest_2(:,1:end-1),MiniBatchSize=miniBatchSize);
YPred_2 = scores2label(scores_2, classNames);
YTest_2 = tblTest_2{:,labelName};
accuracy_2 = sum(YPred_2 == YTest_2)/numel(YTest_2)

figure;
confusionchart(YTest_2,YPred_2);

%% Define M3 architecture and train
numFeatures_3 = size(tbl_3,2)-1;
numClasses = numel(classNames);

layers = [
    featureInputLayer(numFeatures_3,Normalization="zscore")
    fullyConnectedLayer(100)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];

miniBatchSize = 50;
options = trainingOptions("adam", ...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    ValidationData=tblValidation_3, ...
    Plots="training-progress", ...
    Metrics=["accuracy", "fscore"], ...
    Verbose=false, ...
    MaxEpochs=max_epochs);

% Train the network
[net_3, info_3] = trainnet(tblTrain_3,layers,"crossentropy",options);

% Test Network
scores_3 = minibatchpredict(net_3,tblTest_3(:,1:end-1),MiniBatchSize=miniBatchSize);
YPred_3 = scores2label(scores_3, classNames);
YTest_3 = tblTest_3{:,labelName};
accuracy_3 = sum(YPred_3 == YTest_3)/numel(YTest_3)

figure;
confusionchart(YTest_3,YPred_3);

%% plot training and validation accuracy for all 3 models in one graph
models = ["Moments", "GCP Metrics", "Moments + GCP"];
figure;
hold on;
plot(info_1.ValidationHistory.Iteration, info_1.ValidationHistory.Accuracy,'LineWidth',3);
plot(info_2.ValidationHistory.Iteration, info_2.ValidationHistory.Accuracy,'LineWidth',3);
plot(info_3.ValidationHistory.Iteration, info_3.ValidationHistory.Accuracy,'LineWidth',3);
ylabel("Validation Accuracy");
xlabel("Iteration");
legend(models);
