% [] = delete(sph)    Permanently deletes the passed SoloParamHandle. 
%
% Also deletes any graphics objects associated with it; removes it from
% the AutoSet register; and removes it from the register of functions
% that have been granted access to it. 
%



% CDB wrote me Sep 05

function [] = delete(sph)

   RegisterAutoSetParam(sph, 'delete');
   SoloFunctionAddVars(sph, 'add_or_delete', 'delete');
   
   if ~isempty(get_type(sph)),
      lh = get_lhandle(sph);
      gh = get_ghandle(sph);
      if ishandle(lh), delete(lh); end;
      if ishandle(gh), delete(gh); end;
   end;
   
   global private_soloparam_list;
   
   private_soloparam_list{sph.lpos} = [];
