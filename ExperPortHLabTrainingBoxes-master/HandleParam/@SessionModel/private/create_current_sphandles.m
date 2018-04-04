%create_current_sphandles.m     [] = create_current_sphandles(obj, ind)
%
% If passed only one argument, a SessionModel object, looks up the var names
% for that SessionModel object for the current training stage, and
% creates, for each name, a SoloParamHandles with that name and owner =
% get_owner(obj), funcowner = 'SessionModel', value = 0.
%
% If passed a second argument, interprets that as an integer indicating
% the stage number for which vars are to be created. If the index is
% out of range, does nothing.
%


function [] = create_current_sphandles(obj, ind)

   if nargin < 2, ind = get_current_training_stage(obj); end;
   ts = get_training_stages(obj);

   if ind < 1 || ind > rows(ts), return; end;
   
   vars = ts{ind, obj.vars_COL};

   for i=1:length(vars),
      varname = strtrim(vars{i});
      if ~isempty(varname),
         SoloParamHandle(obj, varname, 'param_owner', get_owner(obj), ...
                         'param_funcowner', 'SessionModel', 'value', 0);
      end;
   end;

