function [date_list] = available_dates(ratname, task, varargin)

% Given a rat and taskname, provides the list of dates for which data
% exists in the 'SoloData' directory of the current computer.
% The taskname is as specified on the data filename (e.g. Duration
% Discrimination would have 'duration_discobj' as its task designation).

if ~isstr(ratname)  % callback    if nargin < 4   % src, event + 3 mandatory
    if nargin < 4
        error('Either make the rat a string, or give me more args!');
    end;
end;

pairs = {
    'realign', 0 ; ...
    'cbk', []; ...
    'plist', [];...
    'rlist', []; ...
    };
parse_knownargs(varargin, pairs);

if ~isempty(cbk)
    ratname = get(rlist, 'String'); ratname = ratname{get(rlist, 'Value')};
    task = get(plist, 'String'); task = [lower(task{get(plist, 'Value')}) 'obj'];
end;

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;


files = [Solo_datadir filesep 'data' filesep ratname filesep];
if realign > 0, files = [files 'realigned' filesep];end;
files = ls([files]);

expr = ['data_' task '_' ratname '_(\S+)\.mat|data_' task '_' lower(ratname) '_(\S+)\.mat'];
if realign > 0, expr = [expr '_realigned'];end;

c_files = cellstr(files);
matches = regexp(c_files, expr, 'tokens');

date_list = cell(0,0); dctr = 1;
matches = matches{1};
for d = 1:length(matches)
    if ~isempty(matches{d})
        tok = matches{d}; tok = tok{1};
        if ~strcmpi(tok(end-2:end), 'ASV')
            date_list{dctr} = tok;
            dctr = dctr+1;
        end;
    end;

end;

if ~isempty(cbk)
    dstring = {'-- No available dates --'};
    if ~isempty(date_list), dstring = sort(date_list); end;
    set(cbk, 'String', dstring); 
    fprintf(1, 'Got files for %s: %s\n', ratname, task);
end;

