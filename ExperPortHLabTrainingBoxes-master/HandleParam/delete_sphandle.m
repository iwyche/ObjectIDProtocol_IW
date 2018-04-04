% [n] = delete_sphandle({'owner', '.*'}, {'name', '.*'}, ...
%             {'fullname', '.*'}, {'handlelist', all})
% 
% Finds those SoloParamHandles that regexp match the indicated owner
% (default: all owners), and that have the indicated name (default: all
% names), and indicated fullname (default: all) and permanently deletes
% them. An optional cell list of handles can also be passed; in that
% case the search and destroy will be limited to those handles listed. 
%
% RETURNS:   n,  the number of handles deleted
% --------
%
% OPTIONAL PARAMS:
% ----------------
%
% 'owner'       A string expression, default '.*' that will be matched
%               against the 'owner' tag of a SoloParamHandle.
%
% 'name'        A string expression, default '.*' that will be matched
%               against the 'name' tag of a SoloParamHandle. This
%               generally matches the ordinary name of the variable.
%
% 'fullname'    A string expression, default '.*' that will be matched
%               against the 'fullname' tag of a SoloParamHandle. This tag
%               includes the name of the function within which the
%               variable lives, as well as the name of the variable
%               itself. 
%
% 'handlelist'  A cell vector of SoloParamHandles.
%
%
% EXAMPLE:
% --------
%
%    >> delete_sphandle('owner', 'locsamp4obj')
%
% will permanently delete any SoloParamHandles owned by locsamp4obj.
%
%    >> delete_sphandle('handlelist', {a;b;c}, 'owner', 'locsamp4obj')
%
% will permanently delete any of a,b, or c handles owned by locsamp4obj.
%

% C Brody wrote me Sep-05

function [n] = delete_sphandle(varargin)
   global private_soloparam_list;
   psl = private_soloparam_list;

   pairs = { ...
       'owner'        '.*'   ; ...
       'name'         '.*'   ; ...
       'fullname'     '.*'   ; ...
       'handlelist'    psl   ; ...
   }; parseargs(varargin, pairs);

   if isempty(handlelist), return; end;
   if isa(handlelist{1}, 'SoloParamHandle'), full_splist_fg = 0;
   else                                      full_splist_fg = 1;
   end;
   
   hsl = handlelist(:); % Just a shorter name for handlelist
   
   handles = zeros(size(hsl));
   for i=1:length(hsl),
      if ~isempty(hsl{i})  &&  ~isempty(regexp(get_owner(hsl{i}), owner)) ...
             &&  ~isempty(regexp(get_name(hsl{i}),     name)) ...
             &&  ~isempty(regexp(get_fullname(hsl{i}), fullname)),
         % Mark the handle for deletion:
         handles(i) = 1; 
      end;
   end;

   u = find(handles);
   if nargout > 0, n = length(u); end;
   for i=1:length(u),
      if full_splist_fg, delete(SoloParamHandle(u(i)));
      else               delete(hsl{u(i)});
      end;
   end;
   
   
   
