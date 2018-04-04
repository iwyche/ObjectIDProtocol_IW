function move_home(z, varargin)
%
%
%
disp('move home called');
if strcmp(get(z.sobj,'Status'),'closed')
    error('Serial port status is closed.')
end

if nargin>1
    unit = varargin{1};
else
    unit = 0;
end

cmd = ['/1 ' num2str(unit) ' home'];
fprintf(z.sobj,cmd);%,'async');

%fwrite(z.sobj,[unit 1 0 0 0 0],'uint8'); % home