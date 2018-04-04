%% The non-stim alternative to lickProbabilityCurveStim

function [lickCount, trialCount] = grandMeanNoStimCalcNP(dataInput, stimDirname, bins, onFilter, offFilter)

%stimInfo = pulseJackerPosition(stimDirname); %Calls pulseJackerPosition function to obtain info about which trials we stimulated on
stimInfo = noPulsePosition(dataInput);
stimIndex = find(~stimInfo(onFilter:offFilter,3)); %Indices of trials with a stimulation
sizeStimInfo = numel(stimIndex); 
        
        motorPositionDat = cell2mat(dataInput.MotorsSection_motor_position);
        motorPositionDat = motorPositionDat(onFilter:offFilter);
        if numel(motorPositionDat) ~= length(stimInfo(onFilter:offFilter,3)) %Throw out an error if the trial numbers don't match due to possibility of all trials being off 
            error('number of trials must be the same for motor position and pulse jacker data') 
        end 
        motorPositionDat = motorPositionDat(stimIndex); %Takes only the motor positions of the trials with a stimulation
        totalTrials = sizeStimInfo;
        
        lickingArray = lickArrayMaker(dataInput); %Uses lickArrayMaker code I wrote to make a matrix of whether a lick occurs
        lickingArray = lickingArray(onFilter:offFilter); 
        lickingArray= lickingArray(stimIndex); % Same as above
        
        motorPosBins = (180000/bins):(180000/bins):180000; %Makes bins
        
        lickCount = zeros(1,bins);
        trialCount = zeros(1,bins); 
        for motorPosIndex = 1:bins; %Loop command for each bin
            motorRangeStart = motorPosIndex*(100000/bins)-(100000/bins)+50000; 
            motorRangeEnd = motorPosIndex*(100000/bins)+50000;
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
            lickCount(motorPosIndex) = licksInRange;
            trialCount(motorPosIndex) = trialsInRange; 
        end

        
        %scatter(motorPosBins,lickPercent) % Crude scatterplot, note that axes will not quite be accurate, since they'll be listed by the last value in the range, not the range itself)
end