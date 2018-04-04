animal = '036';
unit = '5554';
exp = '001';

% set animal name after 'A'
judp('SEND', 7000, '68.181.112.192', [int8(['A', animal]) 10]); 
% set unit number after 'U' (5555 for upper spontaneous, 5554 for
% lower layer spontaneous)
judp('SEND', 7000, '68.181.112.192', [int8(['U', unit]) 10]); 
% set experiment number after 'E'
% 0xx for before, 1xx for after exp
% x0x for anesthetized, x1x for awake
% x10 for before session, x11 for after session
judp('SEND', 7000, '68.181.112.192', [int8(['E', exp]) 10]); 
% pressing 'grab' button (recording)
judp('SEND', 7000, '68.181.112.192', [int8('G') 10]); 
judp('SEND', 6610, '68.181.114.170', [int8('Action0101[create new sequence and start recording()]:'), int8([animal, '_', unit, '_', exp])])
pause(3) % wait first 3 sec for warming up 
for i = 1 : 10
    pause(30) % wait 30 sec
    judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); % turn off the laser
    pause(30) % wait 30 sec
    judp('SEND', 7000, '68.181.112.192', [int8('L1') 10]); % re-open the laser
end

% stop recording
judp('SEND', 7000, '68.181.112.192', [int8('S') 10]); 
judp('SEND', 6610, '68.181.114.170', [int8('Action0101[Stop Record()]:'), int8([animal, '_', unit, '_', exp])])