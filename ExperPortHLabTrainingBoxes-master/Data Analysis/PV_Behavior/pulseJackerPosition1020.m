function [pulseOutput] = pulseJackerPosition1020(xsgDirname)
cd(xsgDirname)

fileList = dir([xsgDirname '\*xsg']);
nameList = {fileList.name};
listSize = (numel(nameList)); 

pulseOutput = zeros((listSize),1);

for i = 1:listSize
    readXSG = load(nameList{i},'-mat'); 
    readPulseJacker = readXSG.header.pulseJacker.pulseJacker.currentPosition;
    pulseOutput(i) = (readPulseJacker); 
end 

pulseOutput(:,2) = 1:listSize;

pulseOutput(:,3) = zeros(listSize,1);

for j = 1:listSize
     if pulseOutput(j,1) == 5 || pulseOutput(j,1) == 13 
        %if pulseOutput(j,1) == 2 
        pulseOutput(j,3) = 1;
    else 
        pulseOutput(j,3) = 0;
    end
end 