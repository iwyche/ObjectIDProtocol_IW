% [hname] = get_hostname   Makes a system call to get a string with hostname
% 
% Returns only non-spaces before the first '.', and returns in all lowercase.
%
% If for some reason there is an error getting the hostname, returns
% 'unknown'. 
% 

function [hname] = get_hostname
   
   try,
      [s, hname] = system('hostname');
      u = find(hname=='.'); 
      if ~isempty(u), u=u(1); hname = hname(1:u-1); end;
      
      hname = lower(hname(~isspace(hname)));
      
   catch,
      hname = 'unknown';
   end;
   
   