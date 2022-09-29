% some basic params
size = [100 100 100];
R = 100;
num_runs = 10;

losses = {'normal' 'poisson' 'poisson-log' 'negative-binomial (4)'};

% perform a series of runs on a naively generated artificial tensor

for 

info = create_problem('Size', size, 'Num_factors', R);
X = info.Data;
M_true = info.Soln;

