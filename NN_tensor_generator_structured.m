function [info,params] = NN_tensor_generator_structured(varargin)
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
p.addParamValue('Lambda_Gen', 'rand', @(x) ismember(lower(x), {'rand', 'rayleigh', 'beta', 'gamma', 'randn'}));

p.parse(varargin{:});
params = p.Results;

% initialize random generator
defaultStream.State = params.State;

% initialize return structure for data generated
info = struct;

% hijacking Rayleigh example from 
% http://www.tensortoolbox.org/gcp_opt_doc.html#12 
% modifying method to absorb the pdf samples into the
% first factor matrix
nc = params.Num_Factors;
sz = params.Size;
nd = length(sz);

U=cell(1,nd);
for k=1:nd
    V = 1.1 + cos(bsxfun(@times, 2*pi/sz(k)*(0:sz(k)-1)', 1:nc));
    U{k} = V(:,randperm(nc));
end

% apply specific data distribution type
pdf = lower(params.Lambda_Gen);
switch pdf
    case 'rand'
        lambda = rand(1,nc) + 1;
        lambda = sort(lambda,'descend');
    case 'randn'
        a = 5;
        b = 20;
        lambda = a*randn(1,nc) + b;
        lambda = sort(lambda,'descend');
    case 'rayleigh'
        lambda = sort(raylrnd(10,1,nc),'descend');
    case 'beta'
        lambda = sort(betarnd(1,3,[1 nc]),'descend');
    case 'gamma'
        lambda = sort(gamrnd(11,5,1,nc),'descend');
    otherwise
        lambda = rand(1,nc) + 1;
        lambda = sort(lambda,'descend');
end

M_true = normalize(ktensor(lambda',U));

info.Soln = M_true;
info.Data = full(M_true);

end

