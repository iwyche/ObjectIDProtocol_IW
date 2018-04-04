%% bDataWrapper - wraps behavioral data together

function [behaviorArray, dateArray] = bDataWrapper(behaviorDir)
fileBehavior = dir([behaviorDir filesep '*mat']);
B = {fileBehavior.name};
numBArrays = numel(B);

behaviorArray{numBArrays} = []; 
dateArray = zeros(numBArrays, 1);
for i = 1:numBArrays
    load(B{i})
    behaviorArray{i} = saved_history;
    date = (B{i}(38:41));
    dateArray(i) = str2num(date);
end 