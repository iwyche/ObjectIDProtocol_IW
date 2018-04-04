function set_microsteps_per_step(z,data)
%
% Value persists after powerdown and resets in non-volatile memory.
%
if strcmp(get(z.sobj,'Status'),'closed')
    error('Serial port status is closed.')
end

if data > 10000 | data < 1
    error('Desired acceleration out of range.')
end

%cmd = [z.unit 37 single_to_four_bytes(data)];
cmd = ['/1 0 set resolution ' num2str(data)];
%fwrite(z.sobj,cmd,'int8');
fprintf(z.sobj,cmd);%,'async');