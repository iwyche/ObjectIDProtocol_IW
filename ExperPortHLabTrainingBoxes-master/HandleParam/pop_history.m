function [] = pop_history(owner);

   handles = get_sphandle('owner', owner);
   for i=1:length(handles),
      if ~isempty(get_type(handles{i})), pop_history(handles{i}); end;
   end;
   
   