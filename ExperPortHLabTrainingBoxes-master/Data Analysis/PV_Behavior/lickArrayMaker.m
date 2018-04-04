%% Creates array showing whether or not the mouse in question licked during a trial 
% Created by J. Sy on 2014-12-4
% Use on array with mouse data

function [lickArray, trialCount] = lickArrayMaker(x)
trialCount = numel(x.AnalysisSection_FAR); % Helpfully includes the overall number of trials for your convenience 
lickArray = zeros(trialCount,1);  
for i = 1:trialCount 
    if x.AnalysisSection_NumTrials{i} == 1 % Discounts the first trial since it's autoscored as a hit and difficult to code in accurately
        lickArray(i) = 0;
    elseif x.AnalysisSection_HR{i} > x.AnalysisSection_HR{i-1} % Compares hit ratio at end of current trial to the end of the previous trial. An increase implies a lick
        lickArray(i) = 1;
    elseif x.AnalysisSection_FAR{i} > x.AnalysisSection_FAR{i-1} % Same as above, an increase still implies a lick
        lickArray(i) = 1;
    else lickArray(i) = 0; % No increase in HR or FAR implies no lick 
    end 
end 
