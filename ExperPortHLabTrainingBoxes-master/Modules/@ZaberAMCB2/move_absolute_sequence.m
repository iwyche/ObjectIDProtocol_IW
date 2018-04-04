function move_absolute_sequence(z, seq, varargin)
%
% Move actuator to a sequence of absolute positions, without pausing at each 
% position. 
%
% 12/06, DHO
%

% warning off MATLAB:instrcb:invalidcallback

if ~isa(seq,'cell')
    error('Argument seq must be a cell array')
end

if nargin > 2
    unit = varargin{1};
else
    unit = 1;
end

% jitter mode - jitters by uniform distro of [0 127]; if 
%  position >= 180000-128, jitters by NEGATIVE that.
jitter_mode = 0; % set to 0 to disable
if (jitter_mode == 1) 
    disp('move_absolute_sequence.m::jitter mode ON ; jittering by 128 microsteps'); 
end

if z.sobj.BytesAvailable > 0
%     fread(z.sobj,z.sobj.BytesAvailable,'uint8');  % clear input buffer
    fscanf(z.sobj,'%s',z.sobj.BytesAvailable);
end

for k=1:length(seq)
    position = seq{k};    
    % jitter 
    if (jitter_mode == 1)
        offs = round(127*rand);
        if (position < (180000-128))
            position = position + offs;
        else
            position = position - offs;
        end
    end
    cmd = ['/0 ' num2str(unit) ' move abs ' num2str(position)];
    fprintf(z.sobj,cmd);

%     disp(['move_absolute_sequence::command to zaber: ' cmd]);

    motor_status = 1;
    while motor_status ~= 0; % status 0 is idle
        %         fwrite(z.sobj,[unit 54 0 0 0 0],'uint8'); % Command 54: Return Status
        try
            motor_status = get_status(z,unit);
        catch
%             stop(z.sobj);
%             reset(z.sobj);
%             renumber_all(z.sobj);
%             % If timeout error, clear buffer and try again:
%             if z.sobj.BytesAvailable > 0
%                  fscanf(z.sobj,'%s',z.sobj.BytesAvailable);
%             end
%             motor_status = get_status(z,unit);
% error at stop(z.sobj) after state35. 2016/05/17 JK. 2016/06/05 again.
        end
        if motor_status ~= 0
            pause(0.01);
        end
    end
end





% set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
% set(z.sobj,'BytesAvailableFcn',{@bytes_available_callback, z, unit, seq, k})
% % set(z.sobj,'BytesAvailableFcn',{@next_move, z, unit, seq, k})
% 
% position = seq{k};
% cmd = [unit 20 single_to_four_bytes(position)];
% fwrite(z.sobj,cmd,'uint8');%,'async'); % Maybe *not* asynch?

% 
% function next_move(obj,event,z,unit,seq,k)
% % display(['callbk run with k=' int2str(k)])
% ba = get(obj,'BytesAvailable');
% if ba > 0
%     [A,count,msg] = fread(obj,ba,'uint8');
% end
% k = k+1;
% move_absolute_sequence(z,unit,seq,k);




% %%
% function move_absolute_sequence(z, unit, seq, varargin)
% %
% % Move actuator to a sequence of absolute positions, without pausing at each 
% % position. Works by recursion.
% %
% % 12/06, DHO
% %
% 
% 
% if ~isa(seq,'cell')
%     error('Argument seq must be a cell array')
% end
% 
% if nargin > 3
%     k = varargin{1};
% else
%     k = 1;
% end
% 
% ba = get(z.sobj,'BytesAvailable');
% if k==1 && ba > 0
%     fread(z.sobj,ba,'uint8')  % clear input buffer
% end
% 
% if k > length(seq)
%     return
% end
% 
% % set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
% set(z.sobj,'BytesAvailableFcn',{@next_move, z, unit, seq, k})
% 
% position = seq{k};
% cmd = [unit 20 single_to_four_bytes(position)];
% fwrite(z.sobj,cmd,'uint8');%,'async'); % Maybe *not* asynch?
% 
% 
% function next_move(obj,event,z,unit,seq,k)
% % display(['callbk run with k=' int2str(k)])
% ba = get(obj,'BytesAvailable');
% if ba > 0
%     [A,count,msg] = fread(obj,ba,'uint8');
% end
% k = k+1;
% move_absolute_sequence(z,unit,seq,k);
% 

