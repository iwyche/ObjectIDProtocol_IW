%Creates easier user interface curves

mouseResp = input('Please type the name of your mouse ', 's');
dataFolder = 'C:\Users\shires\Documents\GitHub\BControl_Primary\SoloData\Data';
cd([dataFolder filesep mouseResp]);  

typeResp = input('Type 1 for 2AFC or 2 for Go-NoGo ');
if typeResp == 1
    lickProbability2AFC
elseif typeResp == 2
    allTrialLickAccuracy
else
    error('Invalid input')
end
