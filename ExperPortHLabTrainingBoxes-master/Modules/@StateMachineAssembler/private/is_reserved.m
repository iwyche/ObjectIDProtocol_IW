% [t] = is_reserved(str)

% Written by Carlos Brody October 2006

function [t] = is_reserved(str)
   
   t = ismember(str, reserved_word_list);
   return;
   
   