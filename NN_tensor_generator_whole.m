function [info,params] = NN_tensor_generator_whole(varargin)
%NN_TENSOR_GENERATOR_WHOLE Summary of this function goes here
%   Detailed explanation goes here

% set-up random
defaultStream = RandStream.getGlobalStream;

% parse arguments
p = inputParser;
p.addParamValue('State', defaultStream.State, @(x) true);
p.addParamValue('Size', [100 100 100], @all);
p.addParamValue('Gen_type', 'rand', @(x) ismember(lower(x), {'rand', 'rayleigh', 'beta', 'gamma'}));
p.addParamValue('Sparsity', 0, @(x) x >= 0 && x < 1);

p.parse(varargin{:});
params = p.Results;

% initialize random generator
defaultStream.State = params.State;

% initialize return structure for data generated
info = struct;

% gather useful information
sz = params.Size;
nd = length(sz);

% Set up a factor generator
gen_type = lower(params.Gen_type);

% build a full tensor based Gen_type
switch gen_type
    case 'rand'
        X = rand(sz) + ones(sz);
    case 'rayleigh'
        X = raylrnd(10,sz);
    case 'beta'
        X = betarnd(1,3,sz);
    case 'gamma'
        X = randg(11,sz);
    case 'randn'
        X = randn(sz) + ones(sz);
    otherwise 
        X = randn(sz) + ones(sz);
end

% handle sparsity case
if params.Sparsity > 0
    numElements = prod(sz);
    nonZeros = (1 - params.Sparsity)*numElements;
    mask = zeros(sz);
    mask(randperm(numel(mask), nonZeros)) = 1;
    info.data = sptensor(X.*mask);
else
    info.data = tensor(X);
end

% estimate resulting rank


