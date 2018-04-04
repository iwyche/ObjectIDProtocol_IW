% Creates plot of lick probability vs. pole position using mouse whisking data
% Altered for stim trials and non stim trial difference
% Created 2014-12-4 by J. Sy
% Version 02, should be a bit nicer to use,
% Future additions: input options for array name, bin size (currently
% hard-coded for 18 bins)

%% Part 1: Analyze trials with stimulation

function [lickPercent] = lPCS_multiPower(dataInput, stimDirname, bins)

onFilter = 50; %Sets trial number to start at
offFilter = 300; %Sets trial number to end at

stimInfo = pulseJackerPosition1020(stimDirname); %Calls pulseJackerPosition function to obtain info about which trials we stimulated on
%stimInfo = noPulsePosition(dataInput);
stimIndex = find(stimInfo(onFilter:offFilter,3)); %Indices of trials with a stimulation
sizeStimInfo = numel(stimIndex); 
        
        motorPositionDat = cell2mat(dataInput.MotorsSection_motor_position);
        motorPositionDat = motorPositionDat(onFilter:offFilter);
        if numel(motorPositionDat) ~= length(stimInfo(:,3)) %Throw out an error if the trial numbers don't match due to possibility of all trials being off 
            error('number of trials must be the same for motor position and pulse jacker data') 
        end 
        motorPositionDat = motorPositionDat(stimIndex); %Takes only the motor positions of the trials with a stimulation
        
        totalTrials = sizeStimInfo;
        
        lickingArray = lickArrayMaker(dataInput); %Uses lickArrayMaker code I wrote to make a matrix of whether a lick occurs
        lickingArray= lickingArray(stimIndex); % Same as above
        
        motorPosBins = (180000/bins):(180000/bins):180000; %Makes bins
        
        lickProb = zeros(1,bins);
        for motorPosIndex = 1:bins; %Loop command for each bin
            motorRangeStart = motorPosIndex*(180000/bins)-(180000/bins); % Subtract 10,000 so as to start at 0 and go by increments of 10,000
            motorRangeEnd = motorPosIndex*(180000/bins);
            trialsInRangeArray = (motorPositionDat >= motorRangeStart & motorPositionDat < motorRangeEnd);
            trialsInRange = sum(trialsInRangeArray);
            
            
            licksInRangeArray = zeros(1,totalTrials);
            for lickIndex = 1:totalTrials; %Loop command for all trials, forms array with all licks that occur within specified range
                if (lickingArray(lickIndex) == 1) && (motorPositionDat(lickIndex) >= motorRangeStart) && (motorPositionDat(lickIndex) < motorRangeEnd)
                    licksInRangeArray(lickIndex) = 1;
                else licksInRangeArray(lickIndex) = 0;
                end
            end
            licksInRange = sum(licksInRangeArray);
            
            lickProb(motorPosIndex) = licksInRange/trialsInRange;
        end
        
        lickPercent = 100*lickProb;
        
        
        %scatter(motorPosBins,lickPercent) % Crude scatterplot, note that axes will not quite be accurate, since they'll be listed by the last value in the range, not the range itself)
        %xlim([0.6 1.8])
        %ylim([0 100])
        
end

