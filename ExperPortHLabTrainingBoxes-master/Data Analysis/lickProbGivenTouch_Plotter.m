%% Calculates probability of lick given touch of a given cell and plots the data
%Created 2015-04-21 by J. Sy
%Added commented out bits to loop it 2015-04-25 by J. Sy 

%% Section 1: Specify layer, cell name, number
ARRAY_NAME = 'L';
%for i = 4:37
plotName = 1; %change to i to run in loop
CELL_NUMBER = num2str(plotName);
TRIAL_TYPE = 1; 
PATH = 'D:\L4';
% TRIAL_TYPE = 1 calculates go trials only
% TRIAL_TYPE = 0 calculates no-go trials only
% TRIAL_TYPE = 3 calculates all trials together
% TRIAL_TYPE = 4 calculates go and no-go trials separately %Future
% implementation

%% Section 2: Run lickProbWTouch to return probabilities
s{1} = ARRAY_NAME;
s{2} = '{';
s{3} = CELL_NUMBER;
s{4} = '}';
arrayName = eval(strcat(s{1},s{2},s{3},s{4}));
[P] = lickProbWTouch(arrayName, TRIAL_TYPE);
xGo = P(:,1);
yGo = P(:,2);

%% Section 3: Re-run (for no-go if overlay desired)
TRIAL_TYPE = 0;
[P] = lickProbWTouch(arrayName, TRIAL_TYPE);
xNoGo = P(:,1);
yNoGo = P(:,2);
%% Plotting Section
clf
figure(01)
hold on
set(gca, 'xlim', [0 5])
set(gca, 'ylim', [-0.001 1.001])
xbounds = xlim;
set(gca,'XTick',xbounds(1):xbounds(2));

scatter(xGo,yGo, 'b') 
plot(xGo,yGo, 'b')

scatter(xNoGo,yNoGo, 'r') 
plot(xNoGo,yNoGo, 'r')
hold off 
legend('Go Trials', '', 'No-Go Trials','')

path = PATH;
filename = [ARRAY_NAME '_' CELL_NUMBER];
print(gcf,'-depsc', [path filesep filename]) 
%end 