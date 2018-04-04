function [arglist] = GetSoloFunctionArgList(func_owner, func_name)
% 
% Returns a cell column vector of strings, containing the names of the
% SoloParamHandles that have been registered for the specified function owner
% and function name. Unlike GetSoloFunctionArgs, just returns a list of
% strings, doesn't instantiate anything.
%
% Doesn't distinguish between read-write and read-only variables.   
%   
      
% $Id: GetSoloFunctionArgList.m,v 1.3 2006/02/01 05:01:08 carlos Exp $
   
   arglist = GetSoloFunctionArgs('arglist', func_owner, func_name);
   
   
