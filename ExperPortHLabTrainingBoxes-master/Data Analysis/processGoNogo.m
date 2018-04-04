%processGoNogo: returns matrix filled running percent correct values
%Assess PercentCorrect, HR, and FAR over all trials and sessions 

function [runningPercent] = processGoNogo(wrappedBehaviorArray)
wBA = wrappedBehaviorArray;
numSessions = numel(wBA);

trialMatrix = zeros(numSessions, 1);
for i = 1:numSessions
    sessionTrials = numel(wBA{i}.MotorsSection_motor_position);
    trialMatrix(i, 1) = sessionTrials;
end 
totalTrials = sum(trialMatrix);

totalPercentMat = zeros(3, totalTrials);
brkList = zeros(1, totalTrials); 
for j = 1:numSessions
    if j >1
        increment = sum(trialMatrix(1:(j-1),1));
    else
        increment = 1;
    end 
    currentTrials = trialMatrix(j,1);
    
    tempCellPC = wBA{j}.AnalysisSection_PercentCorrect(:);
    tempCellHR = wBA{j}.AnalysisSection_HR(:);
    tempCellFAR = wBA{j}.AnalysisSection_FAR(:);
    
    percentMatPC = cell2mat(tempCellPC);
    percentMatHR = cell2mat(tempCellHR);
    percentMatFAR = cell2mat(tempCellFAR);
    
    breakPoint = increment + currentTrials -1;
    brkList(1, breakPoint) = 1;  
    
    totalPercentMat(1, increment:breakPoint) = percentMatPC;
    totalPercentMat(2, increment:breakPoint) = percentMatHR;
    totalPercentMat(3, increment:breakPoint) = percentMatFAR;  
end 

runningPercent.percentages = totalPercentMat;
runningPercent.sessionBreaks = brkList; 


        
