function move_absolute(z, position, varargin)
%
%
%
if strcmp(get(z.sobj,'Status'),'closed')
    error('Serial port status is closed.')
end

if position > 180000 | position < 0
    error('Desired position out of range.') % Need to check range; this just guess.
end

if nargin>2
    unit = varargin{1};
else
    unit = 0;
end

%cmd = [unit 20 single_to_four_bytes(position)];
cmd = ['/1 ' num2str(unit) ' move abs ' num2str(position)];
%fwrite(z.sobj,cmd,'uint8');%,'async');
fprintf(z.sobj,cmd);%,'async');
