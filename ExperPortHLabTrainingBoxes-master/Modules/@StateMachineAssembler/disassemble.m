function [] = disassemble(sma, events)

   statenames = get_labels(sma);
   colnames   = get_col_labels(sma);

   stateids = cell2mat(statenames(:,2)); 
   colids   = cell2mat(colnames(:,2));
   
   outcols = cell2mat(sma.output_map(:,2)');
   mnoc    = min(outcols)-1;
   
   [trash, I] = sort(stateids);
   statenames = statenames(I,:);
   stateids = cell2mat(statenames(:,2)); 

   sma.states = [sma.states ; sma.iti_states];
   
   for i=1:rows(events),
      cid = find(events(i,2)==colids);
      if isempty(cid), col_str = 'none';
      else             col_str = colnames{cid,1};
      end;
      
      sid = max(find(events(i,1) >= stateids));
      if isempty(sid), state_str = 'none';
      else             state_str = statenames{sid,1};
      end;

      fprintf(1, '%d:%s \t %s \t %.5f \t', events(i,1), state_str, ...
              col_str, events(i,3));
      if i==1 || events(i-1,1) ~= events(i,1),
          for j=1:length(outcols),
              outval  = sma.states{events(i,1)+1, outcols(j)-mnoc};
              if ~isempty(outval)  && (~isnumeric(outval) ||  outval ~= 0),
                  outname = sma.output_map{j,1};
                  switch outname,
                      case 'DOut',         fprintf(1, 'DOut=%d \t', outval);
                      case 'SoundOut',     fprintf(1, 'SoundOut=%d \t', outval);
                      case 'SchedWaveTrig', fprintf(1, 'SchedWaveTrig=%s \t', outval);
                      otherwise             fprintf(1, '%s=%d \t', outname, outval);
                  end;
              end;
          end;
      end;
      fprintf(1, '\n');
   end;
   