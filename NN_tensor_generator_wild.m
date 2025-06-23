function [info,params] = NN_tensor_generator_wild(varargin)
%NN_TENSOR_GENERATOR_WILD Summary of this function goes here
%   Detailed explanation goes here

% set-up random
defaultStream = RandStream.getGlobalStream;

% parse arguments
p = inputParser;
p.addParamValue('State', defaultStream.State, @(x) true);
p.addParamValue('Size', [100 100 100], @all);
p.addParamValue('Gen_type', 'rand', @(x) ismember(lower(x), {'rand','randn', 'rayleigh', 'beta', 'gamma'}));
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
        b = rand(1)*randi([1,10]);
        X = raylrnd(b,sz);
    case 'beta'
        a = rand(1)*randi([5,10]);
        b = rand(1)*randi([1,5]);
        X = betarnd(a,b,sz);
    case 'gamma'
        a = randi([1,6]);
        b = randi([5,10]);
        X = gamrnd(a,b,sz); % + ones(sz);
    case 'randn'
        a = randi([1,3]);      % sigma
        b = randi([10,15]);    % mu
        X = a.*randn(sz) + b;
    otherwise 
        a = 2;
        b = 20;
        X = a.*randn(sz) + b;
end

% handle sparsity case
if params.Sparsity > 0
    numElements = prod(sz);
    nonZeros = (1 - params.Sparsity)*numElements;
    mask = zeros(sz);
    mask(randperm(numel(mask), nonZeros)) = 1;
    info.Data = sptensor(X.*mask);
else
    info.Data = tensor(X);
end

end

