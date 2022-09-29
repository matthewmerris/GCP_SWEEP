% some basic params
size = [100 100 100];
R = 100;
num_runs = 10;

losses = {'normal' 'rayleigh'};
num_losses = length(losses);

% perform a series of runs on a naively generated artificial tensor

for run = 1:num_runs
    % create a problem
    info = create_problem('Size', size, 'Num_factors', R);
    X = info.Data;
    M_true = info.Soln;
    % create a guess
    init_factors = create_guess('Data', X, 'Factor_Generator', 'nvecs');
    % feed problem and guess to gcp, cp-opt
    for i = 1:num_losses
        % decompose and compare with gcp
    end
end


