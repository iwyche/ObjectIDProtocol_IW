%% Grand Mean: Code to find the grand mean of licking and stimulation data
%Created 2015-04-08 by J. Sy
%clear

%% Section 1: Set the data locations to process, make sure the behavior data is the same folder as the .xsg files

MOUSE_NAME = 'AH0097'
DATA_DIRECTORY = 'D:\StimData'; 
FOLDER_LIST = {'128'}; %'113' '124' '125' '128' '130'};
FOLDER_PREFIX = 'JS0'; %The idea here is that you have some common prefix before all the numbers
%If you have different prefixes, you just have to make a matrix with all
%relevant directories as strings. Sorry about that. 
BINS = 20;
EPS_PATH = 'C:\Users\shires\Documents\BehaviorData\Stim_vs_NoStim_GrandMean';
DATE = 'All_20mW_AltAltAlt';

cd(DATA_DIRECTORY);

folderList = FOLDER_LIST;
folderList = strcat(FOLDER_PREFIX,folderList); 
bins = BINS;
mouseN = MOUSE_NAME;

%% Section 2: Find grand mean of stim data

numFolders = numel(folderList);

lickCountStim = zeros(numFolders, bins);
trialCountStim = zeros(numFolders, bins);

for i = 1:numFolders
    
    actFolder = folderList{i};
    actDir = [DATA_DIRECTORY filesep actFolder];
    
    fileBehavior = dir([actDir '\*mat']);
    behaviorName = {fileBehavior.name};
    behaviorName = char(behaviorName);
    
    if strcmpi([DATA_DIRECTORY filesep 'JS0113'],actDir) == 1; %Friday the 13th filter
    numTrials = (270);
    onFilter = 02;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalcNP(saved_history, actDir, bins, onFilter, offFilter);  
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0130'],actDir) == 1; %April 9th filter
    numTrials = (207);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0128'],actDir) == 1; 
    numTrials = (255);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0124'],actDir) == 1; 
    numTrials = (300);
    onFilter = 50;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0125'],actDir) == 1; 
    numTrials = (293);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
%     elseif strcmpi('D:\StimData\JS0117',actDir) == 1; 
%     numTrials = (488);
%     onFilter = 2;
%     offFilter = numTrials;
%     
%     cd(actDir)
%   
%     load(behaviorName);
%     
%     [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
%     
%     elseif strcmpi('D:\StimData\JS0115',actDir) == 1; 
%     numTrials = (516);
%     onFilter = 2;
%     offFilter = numTrials;
%     
%     cd(actDir)
%   
%     load(behaviorName);
%     
%     [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter);
%     
    else
    fileXSG = dir([actDir '\*xsg']); 
    numTrials = numel(fileXSG);
    numTrials = (numTrials - 10);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountStim(i,:), trialCountStim(i,:)] = grandMeanStimCalc(saved_history, actDir, bins, onFilter, offFilter); 
    end 
end 

lickTotalStim = sum(lickCountStim);
trialTotalStim = sum(trialCountStim);
yStim = lickTotalStim./trialTotalStim; 
yStim = yStim*100;

%% Section 3: Find grand mean of non-stim trials

lickCountNoStim = zeros(numFolders,bins);
trialCountNoStim = zeros(numFolders, bins);

for i = 1:numFolders
    
    actFolder = folderList{i};
    actDir = [DATA_DIRECTORY filesep actFolder];
    fileBehavior = dir([actDir '\*mat']);
    behaviorName = {fileBehavior.name};
    behaviorName = char(behaviorName);
    
    if strcmpi([DATA_DIRECTORY filesep 'JS0113'],actDir) == 1;
    numTrials = (299);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalcNP(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0137'],actDir) == 1; %April 9th filter
    numTrials = (60);
    onFilter = 300;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0128'],actDir) == 1; 
    numTrials = (255);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0124'],actDir) == 1; 
    numTrials = (300);
    onFilter = 50;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
    elseif strcmpi([DATA_DIRECTORY filesep 'JS0125'],actDir) == 1; 
    numTrials = (293);
    onFilter = 2;
    offFilter = numTrials;
    
    cd(actDir)
  
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
    
%     elseif strcmpi('D:\StimData\JS0117',actDir) == 1; 
%     numTrials = (488);
%     onFilter = 2;
%     offFilter = numTrials;
%     
%     cd(actDir)
%   
%     load(behaviorName);
%     
%     [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
%     
%     elseif strcmpi('D:\StimData\JS0115',actDir) == 1; 
%     numTrials = (516);
%     onFilter = 2;
%     offFilter = numTrials;
%     
%     cd(actDir)
%   
%     load(behaviorName);
%     
%     [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter);
%     
%     
    else
    fileXSG = dir([actDir '\*xsg']); 
    numTrials = numel(fileXSG);
    numTrials = (numTrials - 10);
    onFilter = 2;
    offFilter = numTrials; 
  
    cd(actDir)
    
    load(behaviorName);
    
    [lickCountNoStim(i,:), trialCountNoStim(i,:)] = grandMeanNoStimCalc(saved_history, actDir, bins, onFilter, offFilter); 
    end 
end 

lickTotalNoStim = sum(lickCountNoStim);
trialTotalNoStim = sum(trialCountNoStim);
yNoStim = lickTotalNoStim./trialTotalNoStim; 
yNoStim = yNoStim*100;

%% Section 4: Plot grand mean

motorPosBins = 55000:(100000/bins):150000;
xAll = (motorPosBins);

figure(01) %Plot Stim vs Non-Stim
h1 = axes;
set(gca, 'xdir', 'reverse')
set(gca, 'ydir', 'normal')
set(gca, 'xlim', [50000 150000])
set(gca, 'ylim', [0 100])


hold on
s1 = scatter(xAll, yStim, 40, 'r', 'o');
s2 = scatter(xAll, yNoStim, 40, 'k', '*');
%axis([60000 180000 0 110])
legend('Stim Trials', 'Non-stim Trials')
hold off

%% Section 5: Print plots to EPS files

path = EPS_PATH;
filename = [mouseN '_' DATE];
print(gcf,'-depsc', [path filesep filename]) 

%clear %Clear the horrific amounts of clutter that probably popped up in the workspace by now
