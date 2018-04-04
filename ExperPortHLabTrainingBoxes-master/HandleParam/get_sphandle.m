function [handles] = get_sphandle(varargin)
   
   pairs = { ...
       'owner'        '.*'   ; ...
       'name'         '.*'   ; ...
       'fullname'     '.*'   ; ...
       'handlelist'    {}    ; ...
   }; parseargs(varargin, pairs);
   
   if isempty(handlelist),
      global private_soloparam_list;
      psl = private_soloparam_list;
   else
      psl = handlelist;
   end;
   if isempty(psl), handles = {}; return; end;
   
   guys = zeros(size(psl));
   for i=1:length(psl),
      if ~isempty(psl{i})  &&  ...
             (strcmp(owner, '.*') || ~isempty(regexp(get_owner(psl{i}), owner)))  &&  ...
             (strcmp(name,  '.*') || ~isempty(regexp(get_name(psl{i}),   name)))  &&  ...
             (strcmp(fullname, '.*') || ~isempty(regexp(get_fullname(psl{i}), fullname))),
         guys(i) = 1;
      end;
   end;
   
   guys = find(guys);
   if isempty(guys), handles = {}; return; end;
    
   if ~isempty(handlelist),
      handles = handlelist(guys);
   else
      handles = cell(size(guys));
      for i=1:length(guys),
         handles{i} = SoloParamHandle(guys(i));
      end;
   end;
   
   
