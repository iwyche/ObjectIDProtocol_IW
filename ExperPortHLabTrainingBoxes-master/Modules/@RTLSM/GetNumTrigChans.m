% val = GetNumTrigChans(sm)
%                Returns the number of trigger channels presently 
%                configured.  See SetNumTrigChans().
function num = GetNumTrigChans(sm)
    return sm.num_trig_chans;
