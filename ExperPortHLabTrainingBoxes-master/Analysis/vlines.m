function [ll] = vlines(x, y0, y1)

   yls = get(gca, 'Ylim');
   if nargin < 3, y1 = yls(2); end;
   if nargin < 2, y0 = yls(1); end;
   
   if prod(size(x)) ~= length(x),
       error('Need x to be a vector');
   end;
   
   if size(x,1) > size(x,2), x = x'; end;
   
   l = line([x ; x], [y0*ones(size(x)) ; y1*ones(size(x))]);
   
   if nargout > 0, ll = l; end;
   