% [sma, sched_wave_name] = add_scheduled_wave(sma, varargin)
%

% Written by Carlos Brody October 2006

function [sma, sched_wave_name] = add_scheduled_wave(sma, varargin)
   
   pairs = { ...
     'name'               ''    ;  ...
     'preamble'            1    ;  ...
     'sustain'             0    ;  ...
     'refraction'          0    ;  ...
     'dio_line'           -1    ;  ...
   }; parseargs(varargin, pairs);

   already_have_schedwave_out = ~isempty(sma.sched_waves);   
   if isempty(name),
      sched_wave_name = ['timer' num2str(length(sma.sched_waves)+1)];
   else
      sched_wave_name = name;
   end;
   
   
   % --- BEGIN error-checking ---
   Tup = find(strcmp('Tup', sma.input_map(:,1)));
   if isempty(Tup),
      error('Huh??? input map has no Tup entry?');
   end;
      
   [prev_names{1:length(sma.sched_waves)}] = deal(sma.sched_waves.name);
   if ~isempty(find(strcmp(sched_wave_name, prev_names))),
      error(['A scheduled wave with name ' sched_wave_name ' already ' ...
             'exists.']);
   end;   
   % --- END error-checking ---
   
   
   % We'll add columns for the In and Out events of this sched wave,
   % and we'll put them right behind the Tup:
   in_col  = sma.input_map{Tup, 2};
   out_col = sma.input_map{Tup, 2}+1;
   % make space for the two new cols and move everything after and
   % including Tup forwards by two columns:
   sma.states = [sma.states cell(rows(sma.states),2)];
   sma.states(:,in_col+2:end) = sma.states(:,in_col:end-2);
   sma.states(:,in_col)  = sma.default_actions;
   sma.states(:,out_col) = sma.default_actions;
   % repeat for iti_states:
   sma.iti_states = [sma.iti_states cell(rows(sma.iti_states),2)];
   sma.iti_states(:,in_col+2:end) = sma.iti_states(:,in_col:end-2);
   sma.iti_states(:,in_col)  = sma.default_iti_actions;
   sma.iti_states(:,out_col) = sma.default_iti_actions;

   
   % Now add our new entries to the input map:
   sma.input_map = [sma.input_map(1:in_col-1,:) ; ...
                    {[sched_wave_name '_In'],  in_col ; ...
                     [sched_wave_name '_Out'], out_col} ; ...
                   sma.input_map(in_col:end,:)];

   % And adjust the Tup entry in the input map:
   sma.input_map{Tup+2,2} = sma.input_map{Tup+2,2} + 2;

   % As well as adjusting the self_timer map:
   for i=1:rows(sma.self_timer_map),
      sma.self_timer_map{i,2} = sma.self_timer_map{i,2}+2;
   end;
   % And the output map:
   for i=1:rows(sma.output_map),
      sma.output_map{i,2} = sma.output_map{i,2} + 2;
   end;
   

   if ~already_have_schedwave_out,
      % --- create a column for the scheduled wave triggering signals:
      if ~isempty(sma.states),         
         sma.states = [sma.states num2cell(zeros(rows(sma.states),1))];
      else
         sma.states = cell(0, cols(sma.states)+1);
      end;
      % repeat for iti_states:
      if ~isempty(sma.iti_states),         
         sma.iti_states = [sma.iti_states num2cell(zeros(rows(sma.iti_states),1))];
      else
         sma.iti_states = cell(0, cols(sma.iti_states)+1);
      end;
      
      sma.output_map = [sma.output_map ; {'SchedWaveTrig' cols(sma.states)}];
   end;
   
   
   % Now store it in the scheduled waves list
   snum = length(sma.sched_waves)+1;   
   sma.sched_waves(snum).name       = sched_wave_name;
   sma.sched_waves(snum).id         = snum-1;
   sma.sched_waves(snum).in_column  = in_col;
   sma.sched_waves(snum).out_column = out_col;
   sma.sched_waves(snum).dio_line   = dio_line;
   sma.sched_waves(snum).preamble   = preamble;
   sma.sched_waves(snum).sustain    = sustain;
   sma.sched_waves(snum).refraction = refraction;
   
   
   