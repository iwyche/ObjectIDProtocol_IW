function [sph] = push_history(sph)
% Appends current value onto the object's history list. Despite the
% name, treats history like a queue, not a stack!  Does not clear the
% current value.
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       push_history(private_soloparam_list{sph.lpos});
   
