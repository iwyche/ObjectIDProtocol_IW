%is_same_soloparamhandle.m    [t] = is_same_soloparamhandle(u1, u2)
%
% Checks to see whether two handles actually point to the same
% SoloParam (i.e., are equal not only in value but also in reference). 
%
   
% $Id: is_same_soloparamhandle.m,v 1.3 2006/01/28 04:56:02 carlos Exp $
   
function [t] = is_same_soloparamhandle(u1, u2)
   
   if isa(u1, 'SoloParamHandle') && isa(u2, 'SoloParamHandle'),
      t = (u1.lpos == u2.lpos);
   else
      t = 0;
   end;
   
