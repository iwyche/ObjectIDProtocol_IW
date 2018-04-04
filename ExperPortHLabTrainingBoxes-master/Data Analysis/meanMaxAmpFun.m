%% meanMaxAmpFun- calculates mean and max amplitude of whiskers for each trial over a session (function version)
%Alternative: over all sessions
%Created 2015-05-11 by J. Sy

function [meanMaxVals] = meanMaxAmpFun(ARRAY, SESSION_NUMBER, INDEX)  

array = ARRAY;
idx = INDEX; 


desArray = array{SESSION_NUMBER};
numTrials = length(desArray.S_ctk(1,1,:)); 

meanList = zeros(numTrials, 1);
maxList = zeros(numTrials, 1);

for i = 1:numTrials
    amplitude = desArray.S_ctk(3,:,i); 
    maxA = max(amplitude);
    maxList(i) = maxA;  
    numSec = length(amplitude);
    meanA = sum(amplitude)/numSec;
    meanList(i) = meanA;
end 

meanList = meanList(idx);
maxList = maxList(idx);

meanMaxVals(:, 1) = meanList; 
meanMaxVals(:, 2) = maxList; 

end 

