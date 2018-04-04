function [obj] = set_current_training_stage(obj, val)

% Sets the index of the currently active training string.
% Note: If the set of training stages is empty, sets the value to 1
% regardless of what value is provided as an input argument.

ts   = get_training_stages(obj);

if ~isempty(ts)

   if val > rows(ts),
      comp_sum = 0;
      for k = 1:rows(ts), comp_sum = comp_sum + ts{k,obj.is_complete_COL}; end;
      if comp_sum < rows(ts),
         error(['Current training stage exceeds total number of training ' ...
                'stages! Are you really done?']);
      else
         val = rows(ts);
      end;
   
   elseif val < 0, 
      error('Current training stage must be a natural number');
   end;

   
   obj = set_current_training_stage_unchecked(obj, val);

else

   obj.current_train_stage = 1;
end;

