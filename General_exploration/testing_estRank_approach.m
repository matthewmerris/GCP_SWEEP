%% Proding estRank,  
% a modal unfolding approach based on singular value thresholding
% for estimating tensor rank and providing an initialization for the 
% factor matrices of a CP decomposition of a data tensor.
clear;
size = [30, 40, 55];
X = NN_tensor_generator_whole('Size', size);
[rank, factors] = estRank(X.Data);