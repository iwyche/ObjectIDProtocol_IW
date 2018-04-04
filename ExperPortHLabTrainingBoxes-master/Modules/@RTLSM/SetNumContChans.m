% sm = SetNumContChans(sm, val)
%                Configure the state machine to use val continuous output
%                channels.  This reconfiguration takes effect after the
%                next State Matrix upload (a call to SetStateMatrix).
function sm = SetNumContChans(sm, val)
    if (val < 0 || val+sm.num_trig_chans > 32), error('Currently, the state machine implementation supports no more than 32 total output channels, and your specification of %d cont chans would bring the total to %d.', val, val+sm.num_trig_chans); end;
    sm.num_cont_chans = val;
    return;
    