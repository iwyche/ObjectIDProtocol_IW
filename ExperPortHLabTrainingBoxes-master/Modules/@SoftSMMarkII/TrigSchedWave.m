function [sm] = TrigSchedWave(sm, idx, ts)
    untrig = 0;
    if (idx < 0), % negative idx means untrigger an already-running wave
      idx = -idx;
      untrig = 1;
    end;
    
    sw = sm.SchedWaves{idx,1};
    
    if (~isstruct(sw)),
      error(['INTERNAL ERROR sm.SchedWaves does not contain a struct!']);
    end;
    
    if (sw.running && ~untrig), 
      if (sm.debug),
        warning(sprintf(['Triggered already-running sched-wave' ...
        ' %d, ignoring...'], sw.id));
      end;
      return;
    elseif (~sw.running && untrig)
      if (sm.debug),
        warning(sprintf(['UnTriggered already-not-running sched-wave' ...
        ' %d, ignoring...'], sw.id));
      end;
      return;
    end;
    
    if (~untrig),
      % request was to trigger this wave
      sw.startTS = ts;
      sw.running = 1;
      sw.didUP = 0;
      sw.didDOWN = 0;
    else
      % request was to untrigger this wave      
      sw.running = 0;
      sw.didUP = 0;
      sw.didDOWN = 0;
    end;
    
    sm.SchedWaves{idx, 1} = sw;
    
    return;
