%% whiskerEngagementPlotter
%Created 2015-05-11 by J. Sy
%Calculates whisker engagement based amplitude of whisker
%Mean vs max amplitude for each trial

%Dependencies: 
% > meanMaxAmpFun.m
% > meanMaxIdxMaker.m
% > An actual dataset

%% Section 1: Set values
DATA = L5;
SESSION_NUMBER = 1; 

%% Section 2: Generate indexes of hit, miss, false alarm, correct rejection trials

bDat = DATA{SESSION_NUMBER}; 

hitIndex = meanMaxIdxMaker(bDat, 1);
missIndex = meanMaxIdxMaker(bDat, 2); 
falseAlarmIndex = meanMaxIdxMaker(bDat, 3);
correctRejectionIndex = meanMaxIdxMaker(bDat, 4);

%% Section 3: Calculate mean and max amplitudes for hits, misses, false alarms, and correct rejections

hitVals = meanMaxAmpFun(DATA, SESSION_NUMBER, hitIndex); 
missVals = meanMaxAmpFun(DATA, SESSION_NUMBER, missIndex);
falseAlarmVals = meanMaxAmpFun(DATA, SESSION_NUMBER, falseAlarmIndex);
correctRejectionVals = meanMaxAmpFun(DATA, SESSION_NUMBER, correctRejectionIndex);

%% Section 4: Unused 

%% Section 5: Plot Data
xHit = 1:length(hitVals(:,1));
yHitMean = hitVals(:, 1);
[Y1, I1] = sort(yHitMean)
imagesc(Y1)
hold on
plot(Y1*100, 'g') 
yHitMax = hitVals(:, 2);

xMiss = 1:length(missVals(:,1));
yMissMean = missVals(:, 1);
yMissMax = missVals(:, 2);

xFA = 1:length(falseAlarmVals(:,1));
yFAMean = falseAlarmVals(:, 1);
yFAMax = falseAlarmVals(:, 2);

xCR = 1:length(correctRejectionVals(:,1));
yCRMean = correctRejectionVals(:, 1);
yCRMax = correctRejectionVals(:, 2);


% figure(01)
% hold on
% scatter(xHit, yHitMean, 'k')
% scatter(xHit, yHitMax, 'r')
% hold off
% 
% figure(02)
% hold on
% scatter(xMiss, yMissMean, 'k')
% scatter(xMiss, yMissMax, 'r')
% hold off
% 
% figure(03)
% hold on
% scatter(xFA, yFAMean, 'k')
% scatter(xFA, yFAMax, 'r')
% hold off
% 
% figure(04)
% hold on
% scatter(xCR, yCRMean, 'k')
% scatter(xCR, yCRMax, 'r')
% hold off

% figure(05)
% hist(hitVals, 100)
% title('Hits')
% 
% figure(06)
% hist(missVals, 100)
% title('miss')
% 
% figure(07)
% hist(falseAlarmVals,100)
% title('FA')
% 
% figure(08)
% hist(correctRejectionVals, 100)
% title('CR')
