%processGoNogo: returns matrix filled running percent correct values
%Assess PercentCorrect, HR, and FAR over all trials and sessions 

function [runningPercent] = processAllTrials2AFC(wrappedBehaviorArray)
wBA = wrappedBehaviorArray;
numSessions = numel(wBA);

trialMatrix = zeros(numSessions, 1);
for i = 1:numSessions
    sessionTrials = numel(wBA{i}.MotorsSection_motor_position);
    trialMatrix(i, 1) = sessionTrials;
end 
totalTrials = sum(trialMatrix);

totalPercentMat = zeros(4, totalTrials);
brkList = zeros(1, totalTrials); 
for j = 1:numSessions
    if j >1
    %    increment = sum(trialMatrix(0:(j-1),1));
       increment = sum(trialMatrix(1:(j-1),1));
    else
        increment = 1;
    end 
    currentTrials = trialMatrix(j,1);
    
    if isfield(wBA{j},'AnalysisSection_PercentCorrect')
    tempCell = wBA{j}.AnalysisSection_PercentCorrect;
    else
    tempCell = wBA{j}.AnalysisSection_PctCorrect;
    end
    tempStr = cell2mat(tempCell);
    tempMat = str2num(tempStr);
    
    percentLeft = tempMat(:,1);
    percentRight = tempMat(:,2);
    percentTotal = tempMat(:,3);
    
    missPercent = zeros(1, currentTrials);
    for k = 1:currentTrials %Calculate miss percentages
        missStr = wBA{j}.AnalysisSection_NumIgnores{k};
        if numel(missStr) == 16
        missNumPct = str2num(missStr(13:16))/k*100;    
        else  
        missNums = cell2num(missStr);
        missNumPct = missNums(1,3)/k*100;
        end
        
        missPercent(1, k) = missNumPct;
    end 
    
    breakPoint = increment + currentTrials -1;
    brkList(1, breakPoint) = 1;  
    
    totalPercentMat(1, increment:breakPoint) = percentLeft;
    totalPercentMat(2, increment:breakPoint) = percentRight;
    totalPercentMat(3, increment:breakPoint) = percentTotal;  
    totalPercentMat(4, increment:breakPoint) = missPercent;
end 

runningPercent.percentages = totalPercentMat;
%runningPercent.instant50   = instant50;
runningPercent.sessionBreaks = brkList; 


        
