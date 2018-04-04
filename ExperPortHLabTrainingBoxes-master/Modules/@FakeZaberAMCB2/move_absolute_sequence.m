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

pause(2);

% 
% if z.sobj.BytesAvailable > 0
%     fread(z.sobj,z.sobj.BytesAvailable,'uint8');  % clear input buffer
% end
% 
% for k=1:length(seq)
%     position = seq{k};
%     cmd = [unit 20 single_to_four_bytes(position)];
%     fwrite(z.sobj,cmd,'uint8');
% 
%     motor_status = 20;
%     while motor_status ~= 0; % status 0 is idle
%         fwrite(z.sobj,[unit 54 0 0 0 0],'uint8'); % Command 54: Return Status
%         motor_status = get_status(z,unit);
%         if motor_status ~= 0
%             pause(0.01);
%         end
%     end
% end




