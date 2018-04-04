%% noPulsePosition- use if the pulse Jacker positions are known but the .xsg files cannot be found
%Created 2015-03-31 by J. Sy
%Please use the BControl data for this 
function [pulseOutput] = noPulsePosition(dataInput)
listSize = numel(dataInput.MotorsSection_motor_position);

stim1 = 2;
stim2 = 5;
stim3 = 11;
stim4 = 13;
stim5 = 16;

nPJ = (1:20);
pL = repmat(nPJ,1,15);
pulseOutput(1,1) = 0;
pulseOutput((2:299),1) = pL(1:298);  
pulseOutput(:,2) = 1:listSize;

pulseOutput(:,3) = zeros(listSize,1);

for j = 1:listSize
    if pulseOutput(j,1) == stim1 || pulseOutput(j,1) == stim2 || pulseOutput(j,1) == stim3 || pulseOutput(j,1) == stim4 || pulseOutput(j,1) == stim5
        pulseOutput(j,3) = 1;
    else 
        pulseOutput(j,3) = 0;
    end
end 