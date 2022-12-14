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

p.parse(varargin{:});
params = p.Results;

% initialize random generator
defaultStream.State = params.State;

% initialize return structure for data generated
info = struct;

% hijacking custom factor generator example from 
% https://www.tensortoolbox.org/test_problems_doc.html
sz = params.Size;
nd = length(sz);

% Set up a factor generator
gen_type = lower(params.Gen_type);

% build a full tensor based Gen_type
switch gen_type
    case 'rand'
        X = rand(sz);
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

info.data = tensor(X);

% estimate resulting rank


