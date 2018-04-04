% scalar = GetNumContChans(sm)
%                Returns the number of continuous channels presently 
%                configured.  See SetNumContChans().
function num = GetNumContChans(sm)
    return sm.num_cont_chans;