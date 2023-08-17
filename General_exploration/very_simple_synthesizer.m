%% designing and testing a very simple artificial tensor generator


%% testing stuff
sz = [15, 10, 5];
rank = 3;
type = 'beta';
[x, k_x] = vsg(sz, rank, type);


%%
% function [ten, k_ten] = simple_generator(sz, rank, type)
%     nd = length(sz);
%     A = cell(nd,1);
%     for i = 1:nd
%         A{i} = ones(sz(i),rank);
%     end
%     % capture desired statistical distro in lambda
%     type = lower(type);
% 
%     switch type
%         case 'rand'
%             lambda = rand(rank,1) + ones(rank,1);
%         case 'rayleigh'
%             lambda = raylrnd(10,{rank,1});
%         case 'beta'
%             lambda = betarnd(1,3,{rank,1});
%         case 'gamma'
%             lambda = randg(11,{rank,1});
%         case 'randn'
%             lambda = randn(rank,1) + ones(rank,1);
%     end
% 
%     % form the ktensor
%     k_ten = ktensor(lambda,A)
%     % form the tensor
%     ten = full(k_ten);
% end