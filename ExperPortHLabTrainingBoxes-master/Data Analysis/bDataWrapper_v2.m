%% bDataWrapper - wraps behavioral data together

function [behaviorArray] = bDataWrapper_v2(behaviorDir)
fileBehavior = dir([behaviorDir filesep '*mat']);
B = {fileBehavior.name};
numBArrays = numel(B);

behaviorArray{numBArrays} = []; 
%dateArray = zeros(numBArrays, 1);
for i = 1:numBArrays
    load(B{i})
    behaviorArray{i} = saved_history;
    %
end 