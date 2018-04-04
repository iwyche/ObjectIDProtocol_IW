%% lickProbabilityPlotter- returns three figures corresponding to trials both in total, with and without stimulation
%Created 2015-03-31 by J Sy. 
%Alternatively, returns EPS files corresponding to stim vs no stim
%-2015-04-07 edit

%% SECTION 1: Set values for plots

BINS = 20; %Set desired bin size
STIM_DIRECTORY = 'D:\StimData\JS0128'; % Set directory containing .xsg files
BEHAVIOR_LOCATION = saved_history; % Specify locatison of BControl behavior Data
TRIAL_RANGE = [2:255]; %Specify which trials to use 
MOUSE_NAME = 'AH0097';
DATE = '2015_04_09_Alt'; %Set date at which recordins are taken
PATH = 'C:\Users\shires\Documents\BehaviorData\Stim_vs_NoStim\AH0097';

bins = BINS; 
stimDir = STIM_DIRECTORY;
datLocal = BEHAVIOR_LOCATION;
onFilter = min(TRIAL_RANGE);
offFilter = max(TRIAL_RANGE);
mouseN = MOUSE_NAME;

%% SECTION 2A: Run multiple functions to generate curve data

%prettyPlots

motorPosBins = 55000:(100000/bins):150000;
xAll = (motorPosBins);

%yTotal = lickProbabilityCurve_valOnly(datLocal, bins, onFilter, offFilter);
yStim = lickProbabilityCurveStim_valOnly(datLocal, stimDir, bins, onFilter, offFilter);
yNoStim = lickProbabilityCurveNoStim_valOnly(datLocal, stimDir, bins, onFilter, offFilter); 

%% SECTION 2B: Alternate version of above for multiple power levels
% bins = BINS; 
% stimDir = STIM_DIRECTORY;
% datLocal = BEHAVIOR_LOCATION;
% 
% motorPosBins = (150000/bins):(150000/bins):150000;
% xAll = motorPosBins;
% 
% yTotal = lickProbabilityCurve_valOnly(datLocal, bins);
% yStim = lPCS_multiPower(datLocal, stimDir, bins);
% yNoStim = lickProbabilityCurveNoStim_valOnly(datLocal, stimDir, bins); 

%% SECTION 3: Plot figures, comment 
% % Comment this out to use SECTION 4 below.
% % clf
% % 
% % figure(01) %Plot all data
% % s1 = scatter(xAll, yTotal, 40, 'b', 'o');
% % axis([5000 180000 0 100])
% % set(s1,'DisplayName','All Trials')
% 
% % figure(02) %Plot trials with stimulation only
% % s2 = scatter(xAll, yStim, 40, 'r', 'o');
% % axis([5000 180000 0 100])
% 
% % figure(03) %Plot trials without stimulation only
% % s3 = scatter(xAll, yNoStim, 40, 'k', 'o');
% % axis([5000 180000 0 100])
% =============The Useful Bit===============================
figure(01) %Plot Stim vs Non-Stim
figure(01) %Plot Stim vs Non-Stim
h1 = axes;
set(gca, 'xdir', 'reverse')
set(gca, 'ydir', 'normal')
set(gca, 'xlim', [50000 155000])
set(gca, 'ylim', [0 105])


hold on
s1 = scatter(xAll, yStim, 40, 'r', 'o');
s2 = scatter(xAll, yNoStim, 40, 'k', '*');
%axis([60000 180000 0 110])
legend('Stim Trials', 'Non-stim Trials')
hold off
% ===========================================================
% %Uncomment to use current date
% % formatOut = 'yyyy_mm_dd';
% % date = datestr(now,formatOut);

%% SECTION 4: Alternate plotting method to compare the first 100 trials to the entirety of the session
%Please comment out SECTION 3 before using this and vis versa 

% TRIAL_RANGE = [2:102];
% onFilter = min(TRIAL_RANGE);
% offFilter = max(TRIAL_RANGE);
% 
% yStim100 = lickProbabilityCurveStim_valOnly(datLocal, stimDir, bins, onFilter, offFilter);
% 
% figure(04) %Plot Stim vs Non-Stim
% s2 = scatter(xAll, yStim, 40, 'r', 'o');
% axis([5000 180000 0 110])
% hold on
% s3 = scatter(xAll, yStim100, 40, 'b', '*');
% axis([5000 180000 0 110])
% legend('All Stim Trials', 'First 100 Stim Trials')

%% SECTION 5: Print EPS files to path specified in SECTION 1. 

path = PATH;
filename = [mouseN '_' DATE];
print(gcf,'-depsc', [path filesep filename]) 
