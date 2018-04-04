% sm = SetNumTrigChans(sm, val)
%                Configure the state machine to use val trigger output
%                channels.  This reconfiguration takes effect after the
%                next State Matrix upload (a call to SetStateMatrix).
function sm = SetNumTrigChans(sm, val)
    if (val < 0 || val+sm.num_cont_chans > 32), error('Currently, the state machine implementation supports no more than 32 total output channels, and your specification of %d trig chans would bring the total to %d.', val, val+sm.num_cont_chans); end;
    sm.num_trig_chans = val;
    return;
    