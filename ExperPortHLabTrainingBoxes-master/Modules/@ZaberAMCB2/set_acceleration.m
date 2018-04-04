function set_acceleration(z,data,varargin)
%
% Value persists after powerdown and resets in non-volatile memory.
%
if strcmp(get(z.sobj,'Status'),'closed')
    error('Serial port status is closed.')
end

if data > 10000 | data < 1
    error('Desired acceleration out of range.')
end

if nargin>2
    unit = varargin{1};
else
    unit = 0;
end

%cmd = [unit 43 single_to_four_bytes(data)];
cmd = ['/1 ' num2str(unit) ' set accel ' num2str(data)];
%fwrite(z.sobj,cmd,'int8');
fprintf(z.sobj,cmd);%,'async');
