% process2AFCData: Returns 3xN matrix where N = number of sessions in the wrapped behavior array
%Row 1 lists the day starting from 1
%Row 2 lists the probability of a lick given 

function [lickData] = process2AFC(wrappedBehaviorArray, center) 
wBA = wrappedBehaviorArray;
numSessions = numel(wBA);

lickData = zeros(7,numSessions);
lickData(1,:) = 1:numSessions;

for i = 1:numSessions %Loop through each session and fill in data matrix with values
    numTrials = numel(wBA{i}.MotorsSection_motor_position);
    
    cut = 30; 
    
    %Preallocate lots of things
    tLeft = zeros(numTrials - cut,1);
    tLeftHit = zeros(numTrials - cut,1);
    tLeftWrong = zeros(numTrials - cut,1);
    tLeftMiss = zeros(numTrials - cut,1);
    tRight = zeros(numTrials - cut ,1); 
    tRightHit = zeros(numTrials - cut ,1);
    tRightWrong = zeros(numTrials - cut ,1);
    tRightMiss = zeros(numTrials - cut ,1);
    
    for j = (cut+1):numTrials
       motorPos = wBA{i}.MotorsSection_motor_position{j};
       
       if motorPos > center %check if left trial
         tLeft(j,1) = 1;
         
         postPct = str2num(wBA{i}.AnalysisSection_PctCorrect{j});
         prePct = str2num(wBA{i}.AnalysisSection_PctCorrect{j-1});
         dPct = postPct(1) - prePct(1);
         if dPct > 0 %Check if hit
             tLeftHit(j,1) = 1;
         elseif dPct < 0 %Check if wrong hit
             tLeftWrong(j,1) = 1;
         else
             tLeftHit(j,1) = 0;    
         end
         
         postPctM = str2num(wBA{i}.AnalysisSection_NumIgnores{j});
         prePctM = str2num(wBA{i}.AnalysisSection_NumIgnores{j-1});
         dPctM = postPctM(1) - prePctM(1);
         if dPctM > 0 %Check if no lick at all
             tLeftMiss(j,1) = 1;
         else
             tLeftMiss(j,1) = 0;
         end
         
       else
           tLeft(j,1) = 0;
       end 
       
       if motorPos < center %check if right trial
           tRight(j,1) = 1;
           
           postPct = str2num(wBA{i}.AnalysisSection_PctCorrect{j});
           prePct = str2num(wBA{i}.AnalysisSection_PctCorrect{j-1});
           dPct = postPct(2) - prePct(2);
           if dPct > 0 %Check if hit
               tRightHit(j,1) = 1;
           elseif dPct < 0
               tRightWrong(j,1) = 1; 
           else
               tRightHit(j,1) = 0;
           end
           
           postPctM = str2num(wBA{i}.AnalysisSection_NumIgnores{j});
           prePctM = str2num(wBA{i}.AnalysisSection_NumIgnores{j-1});
           dPctM = postPctM(2) - prePctM(2);
           if dPctM > 0 %Check if no lick at all
               tRightMiss(j,1) = 1;
           else
               tRightMiss(j,1) = 0;
           end
           
       else
           tRight(j,1) = 0;
       end
    end
    
    tLeftSum = sum(tLeft);
    tLeftHitSum = sum(tLeftHit);
    tLeftHitPct = tLeftHitSum/tLeftSum;
    lickData(2,i) = tLeftHitPct*100;
    tLeftWrongSum = sum(tLeftWrong);
    tLeftWrongPct = tLeftWrongSum/tLeftSum;
    lickData(4,i) = tLeftWrongPct*100;
    tLeftMissSum = sum(tLeftMiss);
    tLeftMissPct = tLeftMissSum/tLeftSum;
    lickData(6,i) = tLeftMissPct*100;
    
    tRightSum = sum(tRight); 
    tRightHitSum = sum(tRightHit);
    tRightHitPct = tRightHitSum/tRightSum;
    lickData(3,i) = tRightHitPct*100;
    tRightWrongSum = sum(tRightWrong);
    tRightWrongPct = tRightWrongSum/tRightSum;
    lickData(5,i) = tRightWrongPct*100;
    tRightMissSum = sum(tRightMiss);
    tRightMissPct = tRightMissSum/tRightSum;
    lickData(7,i) = tRightMissPct*100;
end 
       
