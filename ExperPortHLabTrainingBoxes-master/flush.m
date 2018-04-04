
if ~isempty(whos('global','motors'))
    global motors
    if isa(motors,'ZaberAMCB2')
        close_and_cleanup(motors)
    end
end

%Modified by AS 6/9/14 to clear Instrument Object Array

%allInstrObjs = instrfind;
%fclose(allInstrObjs)
%delete(allInstrObjs) %end AS modify


delete(get(0,'Children'));
close all;
clear all;
clear classes;
clear functions;