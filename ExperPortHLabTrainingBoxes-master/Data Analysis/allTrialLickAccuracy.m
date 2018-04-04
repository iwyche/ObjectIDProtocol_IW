%% allTrialLickAccuracy- plot running count of mouse lick accuracy per trial as well as whether trial was correct or incorrect
%Created 2015-08-24 by J. Sy
%WORKS ON GO/NO-GO SESSIONS ONLY!

%% Section One: Specify variables

WRAP_DATA = 1; %Set to 1 if data not wrapped, set to 0 if already wrapped
MOUSE_NAME = mouseResp;
DATA_FOLDER = pwd; %Make sure this folder contains no other .mat files than the ones you want to wrap

%% Section 2: Wrap data (only use if not already wrapped)

cd(DATA_FOLDER)
[bArray] = bDataWrapper_v2(DATA_FOLDER);

%% Section 3: Process Data

[runningPercent] = processGoNogo(bArray);  
sessionBreaks = find(runningPercent.sessionBreaks == 1);

%% Section 4: Plot Data

Correct= runningPercent.percentages(1,:)*100;
HR = runningPercent.percentages(2,:)*100;
FAR = runningPercent.percentages(3,:)*100;

sBreak = runningPercent.sessionBreaks;
numTrials = numel(Correct);
trialPlot = 1:numTrials;


plot(trialPlot, Correct, 'g') 
hold on
plot(trialPlot, HR, 'b')
plot(trialPlot, FAR, 'm')


%scatter(sessionBreaks, 100, '*','k') 
legend('Percent Correct', 'Hit Rate', 'False Alarm Rate')
xlabel('Trials')
ylabel('Percent')
hold off