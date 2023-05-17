function [U,info] = initializeCP(X,varargin)
%INITIALIZECP Summary of this function goes here
%   Detailed explanation goes here

%% Iniital setup
nd  = ndims(X);
sz = size(X);
tsz = prod(sz);

%% Random set-up
defaultStream = RandStream.getGlobalStream;

%% Set algorithm parameters from input or by using defaults
p = inputParser;
p.addParamValue('Factor_Generator', 'rand', @(x) isa(x,'function_handle') || ...
    ismember(lower(x),{'rand','randn','orthogonal','stochastic','nvecs','pertubation'}));
p.addParamValue('Num_Factors', [], @(x) isempty(x) || all(x));
p.addParamValue('State', defaultStream.State, @(x) true);
p.parse(varargin{:});
params = p.Results;

%% Initialize solution using create_guess()
switch(params.Factor_Generator)
    case 'rand'       
        U = create_guess('Factor_Generator', 'rand', 'Size', sz, 'Num_Factors', params.Num_Factors);
    case 'randn'       
        U = create_guess('Factor_Generator', 'randn', 'Size', sz, 'Num_Factors', params.Num_Factors);
    case 'orthogonal'
        U = create_guess('Factor_Generator', 'orthogonal', 'Size', sz, 'Num_Factors', params.Num_Factors);
    case 'stochastic'
        U = create_guess('Factor_Generator', 'stochastic', 'Size', sz, 'Num_Factors', params.Num_Factors);
    case 'nvecs'
        U = create_guess('Factor_Generator', 'nvecs', 'Size', sz, 'Num_Factors', params.Num_Factors, ...
            'Data', X);
end

%% Stomp out negative values
eps = 1e-8;
for i = 1:nd
    U{i} = max(U{i}, eps);
end
info.params = params;

end

