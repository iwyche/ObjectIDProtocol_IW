%delete_current_sphandles.m     [] = delete_current_sphandles(obj, ind)
%
% If passed only one argument, a SessionModel object, looks up the var names
% for that SessionModel object for the current training stage, and
% deletes all SoloParamHandles with those names and owner =
% get_owner(obj), funcowner = 'SessionModel'.
%
% If passed a second argument, interprets that as an integer indicating
% the stage number for which vars are to be deleted. If the index is
% out of range, does nothing.
%


function [] = delete_current_sphandles(obj, ind)

   if nargin < 2, ind = get_current_training_stage(obj); end;
   ts = get_training_stages(obj);

   if ind < 1 || ind > rows(ts), return; end;
   
   vars = ts{ind, obj.vars_COL};

   for i=1:length(vars),
      varname = strtrim(vars{i});
      if ~isempty(varname),
         sp = get_sphandle('owner', get_owner(obj), 'fullname', ...
                                    ['^SessionModel_' varname '$']);
         for j=1:length(sp), delete(sp{j}); end;
      end;
   end;

