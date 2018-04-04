function [] = push_history(owner);
%
% For all the SoloParamHandles that are GUI types and that have an
% owner string that match a regexp with the passed param owner, do a
% push_history on them. See SoloParamHandle/push_history.m
%
   
% $Id: push_history.m,v 1.4 2006/02/20 22:00:54 cnmc1 Exp $   
   
   handles = get_sphandle('owner', owner);
   for i=1:length(handles),
      if ~isempty(get_type(handles{i})), push_history(handles{i}); end;
   end;
   
   
