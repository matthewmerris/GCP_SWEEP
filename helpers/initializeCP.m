function [M0,info] = initializeCP(X,vargin)
%INITIALIZECP Summary of this function goes here
%   Detailed explanation goes here

%% Iniital setup
nd  = ndims(X);
sz = size(X);
tsz = prod(sz);

%% Random set-up
defaultStream = RandStream.getGlobalStream;

%% Set algorithm parameters from input or by using defaults
params = inputParser;


end

