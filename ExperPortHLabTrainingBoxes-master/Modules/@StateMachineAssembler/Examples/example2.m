% This is an example script showing how to use the @StateMachineAssembler
% object. It is a reasonably complex example, and illustrates our "no dead
% time technology" (i.e., keeping the real time machine responsive to the
% rat in between trials). This example uses most of what is necessary for
% doing things in separate trials (e.g., state35 is used to indicate end
% of a trial), and it also illustrates using scheduled waves.
%
% The script is intended to be self-contained-- after starting up the
% system, you run the script and it will set up a state machine and start
% running it and communicating with it. (ExperPort/mystartup.m must
% have been run for this script to execute properly, though.)
%
% The simple example protocol used here plays a tone upon poking in the
% center; and then rewards a Left response by lighting an LED, and
% punishes a Right response with 2 secs of white noise. Then there is
% an intertrial interval which is at least 2 more secs of white
% noise. If the animal pokes during the ITI, the 2 secs of white noise
% are reinitialised.
%
% Written by Carlos Brody Oct 2006



% -- REMEMBER TO RUN ExperPort/mystartup.m before running this script!
% mystartup.m holds all the stuff that defines the state_machine_server
% name, etc.

% The following three lines are just to clear and close stuff in case
% you ran this script previously.
if exist('sm'),   Close(sm); clear sm; end;
if exist('sma'),  clear sma;  end;
if exist('sndm'), clear sndm; end;

% These two variables acquire their proper values in
% ExperPort/mystartup.m; if empty, it means we're on a virtual rig, not a
% real one:
global sound_machine_server;   
global state_machine_server;   


% Now set up the State Machine:
if isempty(state_machine_server); sm = SoftSMMarkII;
else                              sm = RTLSM(state_machine_server);   
end;
sm = Initialize(sm);


% Set up the sound machine:
if isempty(sound_machine_server)  
   sndm = softsound;
   % The virtual rig state machine needs to be told to talk to sound machine:
   sm   = SetTrigoutCallback(sm, @playsound, sndm);   
else                             
   sndm = RTLSoundMachine(sound_machine_server);
end;

% Make sound 1 a two second white noise sound; sound 2 a 1-sec 2 KHz tone
sndm = LoadSound(sndm, 1, 0.3*rand(1, 2*GetSampleRate(sndm)));
sndm = LoadSound(sndm, 2, 0.3*sin(2*pi*2000*(0:1/GetSampleRate(sndm):1)));


% Now we start up an assembler object. When we start it up with the
% 'no_dead_time_technology' flag, as below, it means that all the states
% designated 'iti_state' (see ITI SECTION below) will be running *in
% between trials*. This is so the real-time machine can be responsive to
% the rat even while other processes (i.e., the Matlab process) are
% pausing to figure out what they want for the next trial. The default is
% not to do anything in the iti-- that is, if you use the
% 'no_dead_time_technology' flag, but don't write an ITI SECTION, that's
% totally fine, there is well-defined behavior, but the box will not be
% responsive to anything the rat does in between trials. Your choice; if
% you want responsiveness in the iti, define what you want in an iti
% section.
%
%    If you do write an iti section, then once you set it up at the start
% of an experiment, do not change that iti_state part of the program as
% you switch from trial to trial. This is because iti part will be in the
% middle of running when you load the next state machine program. If it
% changes in the middle of running, who knows what could happen! In
% contrast, of course, the main section often changes from trial to
% trial.
%
% Ok. Enough discussion. Let's open up an assembler:
sma  = StateMachineAssembler('no_dead_time_technology');


% ---------------------- MAIN PROGRAMMING SECTION --------
%
%   This is main section, where you define what you want to happen in a
%   trial.
%

% At the very beginning, we'll just wait for a center poke. We'll give
% this state the name 'wait_for_cpoke' (names are arbitrary; anything that
% could be a variable name is ok). Note that state names are *in*sensitive
% to case. We also specify that when a "Cin" event occurs, we'll go to the
% state called "trigger_tone":
sma = add_state(sma, 'name', 'WAIT_FOR_CPOKE', ...
                'input_to_statechange', {'Cin', 'trigger_tone'});
% Next, we'll fly through the trigger_tone state in 1 ms, just using it to
% trigger Sound #2. We'll then immediately go to wait_for_answer. (Below,
% making the default_statechange be "go to wait_for_answer" means that
% *any* input event, unless we had otherwise specified it in
% input_to_statechange, will cause a jump to wait_for_answer.)
sma = add_state(sma, 'name', 'TRIGGER_TONE', ...
                'default_statechange', 'wait_for_answer', ...
                'self_timer', 0.001, ...
                'output_actions', {'SoundOut', 2});

% Note: the "self_timer" is a timer that gets started every time that you
% enter a state from a different state. When this timer runs out, a 'Tup'
% input event is generated. The default length of time for the self_timer
% is 100 secs; above we specified a different value, 1 msec, for this
% state. 

% In the wait_for_answer state, we're just waiting for the rat's
% response. If Left in, we'll go to reward, if Right in, we'll go to
% penalty. The default for other input events is just to stay in the
% current state, so anything else just gets ignored.
sma = add_state(sma, 'name', 'WAIT_FOR_ANSWER', ...
                'input_to_statechange', { ...
                  'Lin', 'left_reward' ; ...
                  'Rin', 'penalty' ; ...
                   });

% In left_reward we'll shine the left LED for 300 ms, and then go to the
% next state (left_reward+1)-- notice how you can do simple arithmetic
% when specifying which state you want to go to. States are added in
% sequence, so left_reward+1 will correspond to the "add_state" command
% after this one:
sma = add_state(sma, 'name', 'LEFT_REWARD', ...
                'output_actions', {'DOut', left1led}, ...
                'self_timer', 0.3, ...
                'input_to_statechange', {'Tup', 'left_reward+1'});
% This next one is the left_reward+1 state. Here we're just going to wait
% for 2 secs, ignoring everything in peaceful silence, before going to iti.
sma = add_state(sma, 'self_timer', 2, ...
                'input_to_statechange', {'Tup' 'iti_start'});


% In this penalty state, we trigger the 2-sec long white noise, we wait
% for two secs, and then we go to the iti. We could use the self_timer
% to wait for two secs. But instead we'll use a scheduled wave, just to
% illustrate using one.
%
% First we declare the scheduled wave with a two second preamble:
sma = add_scheduled_wave(sma, 'name', 'twosec_wave', 'preamble', 2);
%
% Now we add starting the wave to the output actions to be performed on
% entering this state; and in the input_to_statechange list, we specify
% that when this wave goes ping!, we should go to iti_start.
sma = add_state(sma, 'name', 'PENALTY', ...
                'output_actions', {...
                  'SoundOut',      1              ; ...
                  'SchedWaveTrig', 'twosec_wave'  ; ...
                   }, ...
                'input_to_statechange', {'twosec_wave_In', 'iti_start'});


% Note: When you declare a wave with name "blah", the end of the
% preamble will cause a "blah_In" event. The end of the sustain will
% cause a "blah_Out" event. (See @RTLSM/SetScheduledWaves.m for an
% explanation of scheduled waves, and their preamble.)


% ---------------------- ITI SECTION --------
%
%

% This is the section that will be running in between trials. Each trial
% ends by going to State 35. When the Matlab process monitoring the state
% machine detects that a State 35 has occurred in the last set of events
% it is picking up, it uses that as a cue to start figuring out what to do
% for the next trial (e.g., write a different code for "Main Section"
% above, perhaps now something where Rin leads to a hit and Lin leads to
% penalty; whatever you want). The Matlab process then sends the new code
% to the state machine (using send.m as below), and then calls
% ReadyToStartTrial.m. Meanwhile, the real-time machine should be set up
% to be periodically going to state 35. Every time it hits state 35, it
% asks whether it has received the ReadyToStartTrial signal. If it has,
% it'll then jump to the first state of the Main Section above;
% otherwise it goes again to the first state of the ITI section.
%
% In the current simplified example, all trials are the same; so below
% we will constantly say "we're ready to start the next trial," since
% no new sounds or state machines need to be loaded.
%
%
% Note that all of the add_state commands in this section need to have
% "'iti_state', 1"-- this is what tells the assembler that these are for
% the intertrial interval states, not the regular during-a-trial states.


% Start by making sure sounds 1 and 2 are off:
sma = add_state(sma, 'iti_state', 1, ...
                'name', 'ITI_START', 'self_timer', 0.001, ...
                'output_actions', {'SoundOut', -1}, ...
                'default_statechange', 'iti_start+1');
sma = add_state(sma, 'iti_state', 1, ...
                'self_timer', 0.001, ...
                'output_actions', {'SoundOut', -2}, ...
                'default_statechange', 'trigger_iti_sound');

% Now trigger sound 1; 
sma = add_state(sma, 'iti_state', 1, ...
                'name', 'TRIGGER_ITI_SOUND', 'self_timer', 0.001, ...
                'output_actions', {'SoundOut', 1}, ...
                'default_statechange', 'trigger_iti_sound+1');
% Now, if nothing happens, go to state 35. But if anything (any input)
% does happen, go back to turning sounds off and restarting iti. This
% penalizes poking during the white noise sound.
sma = add_state(sma, 'iti_state', 1, ...
                'self_timer', 1.999, ...
                'input_to_statechange', {'Tup', 'state35'}, ...
                'default_statechange', 'iti_start');



%
%
% ----------------- NOW ASSEMBLE, SEND, AND RUN!  ---------
%
%


% Tell the assembler (sma) to assemble and send the program to the
% state machine (sm):
send(sma, sm);

% Ok! Start it up, and start at state 0 --standard intialization calls.
sm = Run(sm); sm = ForceState0(sm);

% Run for 100 secs or so. 
for i=1:1000, 
   % Virtual state machine needs to periodically process its stuff:
   if isa(sm, 'SoftSMMarkII'), sm = FlushQueue(sm); end;
   % Here we'll choose to constantly be ready for the next trial:
   sm = ReadyToStartTrial(sm); 
   pause(0.1); 
end;
% We're done!
sm = Halt(sm);

