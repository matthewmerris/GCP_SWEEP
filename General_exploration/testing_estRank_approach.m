%% Proding estRank,  
% a modal unfolding approach based on singular value thresholding
% for estimating tensor rank and providing an initialization for the 
% factor matrices of a CP decomposition of a data tensor.
size = [30, 30, 30];
X = NN_tensor_generator_whole('Size', size);
[rank, factors] = estRank(X.Data);