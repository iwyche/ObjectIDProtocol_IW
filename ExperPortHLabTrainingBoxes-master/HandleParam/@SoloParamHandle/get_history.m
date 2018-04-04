function [vh] = get_history(sph, u)
   
   global private_soloparam_list
   if nargin==1,
      vh = get_history(private_soloparam_list{sph.lpos});
   else
      vh = get_history(private_soloparam_list{sph.lpos}, u);
   end;
      