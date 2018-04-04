% [] = save_solouiparamvalues(ratname, varargin)
%
% Opens up interactive filename chooser and then saves all
% GUI soloparamvalues (but no non-GUI values). Doesn't save histories.
% First arg is a string identifying the rat.
%
% PARAMETERS:
% ----------
%
% ratname     This will determine which directory the file goes into.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% child_protocol     by default, empty. If non-empty, should be an SPH
%                    that holds an object whose class will indicate the
%                    class of the child protocol who is the real
%                    owner of the vars to be saved.
%
% asv                by default, zero. If 1, this is an non-interactive
%                    autosave, and the file will end in _ASV.mat. If 0,
%                    this is a normal file.
%
% interactive        by default 1; dialogues with the user to determine
%                    the file in which the data will be saved. If 0,
%                    the default suggested filename is used, with
%                    possible overwriting and no questions asked.
%
% commit             by default, 0; if 1, tries to add and commit to CVS
%                    the recently saved file.
%

function [] = save_solouiparamvalues(ratname, varargin)

pairs = { ...
    'child_protocol', [] ; ...
    'asv', 0; ...
    'interactive'      1 ; ...
    'commit'           0 ; ...
    };
parseargs(varargin, pairs);

if isempty(child_protocol),
    owner = determine_owner;
else
    owner = class(value(child_protocol));   % the child protocol owns all vars
    % owner = c(2:end);
end;

owner = owner;
global Solo_datadir;
if isempty(Solo_datadir),
    Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
end;
settings_path = [Solo_datadir filesep 'Settings'];
if ~exist(settings_path, 'dir'),
    success = mkdir(Solo_datadir, 'Settings');
    if ~success, error(['Couldn''t make directory ' settings_path]); end;
end;

handles = get_sphandle('owner', owner);
k = zeros(size(handles));
for i=1:length(handles),
   if ~isempty(get_type(handles{i}))  &&  ...
        ~ismember(get_type(handles{i}), {'disp' 'pushbutton'})  && ...
        get_saveable(handles{i})==1,
      k(i) = 1;
   end;
end;
handles = handles(find(k));

saved         = struct;
saved_autoset = struct;
for i=1:length(handles),
    saved.(get_fullname(handles{i}))        = value(handles{i});
    saved_autoset.(get_fullname(handles{i}))= get_autoset_string(handles{i});
end;

protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
if ~isempty(protocol_name),
   protocol_name = protocol_name{1};
   fig_position = get(findobj(get(0, 'Children'), ...
                              'Name', value(protocol_name)), 'Position');
else
   fig_position = [];
end;

% Load Settings directory to save in

if settings_path(end)~=filesep, settings_path=[settings_path filesep]; end;
rat_dir = [settings_path ratname];
if ~exist(rat_dir)
    success = mkdir(settings_path, ratname);
    if ~success, error(['Couldn''t make directory ' rat_dir]); end;
end;
if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;

if asv > 0
    pname = rat_dir;
    fname = ['settings_' owner '_' ratname '_' ...
        yearmonthday '_ASV.mat'];
else
    u = dir([rat_dir 'settings_' owner '_' ratname '_' ...
        yearmonthday '*.mat']);

    if ~isempty(u),
        [filenames{1:length(u)}] = deal(u.name); filenames = sort(filenames');
        fullname = [rat_dir filenames{end}];
        fullname = fullname(1:end-4); % chop off .mat
        if strcmpi(fullname(end-3:end),'_ASV')
          fullname = [fullname(1:end-4) 'a'];
      else
          fullname(end) = fullname(end)+1;
      end;
    else
        fullname = [rat_dir 'settings_' owner '_' ratname '_' ...
            yearmonthday 'a'];
    end;

    rn = ratname;
    if interactive,
       [fname, pname] = ...
           uiputfile({['*' owner '*' rn '*.mat'], ...
                      [owner ' ' rn ' files (' owner '*' rn '*.mat)'] ; ...
                      ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
                      '*.mat',  'All .mat files (*.mat)'}, ...
                     'Save settings', fullname);
       if fname == 0, return; end;
    else
       fname = fullname; pname = '';
    end;
end;

save([pname fname], 'saved', 'saved_autoset', 'fig_position');

% Make sure it is a .mat extension:
[path, name, ext] = fileparts([pname fname]); 
if ~strcmp('.mat', ext), fname = [name '.mat']; end;
% Then add and commit if necessary:
if commit, add_and_commit([path filesep fname]); end;

