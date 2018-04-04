%% lickProbability2AFC - creates plot of a mouse's accuracy, either for one day or over time
%Created 2015-04-28 by J. Sy

%% Section 1: Specify variables

WRAP_DATA = 1; %Set to 1 if data not wrapped, set to 0 if already wrapped
MOUSE_NAME = mouseResp;
DATA_FOLDER = pwd; %Make sure this folder contains no other .mat files than the ones you want to wrap
CENTER_POSITION = 60000;

%% Section 2: Wrap data (only use if not already wrapped)

cd(DATA_FOLDER)
[bArray, dateArray] = bDataWrapper(DATA_FOLDER); 

%% Section 3: Process 2AFC Data

center = CENTER_POSITION;
lickData = process2AFC(bArray, center); 

%% Section 4: Plot 2AFC Data

xLeft = dateArray;
xRight = dateArray;  
yLeftHit = lickData(2,:);
yRightHit = lickData(3,:);
yLeftWrong = lickData(4,:);
yRightWrong = lickData(5,:);
yLeftMiss = lickData(6,:);
yRightMiss = lickData(7,:);

figure(01)
hold on
title('Left Port')
xlabel('Date')
ylabel('Percent of all trials')

set(gca, 'ylim', [-0.001 100.001])


plot(xLeft, yLeftHit, 'g')
scatter(xLeft, yLeftHit, 'g')
plot(xLeft, yLeftWrong, 'r')
scatter(xLeft, yLeftWrong, 'r')
plot(xLeft, yLeftMiss, 'k')
scatter(xLeft, yLeftMiss, 'k')
legend('Correct', '','Wrong','','Miss','')
hold off 

figure(02)
hold on
title('Right Port')
xlabel('Date')
ylabel('Percent of all trials')

set(gca, 'ylim', [-0.001 100.001])

plot(xRight, yRightHit, 'g')
scatter(xRight, yRightHit, 'g')
plot(xRight, yRightWrong, 'r')
scatter(xRight, yRightWrong, 'r')
plot(xRight, yRightMiss, 'k')
scatter(xRight, yRightMiss, 'k') 
legend('Correct','','Wrong','','Miss','')

hold off 