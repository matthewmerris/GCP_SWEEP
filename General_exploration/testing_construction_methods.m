clear;
%% Some simple testing of current methods for contrusting fake tensors
%  TEST 1: do factor matrices drawn from a known distribution, result in
%  tensor data that follows a similar distribution. 
%  (NN_tensor_generator_fancy)
sz = [10 10 10];
info1 = NN_tensor_generator_fancy('Size', sz, 'Factor_Gen', 'rand');
X1 = info1.Data;
x1 = double(tenmat(X1,1:length(sz)));

subplot(3,2,1)
histfit(x1,12)
title('Gen_{type} - rand')

info2 = NN_tensor_generator_fancy('Size', sz, 'Factor_Gen', 'randn');
X2 = info2.Data;
x2 = double(tenmat(X2,1:length(sz)));

subplot(3,2,2)
histfit(x2,12, 'normal')
title('Gen_{type} - randn')

info3 = NN_tensor_generator_fancy('Size', sz, 'Factor_Gen', 'rayleigh');
X3 = info3.Data;
x3 = double(tenmat(X3,1:length(sz)));
subplot(3,2,3)
histfit(x3,12, 'rayleigh')
title('Gen_{type} - rayleigh')

info4 = NN_tensor_generator_fancy('Size', sz, 'Factor_Gen', 'beta');
X4 = info4.Data;
x4 = double(tenmat(X4,1:length(sz)));
subplot(3,2,4)
histfit(x4,12, 'beta')
title('Gen_{type} - beta')

info5 = NN_tensor_generator_fancy('Size', sz, 'Factor_Gen', 'gamma');
X5 = info5.Data;
x5 = double(tenmat(X5,1:length(sz)));
subplot(3,2,5)
histfit(x5,12, 'gamma')
title('Gen_{type} - gamma')

sgtitle('NN\_tensor\_generator\_fancy');

%% Repeat with NN_tensor_generator_whole
figure;
info6 = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'rand');
X6 = info6.Data;
x6 = double(tenmat(X6,1:length(sz)));
subplot(3,2,1)
histfit(x6,12)
title('Gen_{type} - rand')

info7 = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'randn');
X7 = info7.Data;
x7 = double(tenmat(X7,1:length(sz)));
subplot(3,2,2)
histfit(x7,12)
title('Gen_{type} - randn')

info8 = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'rayleigh');
X8 = info8.Data;
x8 = double(tenmat(X8,1:length(sz)));
subplot(3,2,3)
histfit(x8,12)
title('Gen_{type} - rayleigh')

info9 = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'beta');
X9 = info9.Data;
x9 = double(tenmat(X9,1:length(sz)));
subplot(3,2,4)
histfit(x9,12)
title('Gen_{type} - beta')

info10 = NN_tensor_generator_whole('Size', sz, 'Gen_type', 'gamma');
X10 = info10.Data;
x10 = double(tenmat(X10,1:length(sz)));
subplot(3,2,5)
histfit(x10,12)
title('Gen_{type} - gamma')
sgtitle('NN\_tensor\_generator\_whole');