%% fill in missing parameters
losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
num_losses = length(losses);

%% prep the data
raw_data = cell(num_gens * num_tensors * num_losses, 12);  % hard coding feature vector length
for idx = 1:num_gens
    for jdx = 1:num_tensors
        tmp_tns = tensors{jdx,idx};
        tns_data = tmp_tns.data(:);
        m1 = mean(tns_data);
        m2 = var(tns_data);
        m3 = skewness(tns_data);
        m4 = kurtosis(tns_data);
        for kdx = 1:num_losses
            row_idx = kdx + (idx -1)*(num_tensors*num_losses) + (jdx -1)*num_losses;
            raw_data{row_idx, 1} = m1;
            raw_data{row_idx, 2} = m2;
            raw_data{row_idx, 3} = m3;
            raw_data{row_idx, 4} = m4;
            raw_data{row_idx, 5} = fits(idx, jdx, kdx);
            raw_data{row_idx, 6} = cossims(idx, jdx, kdx);
            raw_data{row_idx, 7} = corcondias(idx, jdx, kdx);
            raw_data{row_idx, 8} = times(idx, jdx, kdx);
            raw_data{row_idx, 9} = ranks(jdx,idx);
            raw_data{row_idx, 10} = "unknown";
            raw_data{row_idx, 11} = losses{kdx};
            raw_data{row_idx, 12} = gens{idx};
        end
    end
end

%% construct a table
col_names = {'Mean', 'Variance', 'Skewness', 'Kurtosis', ...
    'Fit Score', 'COSSIM', 'CORCONDIA', 'Time', ...
    'Rank', 'Rank Status', 'Loss', 'Generator'};
tbl = cell2table(raw_data, 'VariableNames',col_names);

%% convert labels for prediction to categorical (Generator)
labelName = 'Generator';
tbl = convertvars(tbl, labelName, "categorical");

%% convert categorical features (Loss)
categoricalInputs = ["Loss", "Rank Status"];
tbl = convertvars(tbl, categoricalInputs,"categorical");

%% convert categorical variables to one-hot and split variables
for i = 1:numel(categoricalInputs)
    name = categoricalInputs(i);
    oh = onehotencode(tbl(:,name));
    tbl = addvars(tbl,oh,After=name);
    tbl(:,name) = [];
end

tbl = splitvars(tbl);

%% view class names & split out
classNames = categories(tbl{:,labelName});
numObservations = size(tbl,1);

%% Split by 5 row clumps
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
tblTrain = tbl(train_idx,:);

validation_idx = [];
for k = 1:numel(clump_idxValidation)
    start_idx = (clump_idxValidation(k) - 1) * num_losses + 1;
    end_idx = (clump_idxValidation(k) - 1) * num_losses + num_losses;
    validation_idx = [validation_idx start_idx:end_idx];
end
tblValidation = tbl(validation_idx,:);

test_idx = [];
for k = 1:numel(clump_idxTest)
    start_idx = (clump_idxTest(k) - 1)*num_losses + 1;
    end_idx = (clump_idxTest(k) - 1)*num_losses + num_losses;
    test_idx = [test_idx start_idx:end_idx];
end
tblTest = tbl(test_idx,:);

%% Define network architecture
numFeatures = size(tbl,2)-1;
numClasses = numel(classNames);

layers = [
    featureInputLayer(numFeatures,Normalization="zscore")
    fullyConnectedLayer(100)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];

%% Specify Training options
miniBatchSize = 50;

options = trainingOptions("adam", ...
    MiniBatchSize=miniBatchSize, ...
    Shuffle="every-epoch", ...
    ValidationData=tblValidation, ...
    Plots="training-progress", ...
    Metrics="accuracy", ...
    Verbose=false);

%% Train the network
net = trainnet(tblTrain,layers,"crossentropy",options);

%% Test Network
scores = minibatchpredict(net,tblTest(:,1:end-1),MiniBatchSize=miniBatchSize);
YPred = scores2label(scores, classNames);
YTest = tblTest{:,labelName};
accuracy = sum(YPred == YTest)/numel(YTest)

figure;
confusionchart(YTest,YPred);