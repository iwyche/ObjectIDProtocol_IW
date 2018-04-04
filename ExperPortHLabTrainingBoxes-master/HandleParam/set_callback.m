function [] = set_callback(handles, callback)
%
% Use this function to set common callbacks for a set of
% SoloParamHandles. This function is a wrapper for
% @SoloParamHandle/set_callback.m. The first parameter here, 'handles',
% can be a single SPH, or it can be a cell column vector of SPHs, in
% which case all the passed SPHs get the same callbacks.
%

% $Id: set_callback.m,v 1.3 2006/01/28 04:56:02 carlos Exp $
      
   if isempty(handles), return; end;
   
   if ~iscell(handles), handles = {handles}; end;
   handles = handles(:);
   
   for i=1:length(handles),
      if ~isa(handles{i}, 'SoloParamHandle'),
         error('Only know how to set callbacks for SoloParamHandles');
      end;
      set_callback(handles{i}, callback);
   end;
   
