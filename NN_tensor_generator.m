function [info,params] = NN_tensor_generator(varargin)
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

p.parse(varargin{:});
params = p.Results;

% initialize random generator
defaultStream.State = params.State;

% initialize return structure for data generated
info = struct;

% hijacking Rayleigh example from 
% http://www.tensortoolbox.org/gcp_opt_doc.html#12
nc = params.Num_Factors;
sz = params.Size;
nd = length(sz);

U=cell(1,nd);
for k=1:nd
    V = 1.1 + cos(bsxfun(@times, 2*pi/sz(k)*(0:sz(k)-1)', 1:nc));
    U{k} = V(:,randperm(nc));
end
M_true = normalize(ktensor(U));
info.Soln = M_true;

% UPDATE THIS FOR OTHER NN DATA TYPES (GAMMA, etc)
X = tenfun(@raylrnd, full(M_true));
info.Data = X;

end

