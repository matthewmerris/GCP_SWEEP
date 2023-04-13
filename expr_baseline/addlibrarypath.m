function [] = addlibrarypath(inputArg1,inputArg2)
%ADDLIBRARYPATH : adds specified paths to the matlab path and saves it
addpath(genpath(inputArg1));
addpath(genpath(inputArg2));
savepath;
end

