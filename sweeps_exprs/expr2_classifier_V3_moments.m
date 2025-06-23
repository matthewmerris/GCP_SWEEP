%% Baseline comparison model - train on statistical moments of the data
raw_data_moments = cell(num_gens * num_tensors,7);
for idx = 1:num_gens
    for jdx = 1:num_tensors
        row_idx = (idx-1)*num_tensors + jdx;
        tmp_tns = tensors{jdx,idx};
        tns_data = tmp_tns.data(:);
        raw_data_moments{row_idx, 1} = mean(tns_data);
        raw_data_moments{row_idx, 2} = var(tns_data);
        raw_data_moments{row_idx, 3} = skewness(tns_data);
        raw_data_moments{row_idx, 4} = kurtosis(tns_data);
        raw_data_moments{row_idx, 5} = ranks(jdx,idx);
        raw_data_moments{row_idx, 6} = "unknown";
        raw_data_moments{row_idx, 7} = gens{idx};
    end
end

%% construct table
col_names = {'Mean', 'Variance', 'Skewness', 'Kurtosis', 'Rank', 'Rank Status', 'Generator'};
tbl = cell2table(raw_data_moments,'VariableNames',col_names);

labelName = 'Generator';
tbl = convertvars(tbl,labelName,"categorical");

categoricalInputs = 'Rank Status';
tbl = convertvars(tbl, categoricalInputs, "categorical");

%% convert categorical variables to one-hot and split variables
oh = onehotencode(tbl(:,categoricalInputs));
tbl = addvars(tbl,oh,After=categoricalInputs);
tbl(:,categoricalInputs) = [];

tbl = splitvars(tbl);

%% view class names & split out
classNames = categories(tbl{:,labelName});
numObservations = size(tbl,1);

numObservationsTrain = floor(0.7*numObservations);
numObservationsValidation = floor(0.15*numObservations);
numObservationsTest = numObservations - numObservationsValidation - numObservationsTrain;

numObservationsTrain = floor(0.7*numObservations);
numObservationsValidation = floor(0.15*numObservations);
numObservationsTest = numObservations - numObservationsTrain - numObservationsValidation;

idx = randperm(numObservations);
idxTrain = idx(1:numObservationsTrain);
idxValidation = idx(numObservationsTrain+1:numObservationsTrain + numObservationsValidation);
idxTest = idx(numObservationsTrain + numObservationsValidation + 1:end);

tblTrain = tbl(idxTrain, :);
tblValidation = tbl(idxValidation, :);
tblTest = tbl(idxTest, :);

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