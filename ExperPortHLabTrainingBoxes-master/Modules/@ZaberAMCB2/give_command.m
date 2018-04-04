function give_command(z,cmdnum,data,varargin)
%
%
%
if strcmp(get(z.sobj,'Status'),'closed')
    error('Serial port status is closed.')
end

if nargin>3
    unit = varargin{1};
else
    unit = 0;
end

if cmdnum == 1
    zabercmd = ' home ';
elseif cmdnum == 20
    zabercmd = ' move abs ';
elseif cmdnum == 43
    zabercmd = ' set accel ';
else
    disp('not a valid or programmed zaber command');
end    

cmd = ['/1 ' num2str(unit) zabercmd num2str(data)];
% disp(['give_command::command to zaber: ' num2str(cmdnum) ':' zabercmd ' data: ' num2str(data)]);
fprintf(z.sobj,cmd);%,'async');

% %cmd = [unit cmdnum single_to_four_bytes(data)];
% disp(['give_command::command to zaber: ' num2str(cmdnum) ' data: ' num2str(data)]);
% fwrite(z.sobj,cmd,'int8');
