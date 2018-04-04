% lickProbWTouch -Created 2015-04-21 by J. Sy
% Returns a 6x2 matrix with the first column detailing categories of 
% numbers of touches and the second column the actual probabilites
function [Probabilities] = lickProbWTouch(arrayName,trialType)

%First, depending on whether this is set for go or no-go trials, we find indices of just the type of trials we want
%Note: I've included an option for doing all trials, in case we want that
%option later 
trialTypeList = arrayName.meta.trialType;
if trialType == 1
    includeTrials = find(trialTypeList);
elseif trialType == 0
    includeTrials = find(~trialTypeList);
elseif trialType == 3
    includeTrials = 1:length(trialTypeList); 
else
    error('trialType must be either a go trial ("1") or no-go trial ("0")') 
    % Note that the error message does not specify the existance of option 3
end 

numTrials = numel(trialTypeList);  

trialInfo = zeros(numTrials, 7); 
%First column is trial number, following six correspond to the 6 bin categories
%dictated in the Probabilites section at the end of this function
trialInfo(:,1) = 1:numTrials; 

for i = 1:numTrials %For loop divided into 4 steps
    
    %Step 1: Find indices of all touches within a trial (which are also the times)
    firstTouchArray = find(arrayName.S_ctk(9,:,i)>0);
    lateTouchArray = find(arrayName.S_ctk(12,:,i)>0);
    touchArray = [firstTouchArray, lateTouchArray]; 
    
    %Step 2: Find the times at which the pole was present to the mouse
    poleUpTime = find(arrayName.S_ctk(15,:,i)>0, 1);
    poleDownTime = find(arrayName.S_ctk(15,:,i)>0, 1, 'last'); 
    
    %Step 3: Find the first time the mouse licked within the above range (or if it licked at all) 
    lickTimes = find(arrayName.S_ctk(16,:,i)>0);
    if isempty(lickTimes) == 1
        lickExist = 0;
    else
        lickIndex = find(lickTimes > poleUpTime & lickTimes < poleDownTime, 1);
            %Note that this only finds the first lick satisfying the conditions
        if isempty(lickIndex) == 1
            lickExist = 0;
        else
            firstLickTime = lickTimes(lickIndex);
            lickExist = 1; 
        end 
    end 
    
    %Step 4: Edit touch array to only include touches before the first lick
    if lickExist == 0
        touchArray = touchArray(touchArray > poleUpTime & touchArray < poleDownTime); 
        numTouches = numel(touchArray);
        if numTouches < 5;
            trialInfoColumn = numTouches + 2; 
        else 
            trialInfoColumn = 7;
        end 
        trialInfo(i,trialInfoColumn) = 1; 
    else 
        touchArray = touchArray(touchArray > poleUpTime & touchArray < firstLickTime); 
        numTouches = numel(touchArray);
        if numTouches < 5;
            trialInfoColumn = numTouches + 2; 
        else 
            trialInfoColumn = 7;
        end 
        trialInfo(i,trialInfoColumn) = 2;
    end 
end 

trialInfo = trialInfo(includeTrials,:); %Here is where we exclude either go trials or no-go trials


lickTrialNum = trialInfo(:,2:7);
lickTrialNum(lickTrialNum == 1) = 0;
lickTrialSum = sum(lickTrialNum);
lickTrialSum = lickTrialSum/2;

allTrialNum = trialInfo(:,2:7);
allTrialNum(allTrialNum > 0) = 1;  
allTrialSum = sum(allTrialNum);

trialProb = lickTrialSum./allTrialSum;

Probabilities = zeros(6,2); 
Probabilities(:,1) = 0:5;
Probabilities(:,2) = trialProb; 
end 


        