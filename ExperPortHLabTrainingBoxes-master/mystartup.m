% Startup file for hybrid Exper/Solo system.
%
% A typical opening command sequence would be
%
%    >> mystartup; ModuleInit('control'); ModuleInit('rpbox');
%
% after which one would select a protocol from the 'protocols' menu in
% the rpbox window.
% Is something weird still happening? 

cd('C:\Users\shires\Documents\GitHub\BControl_Primary\ExperPortHLabTrainingBoxes')

% Exper's repository of all variables:
global exper;

% Variable that determines what kind of Real-Time State Machine, and
% what kind of sound machine, are to be run:
%
%  fake_rp_box = 0    -->   Use the TDT RM1 boxes
%  fake_rp_box = 1    -->   Use FakeRP/@lunghao1 and FakeRP/@lunghao2
%                           objects as virtual machines %-- FakeRP removed, DHO122906#1
%  fake_rp_box = 2    -->   Use the RT Linux state machine
%  fake_rp_box = 3    -->   Use the Modules/@SoftSMMarkII and
%                           Modules/@softsound objects as virtual
%                           machines. These are recommended over the
%                           old @lunghao1 and @lunghao2
%  fake_rp_box = 4    -->   Use the Modules/@softsm and
%                           Modules/@softsound objects as virtual
%                           machines. @softsm has no scheduled waves.

global fake_rp_box;


% The following global is ONLY relevant when NOT using the RT Linux sound
% server.
% When using the virtual sound machine this variable determines whether
% sounds are played or not. Sometimes sounds are not played with the
% precise timing of the RT Linux server; turning them off permits
% examining the timing of states in better detail.
% global softsound_play_sounds;
% To NOT play sounds:
% softsound_playsounds = 0;
% To play sounds as normal:
% softsound_playsounds = 1;



% Need some proper auto-config method...
% global sound_sample_rate;  sound_sample_rate = 50e6/1024;


[status, hostname] = system('hostname');
hostname = lower(hostname);
hostname = hostname(~isspace(hostname));

if ismember(hostname, {'kaikai1'}), %%{'kaikai1' 'hnb228-labpc5'}),
    fake_rp_box = 3;
elseif ismember(hostname, {'hnb228-g1c' 's7256' 'hnb228-labpc5' 'd5xr7xh1' 'labadmin-pc' 'oconnord-ww1' 'computer-labx' 'svobodalab-2b' 'svobodalab-2a' 'svobodalab-2i' 'svobodalab-2k'}),
    fake_rp_box = 2;
else
    fake_rp_box = 3; % force SoftSMMarkII to be the fake rp box
end;

% global state_machine_server;
% global sound_machine_server;
global state_machine_properties;
global motors_properties;
global valves_properties;

switch hostname
    
    case 'hnb228-g1c'
        disp(['live; fake_rp_box = ' num2str(fake_rp_box)]);
        state_machine_properties.server = '68.181.114.133';%% Edited for Hires RTL2 RTLinux box 11/13/14
        %state_machine_properties.server = '10.102.32.36';
      %  state_machine_properties.server = '10.102.30.56';
        state_machine_properties.sm_number = 1 ;

        state_machine_properties.output_routing = {struct('type', 'dout','data', '0-7'); struct('type', 'noop','data', '7')}; % Breakout box ports 1-4, '0-9' changed from '10-19' by JS

        state_machine_properties.input_events = [1 -1]; % Get beam break input from breakout box port 1
       % state_machine_properties.input_events = [1 -1 16 -16]; % Get beam break input from breakout box port 1
       
       %motors_properties.type = '@FakeZaberTCD1000';
        motors_properties.type = '@ZaberAMCB2'; %Edited by AS 6/6/14 for ZaberAMCB2
        motors_properties.port = 'COM6';
        valves_properties.water_valve_time = 0.15;
        valves_properties.airpuff_time = 0;
        valves_properties.airpuff_frac = 0.2; %puff on 20 % of trials

    otherwise
        %Don't have default, in order to prevent breakout box crosstalk errors:
        error('This computer is not approved to control RTLinux box.  Must add to list in mystartup.m.')
end

% for now, rtlinux machines use 200kHz always
% sound_sample_rate = 200000;



% Variable used to determine whether chunks of code should be run
% within try/catch structures. For example, a piece of code that does
% only analysis, and therefore reads variables but sets absolutely no
% variables relevant to further behavior, could be run in this way, so
% that if by any chance it crashes, it doesn't crash the rest of the
% protocol. Typical use might be:
%   if Solo_Try_Catch_flag,
%      try, analysis; catch, warning('analysis failed!'); lasterr; end;
%   else analysis;
%   end;
%
% During deployment, this flag should be set to "1". For debugging, you
% can set it to "0."
%
global Solo_Try_Catch_Flag;
Solo_Try_Catch_Flag = 1;

% Indicate root directory for the code distribution:
global Solo_rootdir;
Solo_rootdir = pwd;


% Indicate root directory for the data:
global Solo_datadir;
Solo_datadir = [pwd filesep '..' filesep 'SoloData'];
if ~exist(Solo_datadir, 'dir'),
    success = mkdir(Solo_datadir);
    if ~success, error(['Couldn''t make directory ' Solo_datadir]); end;
end;

addpath([pwd]);
addpath([pwd filesep 'Analysis']);
addpath([pwd filesep 'Utility']);
addpath([pwd filesep 'SoloUtility']);
addpath([pwd filesep 'Modules']);
addpath([pwd filesep 'Modules' filesep 'NetClient']);
addpath([pwd filesep 'Modules' filesep 'SoundTrigClient']);
addpath([pwd filesep 'Modules' filesep 'TCPClient']);
addpath([pwd filesep 'Protocols']);
addpath([pwd filesep 'soundtools']);
addpath([pwd filesep 'FakeRP']);
addpath([pwd filesep 'HandleParam']);
addpath([pwd filesep 'UiClasses']);
addpath([pwd filesep 'bin']);

% Old Exper-related hack
setpref('carlos', 'control_datapath', [pwd filesep 'data'])

% dbstop if error

% Exper ran mixing lower and upper case function names, something that
% causes a warning in Matlab 7. In addition, exper often assigned
% structure elements to something not yet defined as a structure, which
% also causes a warning (and will cause an error in future Matlab
% releases).
warning('off','MATLAB:dispatcher:InexactMatch');
warning('off','MATLAB:warn_r14_stucture_assignment');

% To start the system off, run these commands after mystartup.m:
%    >> ModuleInit('control'); ModuleInit('rpbox');
%

% % Names of protocols built using protocolobj
% global Super_Protocols;
% Super_Protocols = {'duration_discobj','dual_discobj'};
%
% %

