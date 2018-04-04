function [] = load_datafile(ratname, task, date, f_ver, varargin)

if ~isstr(ratname)  % callback    if nargin < 4   % src, event + 3 mandatory
    if nargin < 8
        error('Either make the rat a string, or give me more args!');
    end;
    fprintf(1, 'I''m here!');
    temp = varargin;
    varargin{1} = date; varargin{2} = f_ver; varargin(3:length(temp)+2) = temp;
    2;
end;

if nargin < 4
    f_ver = date(end);
    date = date(1:end-1);
end;

pairs = {
    'realign', 0 ; ...
    'dlist', []; ...
    'plist', [];...
    'rlist', []; ...
    };
parse_knownargs(varargin, pairs);

if ~isempty(rlist)
    ratname = get(rlist, 'String'); ratname = ratname{get(rlist, 'Value')};
    task = get(plist, 'String'); task = [lower(task{get(plist, 'Value')}) 'obj'];
    date = get(dlist, 'String'); date = date{get(dlist, 'Value')}; f_ver = date(end); date = date(1:end-1);
end;

pairs = {'realign', 0 ; }; parse_knownargs(varargin, pairs);
    
global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
try
    rat_dir = [Solo_datadir filesep 'data' filesep ratname filesep]; 
    if realign > 0, rat_dir = [rat_dir 'realigned' filesep]; end;
    fname = [rat_dir 'data_' task '_' ratname '_' date f_ver];
    if realign > 0, fname = [fname '_realigned']; end;
    load([fname '.mat']);
catch
    error(['Invalid file: ' fname]);
end;

assignin('caller', 'saved', saved);
assignin('caller', 'saved_history', saved_history);
assignin('caller', 'fig_position', fig_position);
assignin('caller', 'saved_autoset', saved_autoset);