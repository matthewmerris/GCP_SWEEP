function tns = load_frostt(data_path)
%LOAD_FROSTT Summary of this function goes here
%   Detailed explanation goes here
raw_data = dlmread(data_path);
[~,cols] = size(raw_data);
modes = cols - 1;
tns = sptensor(raw_data(:,1:modes),raw_data(:,cols));
end

