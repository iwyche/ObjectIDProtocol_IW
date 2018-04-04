% [obj] = set_current_training_stage_unchecked(obj, val)
%
% Assumes that val is numeric and is within appropriate range.
%
% If val is equal to the current training stage, does
% nothing. Otherwise, calls delete_current_sphandle on the old training
% stage number, and create_current_sphandle on the new training stage
% number, and sets the current training stage number to val.

function [obj] = set_current_training_stage_unchecked(obj, val)

   if obj.current_train_stage == val, return; end;

   delete_current_sphandles(obj);   
   obj.current_train_stage = val;
   create_current_sphandles(obj);
    