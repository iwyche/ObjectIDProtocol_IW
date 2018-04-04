%setdiff_sph.m    [hlist] = setdiff_sph(s1, s2)
%
% Given two cells containing SoloParamHandles, returns a cell
% containing all those SPHs that are in s1 but not in s2.
%

function [hlist] = setdiff_sph(s1, s2)
   
   if isempty(s1) | isempty(s2), hlist = s1; return; end;

   s1 = s1(:); s2 = s2(:);
   
   guys = ones(size(s1));
   for i=1:length(s1),
      j=1; while j<=length(s2),
         if is_same_soloparamhandle(s1{i}, s2{j}),
            guys(i) = 0;
            j = length(s2);
         end;
      j=j+1; end;
   end;
   
   hlist = s1(find(guys));
   
