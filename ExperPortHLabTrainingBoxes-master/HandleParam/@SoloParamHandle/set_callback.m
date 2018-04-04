function [sph] = set_callback(sph, callback)
%
% Use this function to set the callbacks for when there is a GUI change
% to a SoloParamHandle. In other words, here you list the functions
% that will be called if the SPH changes. The function will be called
% with sph as its first argument, plus any other arguments that you
% indicated, as described below: 
%
% PARAMS:
% -------
%
%  sph         The SoloParamHandle to which callbacks will be added
%
%  callback    A string, which is the name of the function that will be
%                called, as in callback(sph);
%              OR a cell column vector of strings, each of which will
%                be called in sequence, as in callback{i}(sph)
%              OR a cell array of strings; first column is function
%                name, next columns are parameters that will be passed
%                on to the function.
%
%              If the first argument is 'super', then the superclass's
%              callback functions will be called.  

% $Id: set_callback.m,v 1.3 2006/01/28 04:56:02 carlos Exp $
   
   global private_soloparam_list;
   private_soloparam_list{sph.lpos} = ...
       set_callback(private_soloparam_list{sph.lpos}, callback);

   
