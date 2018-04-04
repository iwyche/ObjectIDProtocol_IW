% [] = save_soloparamvalues(ratname, varargin)
%
% Opens up interactive filename chooser and then saves ALL soloparamvalues
% (gui AND non-gui). First arg is a string identifying the rat.
%
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
% remove_asvs        by default, 1. If remove_asvs==1 AND asv ~= 1
%                    (i.e., this NOT an asv save), then
%                    after doing the regular saving of the data, any
%                    ASV file of the same date will be removed (i.e.,
%                    cleanup).  
%
% EXAMPLE CALL:
% -------------
%
%   >> save_solouiparamvalues(ratname, 'commit', 1);
%



function [] = save_soloparamvalues(ratname, varargin)

pairs = { ...
    'child_protocol', [] ; ...
    'asv', 0; ...
    'interactive'      1 ; ...
    'commit'           0 ; ...
    'remove_asvs'      1 ; ...
    };
parse_knownargs(varargin, pairs);

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
   data_path = [Solo_datadir filesep 'Data'];
   if ~exist(data_path, 'dir'),
      success = mkdir(Solo_datadir, 'Data');
      if ~success, error(['Couldn''t make directory ' data_path]); end;
   end;
   
   handles = get_sphandle('owner', owner);
   k = zeros(size(handles));
   for i=1:length(handles),
      if get_saveable(handles{i}), k(i) = 1; end;
   end;
   handles = handles(find(k));
   
   saved = struct; saved_history = struct; saved_autoset = struct;
   for i=1:length(handles),
      saved.(get_fullname(handles{i}))        = value(handles{i});
      saved_history.(get_fullname(handles{i}))= get_history(handles{i});
      saved_autoset.(get_fullname(handles{i}))= get_autoset_string(handles{i});
   end;

   
   protocol_name = get_sphandle('owner', owner, 'name', 'protocol_name');
   if ~isempty(protocol_name),
      protocol_name = protocol_name{1};   
      fig_position = get(...
        findobj(get(0, 'Children'), 'Name', value(protocol_name)),'Position');
   else
      fig_position = [];
   end;
   
   % Now set the path for the data file
   
   if data_path(end)~=filesep, data_path=[data_path filesep]; end;
   
   rat_dir = [data_path ratname];
    if ~exist(rat_dir)
    success = mkdir(data_path, ratname);
    if ~success, error(['Couldn''t make directory ' rat_dir]); end;
end;
if rat_dir(end)~=filesep, rat_dir=[rat_dir filesep]; end;
    
if asv > 0
    pname = rat_dir;
    fname = [ 'data_' owner '_' ratname '_' ...
        yearmonthday '_ASV.mat'];
else
   u = dir([rat_dir 'data_' owner '_' ratname '_' yearmonthday '*.mat']);
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
      fullname = [rat_dir 'data_' owner '_' ratname '_' yearmonthday 'a'];
   end;
   
   rn = ratname;
    if interactive,
       [fname, pname] = ...
           uiputfile({['*' owner '*' rn '*.mat'], ...
                      [ owner ' ' rn ' files (*' owner '*' rn '*.mat)'] ; ...
                      ['*' rn '*.mat'], [rn ' files (*' rn '*.mat)'] ; ...
                      '*.mat',  'All .mat files (*.mat)'}, ...
                     'Save data', fullname);
       if fname == 0, return; end;    
    else
       fname = fullname; pname = '';
    end;       
end;

save([pname fname], 'saved', 'saved_history', 'saved_autoset', ...
        'fig_position');

% Make sure it is a .mat extension:
[path, name, ext] = fileparts([pname fname]); 
if ~strcmp('.mat', ext), fname = [name '.mat']; end;
% Then add and commit if necessary:
if commit, add_and_commit([path filesep fname]); end;
    
if ~asv,
   asv_pname = rat_dir;
   asv_fname = [ 'data_' owner '_' ratname '_' ...
                 yearmonthday '_ASV.mat'];
   if exist([asv_pname asv_fname], 'file'),
      delete([asv_pname asv_fname]);
   end;
end;
