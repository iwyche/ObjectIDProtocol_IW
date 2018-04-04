function r = get_status(z, varargin)
%
% 12/06, DHO
%

if nargin > 1
    unit = varargin{1};
else
    unit = 1;
end

if z.sobj.BytesAvailable > 0
    fread(z.sobj,z.sobj.BytesAvailable,'uint8');  % clear input buffer
end

cmd = ['/0 ' num2str(unit)];


fprintf(z.sobj,cmd);

reply = fscanf(z.sobj);
%fwrite(z.sobj,[unit 54 0 0 0 0],'uint8'); % Command 54: Return Status
%reply = fread(z.sobj, 6, 'uint8');

%r = four_bytes_to_single(reply(3:6));
if reply(10:13) == 'BUSY'
    r = 1;
else
    r = 0;
end



