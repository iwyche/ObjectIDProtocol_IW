% [t] = is_validhandle(sph)   Check whether an SPH is a valid pointer
%                             to an actual SoloParam. 
%
% PARAMETERS:
% -----------
%
% sph    A SoloParamHandle object
%
%
% RETURNS:
% --------
%
% t      0 if the sph isn't a handle to a SoloParam; 1 if it is.
%


function [t] = is_validhandle(sph)
        
   global private_soloparam_list;
   t = isa(private_soloparam_list{sph.lpos}, 'SoloParam');
      
   