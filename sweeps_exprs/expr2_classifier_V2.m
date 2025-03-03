%% fill in missing parameters
losses = ["normal", "huber (0.25)","rayleigh", "gamma","beta (0.3)"];
num_losses = length(losses);

%% prep the data
raw_data = cell(num_gens * num_tensors * num_losses, 8);  % hard coding feature vector length
for idx = 1:num_gens
    for jdx = 1:num_tensors
        for kdx = 1:num_losses
            row_idx = kdx + (idx -1)*(num_tensors*num_losses) + (jdx -1)*num_losses;
            raw_data{row_idx, 1} = fits(idx, jdx, kdx);
            raw_data{row_idx, 2} = cossims(idx, jdx, kdx);
            raw_data{row_idx, 3} = corcondias(idx, jdx, kdx);
            raw_data{row_idx, 4} = times(idx, jdx, kdx);
            raw_data{row_idx, 5} = ranks(jdx,idx);
            raw_data{row_idx, 6} = "unknown";
            raw_data{row_idx, 7} = losses{kdx};
            raw_data{row_idx, 8} = gens{idx};
        end
    end
end

%% construct a table
col_names = {'Fit Score', 'COSSIM', 'CORCONDIA', 'Time', 'Rank', 'Rank Status', 'Loss', 'Generator'};
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
miniBatchSize = 25;

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