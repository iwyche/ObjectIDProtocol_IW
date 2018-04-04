
if ~isempty(whos('global','motors'))
    global motors
    if isa(motors,'zaberTCD1000')
        close_and_cleanup(motors)
    end
end

delete(get(0,'Children'));
close all;
clear all;
clear classes;
clear functions;

