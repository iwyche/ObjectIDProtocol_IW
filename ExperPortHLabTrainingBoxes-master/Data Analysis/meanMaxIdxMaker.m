%% Generate index of hit, miss, false alarm
%Type 1 = hit
%Type 2 = miss
%Type 3 = false alarm
%Type 4 = correct rejection
function [IDX] = meanMaxIdxMaker(Array, Type) 

if Type == 1
    %IDX = find(Array.meta.trialType == 1 && Array.meta.trialCorrect == 1);
    tType = Array.meta.trialType;
    tType(Array.meta.trialCorrect == 0) = 0;
    IDX = find(tType == 1);
elseif Type == 2
    %IDX = find(Array.meta.trialType == 1 && Array.meta.trialCorrect == 0);
    tType = Array.meta.trialType;
    tType(Array.meta.trialCorrect == 1) = 0;
    IDX = find(tType == 1);
elseif Type == 3 
    %IDX = find(Array.meta.trialType == 0 && Array.meta.trialCorrect == 0);
    tType = Array.meta.trialType;
    tType(Array.meta.trialCorrect == 1) = 1;
    IDX = find(tType == 0);
elseif Type == 4
    %IDX = find(Array.meta.trialType == 0 && Array.meta.trialCorrect == 1);
    tType = Array.meta.trialType;
    tType(Array.meta.trialCorrect == 0) = 1;
    IDX = find(tType == 0);
else 
    error('Invalid type')
end 


end 