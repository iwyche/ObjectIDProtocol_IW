%% meanMaxAmp- calculates mean and max amplitude of whiskers for each trial over a session
%Alternative: over all sessions
%Created 2015-05-11 by J. Sy

%% Section 1: Set variables
ARRAY = L5;
OUTPUT_FOLDER = 'D:\L5\MeanMaxAmp'; 
SESSION_NUMBER = 1; %Set to 0 to run all sessions

%% Section 2: Calculate mean and max of all trials within 1 session
if SESSION_NUMBER > 0;

desArray = ARRAY{SESSION_NUMBER};
numTrials = length(desArray.S_ctk(1,1,:)); 

memaList = zeros(numTrials, 2);

for i = 1:numTrials
    amplitude = desArray.S_ctk(3,:,i); 
    maxA = max(amplitude);
    memaList(i,2) = maxA;  
    numSec = length(amplitude);
    meanA = sum(amplitude)/numSec;
    memaList(i,1) = meanA;
end 

else
    disp('Switching to All Trial version')
end 

%% Section 3: All trials (WIP) - last edited 2015-05-11 by J. Sy
% if SESSION_NUMBER == 0;
% 
% desArray = ARRAY{SESSION_NUMBER};
% numTrials = length(desArray.S_ctk(1,1,:)); 
% 
% memaList = zeros(numTrials, 2);
% 
% for i = 1:numTrials
%     amplitude = desArray.S_ctk(3,:,i); 
%     maxA = max(amplitude);
%     memaList(i,2) = maxA;  
%     numSec = length(amplitude);
%     meanA = sum(amplitude)/numSec;
%     memaList(i,1) = meanA;
% end 
% 
% else
%     disp('Switching to one-trial version')
% end 

%% Section 4: Plot data
y = 1:numTrials;
xMean = memaList(:,1);
xMax = memaList(:,2);

figure(01)
hold on
scatter(xMean, y, 'k')
scatter(xMax, y, 'r')

hold off 