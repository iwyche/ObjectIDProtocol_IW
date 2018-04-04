%sortcell [C,I] = sortcell(C)  Sorts cell arrays, by rows
%
% Assumes that C is a square array of elements. Each column must
% composed of either strings or single numbers. Sorts
% alphabetically.  
%

function [N, I] = sortcell(C)

   N = zeros(size(C));
   for i=1:cols(C), % Get unique entries column-by-column
      if isstr(C{1,i}),     % for string columns
         [trash1, trash2, J] = unique(C(:,i));
         N(:,i) = J;
      else                  % for numerical columns
         M = cell2num(C(:,i));  
         [trash1, trash2, J] = unique(M);
         N(:,i) = J;
      end;
   end;
   
   [N, I] = sortrows(N);
   N = C(I,:);
   return;
   
         
   