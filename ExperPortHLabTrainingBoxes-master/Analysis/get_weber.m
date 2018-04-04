function [xcomm xfin xmid weber] = get_weber(x, y, varargin)

pairs = { ...
    'pitches', 0 ; ...
    };
parse_knownargs(varargin, pairs);

% Finally, plot threshold limits and calculate Weber ratio
plus_sd = normcdf(1); minus_sd = normcdf(-1);
comm = find(abs(y - minus_sd) == min(abs(y-minus_sd)));
fin = find(abs(y - plus_sd) == min(abs(y-plus_sd)));
mid = find(abs(y - 0.5) == min(abs(y-0.5)));


%xfin = x(fin) - x(mid); xcomm = x(mid)-x(comm);
if pitches > 0
    xfin = 2^(x(fin)) - 2^(x(mid));
    xcomm = 2^(x(mid)) - 2^(x(comm));
    xmid = 2^(x(mid));

else
    xfin = exp(x(fin)) - exp(x(mid));
    xcomm = exp(x(mid)) - exp(x(comm));
    xmid = exp(x(mid));
end;

weber = ((xcomm+xfin)/2)/xmid;

xfin = x(fin); xcomm = x(comm); xmid = x(mid);
