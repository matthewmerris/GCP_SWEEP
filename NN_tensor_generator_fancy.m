function [info,params] = NN_tensor_generator_fancy(varargin)
%NN_TENSOR_GENERATOR Summary of this function goes here
%   Detailed explanation goes here

% set-up random
defaultStream = RandStream.getGlobalStream;

% parse arguments
p = inputParser;
p.addParamValue('State', defaultStream.State, @(x) true);
p.addParamValue('Soln', [], @(x) isempty(x) || isa(x,'ktensor') || isa(x,'ttensor'));
p.addParamValue('Type', 'CP', @(x) ismember(lower(x),{'cp','tucker'}));
p.addParamValue('Size', [100 100 100], @all);
p.addParamValue('Num_Factors', 2, @all);
p.addParamValue('Noise', 0.0, @all);
p.addParamValue('Factor_Gen', 'rand', @(x) ismember(lower(x), {'rand', 'rayleigh', 'beta', 'gamma'}));

p.parse(varargin{:});
params = p.Results;

% initialize random generator
defaultStream.State = params.State;

% initialize return structure for data generated
info = struct;

% hijacking custom factor generator example from 
% https://www.tensortoolbox.org/test_problems_doc.html
nc = params.Num_Factors;    % i.e. CP-rank
sz = params.Size;
nd = length(sz);
nz = params.Noise;

% Set up a factor generator
pdf = lower(params.Factor_Gen);
switch pdf
    case 'rand'
        factor_generator = @(m,n) rand(m,n) + ones(m,n);
    case 'rayleigh'
        factor_generator = @(m,n) raylrnd(10,m,n);
    case 'beta'
        factor_generator = @(m,n) betarnd(1,3,m,n);
    case 'gamma'
        factor_generator = @(m,n) randg(11,m,n);
    otherwise 
        factor_generator = @(m,n) 100*rand(m,n);
end

% Make the problem tensor
info = create_problem('Size', sz, 'Num_factors', nc, ...
     'Factor_Generator', factor_generator, 'Lambda_Generator', @ones, 'Noise', nz); 


end

