% [] = state35(obj)    Method that gets called at the end of every trial
%
% This method assumes that it has been given read/write access to a SPH
% called n_done_trials (which will be updated by one upon entry to
% state35.m), and read-only access to a SPH called
% trial_finished_actions. This last should be a cell vector of strings,
% each of which will be eval'd in sequence (type "help eval" at the
% Matlab prompt if you don't know what that means).
%
% If you put everything into trial_finished_actions, the code for this
% method should be universal for all protocols, and there should be no
% need for you to modify this file.
%

% CDB Feb 06


function [] = state35(obj)

GetSoloFunctionArgs;

if strcmp(SessionType, '2port-Discrim')
    judp('SEND', 6610, '68.181.114.170', [int8('Action0101[Stop Record()]:'), int8(num2str(double(n_done_trials)+1))])
    
    if strcmp(TPM_imaging, 'Block')
        block_length = 10;
        if floor((n_done_trials)/block_length) > floor((n_done_trials - 1)/block_length)
            judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
            if mod(floor((n_done_trials)/block_length),2) 
                judp('SEND', 7000, '68.181.112.192', [int8('Mobjective_set_2') 10]); 
                judp('SEND', 7000, '68.181.112.192', [int8('Rb') 10]); 
                judp('SEND', 7000, '68.181.112.192', [int8('IB') 10]); 
            else
                judp('SEND', 7000, '68.181.112.192', [int8('Mobjective_set_1') 10]); 
                judp('SEND', 7000, '68.181.112.192', [int8('Ra') 10]); 
                judp('SEND', 7000, '68.181.112.192', [int8('IA') 10]); 
            end
            judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
            pause(1); % wait for 1 sec when the objective has moved
        else
            judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
            pause(1); % laser blanking, and pausing for extra 1 sec
        end        
    else
        judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
        pause(1); % laser blanking, and pausing for extra 1 sec
    end        
elseif strcmp(SessionType, 'Piezo stimulation') 
    pause(5); % 5 sec after-stimulation imaging (5 sec baseline, 2 sec stimulation, 5 sec after-stimulation)
    judp('SEND', 6610, '68.181.114.170', [int8('Action0101[Stop Record()]:'), int8(num2str(double(n_done_trials)+1))])
    judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
    pause(3); % wait for 3 sec with laser blanking
elseif strcmp(SessionType, 'Passive Pole')
    judp('SEND', 6610, '68.181.114.170', [int8('Action0101[Stop Record()]:'), int8(num2str(double(n_done_trials)+1))])
    judp('SEND', 7000, '68.181.112.192', [int8('L0') 10]); 
    pause(3); % wait for 3 sec with laser blanking    
end
% SoloFunctionAddVars('state35', 'rw_args', 'n_done_trials', ...
%         'ro_args', 'trial_finished_actions');
% SoloParamhandle(obj, 'iti', 'value', 0); % for debugging motor move time

n_done_trials.value = n_done_trials + 1;

% trialnumstr = strcat('F',num2str(double(n_done_trials)));
% judp('SEND', 7000, '68.181.114.170', [int8(trialnumstr) 10])           
disp(['trial num ',num2str(double(n_done_trials)), ' done'])


if ismember(SessionType, {'2port-Discrim'})
    for i=1:length(trial_finished_actions),
        eval(trial_finished_actions{i});
    end;
else
    for i=1:length(trial_finished_actions),
        if i ~= 6 % bypassing MotorsSection in pole_2port_angdistobj.m
            eval(trial_finished_actions{i});
        end
    end;
end
n_started_trials.value = n_started_trials + 1;
disp(['trial num ',num2str(double(n_started_trials)), ' started'])
% iti.value = toc(a);
% iti_value = toc(a);
% if iti_value < 1
%     pause (1-iti_value); % make sure that iti exceeds 1 sec
% end

% 2016/07/04 JK for whisker video notation
if strcmp(SessionType, '2port-Discrim') || strcmp(SessionType, 'Piezo stimulation') || strcmp(SessionType, 'Passive Pole')
    trialnumstr = strcat('M',num2str(double(n_started_trials)));
    judp('SEND', 7000, '68.181.112.192', [int8(trialnumstr) 10])
    judp('SEND', 7000, '68.181.112.192', [int8('L1') 10]); % re-open the laser
    judp('SEND', 6610, '68.181.114.170', [int8('Action0101[create new sequence and start recording()]:'), int8(num2str(double(n_started_trials)))])
end
% trialnumstr = strcat('S',num2str(double(n_started_trials)));

% Testing motor movement time
% if ismember(SessionType, {'Discrim_DHO','2port-Discrim'})
% if ismember(SessionType, {'2port-Discrim'})
%         disp(['Starting move...'])     
% %         tic
%         MotorsSection(obj,'move_next_side'); % chooses and *moves* to next side
% %         error('TESTING!')
%         disp(['Move finished. Ready for trial ' int2str(value(n_started_trials))]) 
% %         toc        
% else
%     % nothing
% end






