%uniquecell [S] = uniquecell(C)   return unique rows of cell array C
%
% Every column of C must be either strings or numbers. S will have
% sorted, unique, rows of C. Crucially, S will have the same number of
% columns as C. 
%



function [S] = uniquecell(C)
   
   T = sortcell(C);         % SP: Strategy seems to be to sort and then
   if rows(T) <= 1,         % go down cell row-by-row, discarding equal cell rows
      S = T; return;
   end;
   
   nuniques = 1; 
   lastguy = T(1,:);

   S = cell(size(T));
   S(1,:) = lastguy;
   
 
   for i=2:rows(T),
      if ~isequal(T(i,:), lastguy),
         lastguy = T(i,:);
         nuniques = nuniques + 1;
         S(nuniques,:) = lastguy;
      end;
   end;

   S = S(1:nuniques,:);

   return;
   
   
   
% ---------

function [t] = isequal(A, B)
% Given two column cell string vectors, return 1 if they are equal, 0
% if not. A and B must have same number of columns.
   
   t = 1;
   for i=1:cols(A),
      if isstr(A{i}),
         if ~strcmp(A{i}, B{i}), t=0; return; end;
      else
         if A{i} ~= B{i}, t=0; return; end;
      end;
   end;
   
   return;
   
   