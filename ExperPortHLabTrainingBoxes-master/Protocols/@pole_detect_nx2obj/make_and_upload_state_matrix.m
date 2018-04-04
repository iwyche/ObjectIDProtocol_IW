function [] = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;


switch action
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'wait_for_startlick', 0, ...  
     'poles_descend_and_sample', 0, ...  
     'wait_for_answerlick', 0, ... 
     'reward',  0, ...
     'extra_iti', 0,...
     'miss',0, ...
     'correct_nogo', 0, ...
     'poles_ascend', 0, ...
     'airpuff',0));
 
   SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');
   
   make_and_upload_state_matrix(obj, 'next_matrix');
   return;
   
 case 'next_matrix',

   % ----------------------------------------------------------------------
   % - Set parameters used in matrix:
   % ----------------------------------------------------------------------
   
   % DHO origianl
%    wvid = 2^0; % water valve
%    LEDid = 2^1; % lickport LED
% %    snd1 = 2^2; % ID of audio noise.
% %    snd2 = 2^3; % ID of low tone.
% %    snd3 = 2^2 + 2^3; % ID of high tone.
%    puffid = 2^4; % Airpuff valve ID.
%    pvid = 2^5; % Pneumatic (Festo) valve ID.
%    cmid = 2^7; % AOS hi speed camera trigger ID. 
%    etid = 2^3; % EPHUS (electrophysiology) trigger ID.
%    slid = 2^2; % Signal line for signaling trial numbers and fiducial marks.

   % Settings S. Peron
    wvid = 2^0; % water valve
    LEDid = 2^1; % lickport LED
    puffid = 2^2; % Airpuff valve ID.
    pvid = 2^3; % Pneumatic (Festo) valve ID.
    etid = 2^4; % EPHUS (electrophysiology) trigger ID.
    slid = 2^5; % Signal line for signaling trial numbers and fiducial marks.
    cmid = 2^7; % AOS hi speed camera trigger ID. 
   
%    % Settings on 2P rig
%   wvid = 2^0;
 %  LEDid = 2^1;
%   secLEDid = 2^11;
%   %    snd1 = 2^2; % ID of audio noise.
%   %    snd2 = 2^3; % ID of low tone.
%   %    snd3 = 2^2 + 2^3; % ID of high tone.
%   puffid = 2^4; % Airpuff valve ID.
%   pvid = 2^6; % Pneumatic (Festo) valve ID.
%   etid = (2^10)+(2^11); % EPHUS trigger ID.
%  slid = 2^2; % Signal line for signaling trial numbers.
   
   wvtm = WaterValveTime; % Defined in ValvesSection.m.  
   
   % Compute answer period time as 2 sec minus SamplingPeriodTime (from TimesSection.m) , 
   % unless SamplingPeriodTime is > 1 s (for training purposes), in which case it is 1 sec.
   % MOVED THIS PART TO TIMESECTION. - NX 4/9/09
      
      
      
   % program starts in state 40
   stm = [0 0  40 0.01  0 0];
   stm = [stm ; zeros(40-rows(stm), 6)];
   stm(36,:) = [35 35  35 1   0 0];
   b = rows(stm); 

   RealTimeStates.wait_for_startlick = b; 
   RealTimeStates.poles_descend_and_sample = b+1;
   RealTimeStates.wait_for_answerlick = b+2;
   RealTimeStates.reward = b+3;
   RealTimeStates.extra_iti = b+5;
   RealTimeStates.miss = b+6;
   RealTimeStates.correct_nogo = b+7;
   RealTimeStates.poles_ascend = b+8;
   RealTimeStates.airpuff = b+9;                             
   
   next_side = SidesSection(obj, 'get_next_side');
   
   % ----------------------------------------------------------------------
   % - Build matrix:
   % ----------------------------------------------------------------------
   switch SessionType % determined by SessionTypeSection
        
      case 'Water-Valve-Calibration'
             % On beam break (eg, by hand), trigger ndrops water deliveries
             % with delay second delays.
             ndrops = 100; delay = 1;
             openvalve = [b+1 b+1 b+2 wvtm wvid 0]; 
             closevalve = [b+1 b+1 b+2 delay 0 0];
             onecycle = [openvalve; closevalve];
             m = repmat(onecycle, ndrops, 1);    
             x = [repmat((0:(2*ndrops-1))',1,3) zeros(2*ndrops,3)];
             m = m+x; m = [b+1 b 35 999 0 0; m];
             m(end,3) = 35; stm = [stm; m];
             
       case 'Licking'
           onlk1 = RealTimeStates.reward(1);
           %Cin Cout Tup  Tim   Dou Aou  (Dou is bitmask format)
           stm = [stm ;
               onlk1   b    35  999    0     0  ; ... % wait for lick  (This is state 40)
               b+1   b+1    35  1      0     0  ; ... % irrelevant
               b+2   b+2    35  1      0     0  ; ... % irrelevant
               b+3   b+3    35  wvtm  wvid   0  ; ... % reward
               ];
           
       case 'Beam-Break-Indicator'
           %Cin    Cout    Tup  Tim  Dou   Aou  (Dou is bitmask format)
           stm = [stm ;
               b+1   b      35  999  0      0  ; ...
               b+1   b      35  999  LEDid  0  ; ...
               ];
           
           %        case 'Discrim'
           %             onlk1 = RealTimeStates.poles_descend_and_sample(1);
           %             if next_side=='r' % Defined as side w/ pole closest to mouse
           %                 onlk2 = RealTimeStates.reward(1);
           %                 tmout = RealTimeStates.miss(1);
           %             else
           %                 onlk2 = RealTimeStates.airpuff(1);
           %                 tmout = RealTimeStates.correct_nogo(1);
           %             end
           %
           %             stm = [stm ;
           %                 b    b     b+1  .5   0   0  ; ... %
           %                 b+1   b+1  b+2 sptm  pvid+cmid 0  ; ... % trigger camera, wait for poles to descend, wait duration of sampling period.
           %                 onlk2 onlk2  tmout aptm   pvid   0  ; ... % wait for lick for aptm seconds.
           %                 b+3   b+3  b+4  wvtm  pvid+wvid 0  ; ... % reward tone + water - HIT
           %                 b+4   b+4  b+8  2-wvtm  pvid 0  ; ... % Give 3 s drinking time.
           %                 b+9   b+5  b+8  eiti  pvid   0 ; ... % incorrect lick, extra ITI - FALSE ALARM
           %                 b+6   b+6  b+8  .001    pvid    0  ; ... % didn't lick before timeout - MISS
           %                 b+7   b+7  b+8  .001    pvid    0  ; ... % correct nogo.
           %                 b+8   b+8  35    .75       0    0  ; ... % raise poles by unsetting pvid, then go state 35 for new trial
           %                 b+9   b+9  b+5  pfdr    pvid+puffid   0 ; ... % FALSE ALARM. Second extra ITI state, to retrigger extra ITI.
           %                 ];
           %
       case 'Pole-conditioning'
           sptm = SamplingPeriodTime;  % Defined in TimesSection.m
           prmv = PoleReractTime; % time for pole to be removed, defined in TimesSection.
           aptm = value(AnswerPeriodTime); % Defined in TimesSection.m
           onlk1 = RealTimeStates.reward(1);
           supp_iti = 2;     % supplementary ITI, if time up for licking
           %Cin     Cout   Tup   Tim   Dou Aou  (Dou is bitmask format)
           stm = [stm ;
               %b   b      35  999       0     0  ; ... % wait for lick  (This is state 40)
               b     b     b+1   sptm    pvid     0  ; ... % whisker sensing state. sptm should be greater than 0.2 for the pole to descend
               b+1   b+1   b+2   prmv    0        0; ...  %  pole remove state.
               onlk1 onlk1 b+5    aptm    0          0  ; ... % remove the pole and wait for lick for aptm seconds
               b+3   b+3   b+4   wvtm    wvid       0  ; ... % reward tone + water - HIT
               b+4   b+4   35    3        0        0;  ... % Drinking time. Animal can drink also in ITI.
               b+5   b+5   35    supp_iti 0        0   ... % supplementary ITI, if time up for licking
              ];

       case 'Discrim'
          
           pfdr = 0.2; % Duration of airpuff.
           eiti = ExtraITIOnError; % Defined in TimesSection.m
           sptm = SamplingPeriodTime;  % Defined in TimesSection.m
           % Water valve delay, after pole retraction
           if ~strcmp(value(WaterValveDelay), 'random')
               wvdl = pole_delay; % Pole delay time
               wvdl = WaterValveDelay; %PoleReractTime; % time for pole to be removed, defined in TimesSection.
           else
               % choose a random number between 0.4 (pole retraction) and
               % 1.5s (normally answering time).
               min_wvdl = 0.1; max_wvdl = 1; %1.5;
               wvdl = min_wvdl + (max_wvdl - min_wvdl)*rand;
           end;
               wvdl;
           rand_pole_delay_pool = [0.5  1  1.5  2];  
           if ~strcmp(value(pole_delay), 'random')
               pdt = pole_delay; % Pole delay time
           else
               pdt_ind = ceil(length(rand_pole_delay_pool)*rand);
               pdt = rand_pole_delay_pool(pdt_ind); % set Pole delay time as a random number between 0.5 and 1.5
           end;
           aptm = value(AnswerPeriodTime); % Defined in TimesSection.m
           
           onlk1 = RealTimeStates.poles_descend_and_sample(1);
           if next_side=='r' % 'r' means a go trial.
               onlk2 = RealTimeStates.reward(1);
               tmout = RealTimeStates.miss(1);
           else
               onlk2 = RealTimeStates.airpuff(1);
               tmout = RealTimeStates.correct_nogo(1);
           end
           
           stm = [stm ;
               %Cin Cout  Tup  Tim   Dou Aou (Dou is bitmask format)
               b     b     101  .1     etid   0  ; ... % trigger camera and EPHUS; 10 ms later jump to state 101 to give trial num bit code.
               b+1   b+1    b+20  pdt    0   0  ; ... % pole delay state
               onlk2 onlk2   tmout aptm  0      0  ; ... % remove the pole and wait for lick for aptm seconds
               b+3   b+3    b+4  wvtm   wvid   0  ; ... % reward tone + water - HIT
               b+4   b+4  35  2+2*wvtm 0      0  ; ... % Drinking time. Animal can drink also in ITI.
               b+9   b+5    35   eiti   0      0 ; ... % incorrect lick, extra ITI - FALSE ALARM
               b+6   b+6    35  .001    0      0  ; ... % didn't lick before timeout - MISS
               b+7   b+7    35  .001    0      0  ; ... % correct nogo.
               b+8   b+8    35  .001    0      0  ; ... % 
               b+9   b+9    b+5  pfdr   puffid 0  ... % FALSE ALARM. Second extra ITI state, to retrigger extra ITI.
              ];
           
           stm = [stm ; zeros(10, 6);
               b+20  b+20  b+21 sptm/2  (pvid+2^6)  0; ... whisker sensing state. sptm should be greater than 0.2 for the pole to descend
               b+21  b+21  b+22 0.01  (pvid+2^6+2^7)  0; ... whisker sensing state. sptm should be greater than 0.2 for the pole to descend
               b+22  b+22  b+23 sptm/2  (pvid+2^6)  0; ...
               b+23  b+23  b+2  wvdl  (2^6)     0  ...  water valve delay
               
               ];
           %pre: b+7: .001 ; b+6, b+8 too ; b+4: 1+2*wvtm
           %------ Signal trial number on digital output given by 'slid':
           % Requires that states 101 through 101+2*numbits be reserved
           % for giving bit signal.
           
           trialnum = n_done_trials + 1;
           
           %             trialnum = 511; %63;
           % Should maybe make following 3 SPHs in State Machine Control
           % GUI:
           bittm = 0.002; % bit time
           gaptm = 0.005; % gap (inter-bit) time
           numbits = 10; %2^10=1024 possible trial nums
           
           
           x = double(dec2binvec(trialnum)');
           if length(x) < numbits
               x = [x; repmat(0, [numbits-length(x) 1])];
           end
           % x is now 10-bit vector giving trial num, LSB first (at top).
           x(x==1) = slid;
           
           % Insert a gap state between bits, to make reading bit pattern clearer:
           x=[x zeros(size(x))]';
           x=reshape(x,numel(x),1);
           
           y = (101:(100+2*numbits))';
           t = repmat([bittm; gaptm],[numbits 1]);
           m = [y y y+1 t x zeros(size(y))];
           m(end,3) = b+1; % jump back to state that triggers pole descent.
           
           stm = [stm; zeros(101-rows(stm),6)];
           stm = [stm; m];
           
           
       case 'Detection'
           pfdr = 0.2; % Duration of airpuff.
           eiti = ExtraITIOnError; % Defined in TimesSection.m
           sptm = SamplingPeriodTime;  % Defined in TimesSection.m
           % Water valve delay, after pole retraction
           if ~strcmp(value(WaterValveDelay), 'random')
               wvdl = pole_delay; % Pole delay time
               wvdl = WaterValveDelay; %PoleReractTime; % time for pole to be removed, defined in TimesSection.
           else
               % choose a random number between 0.4 (pole retraction) and
               % 1.5s (normally answering time).
               min_wvdl = 0.1; max_wvdl = 1; %1.5;
               wvdl = min_wvdl + (max_wvdl - min_wvdl)*rand;
           end;
               wvdl;
           rand_pole_delay_pool = [0.5  1  1.5  2];  
           if ~strcmp(value(pole_delay), 'random')
               pdt = pole_delay; % Pole delay time
           else
               pdt_ind = ceil(length(rand_pole_delay_pool)*rand);
               pdt = rand_pole_delay_pool(pdt_ind); % set Pole delay time as a random number between 0.5 and 1.5
           end;
           aptm = value(AnswerPeriodTime); % Defined in TimesSection.m
           
           onlk1 = RealTimeStates.poles_descend_and_sample(1);
           if next_side=='r' % 'r' means a go trial.
               onlk2 = RealTimeStates.reward(1);
               tmout = RealTimeStates.miss(1);
           else
               onlk2 = RealTimeStates.airpuff(1);
               tmout = RealTimeStates.correct_nogo(1);
           end
           
           stm = [stm ;
               %Cin Cout  Tup  Tim   Dou Aou (Dou is bitmask format)
               b     b     101  .1     etid   0  ; ... % trigger camera and EPHUS; 10 ms later jump to state 101 to give trial num bit code.
               b+1   b+1    b+20  pdt    0   0  ; ... % pole delay state
               onlk2 onlk2   tmout aptm  0      0  ; ... % remove the pole and wait for lick for aptm seconds
               b+3   b+3    b+4  wvtm   wvid   0  ; ... % reward tone + water - HIT
               b+4   b+4  35  2+2*wvtm 0      0  ; ... % Drinking time. Animal can drink also in ITI.
               b+9   b+5    35   eiti   0      0 ; ... % incorrect lick, extra ITI - FALSE ALARM
               b+6   b+6    35  .001    0      0  ; ... % didn't lick before timeout - MISS
               b+7   b+7    35  .001    0      0  ; ... % correct nogo.
               b+8   b+8    35  .001    0      0  ; ... % 
               b+9   b+9    b+5  pfdr   puffid 0  ... % FALSE ALARM. Second extra ITI state, to retrigger extra ITI.
              ];
           
           stm = [stm ; zeros(10, 6);
               b+20  b+20  b+21 sptm  (pvid+2^6)  0; ... whisker sensing state. sptm should be greater than 0.2 for the pole to descend
               b+21  b+21  b+2  wvdl  (2^6)     0  ...  water valve delay
               
               ];
           %pre: b+7: .001 ; b+6, b+8 too ; b+4: 1+2*wvtm
           %------ Signal trial number on digital output given by 'slid':
           % Requires that states 101 through 101+2*numbits be reserved
           % for giving bit signal.
           
           trialnum = n_done_trials + 1;
           
           %             trialnum = 511; %63;
           % Should maybe make following 3 SPHs in State Machine Control
           % GUI:
           bittm = 0.002; % bit time
           gaptm = 0.005; % gap (inter-bit) time
           numbits = 10; %2^10=1024 possible trial nums
           
           
           x = double(dec2binvec(trialnum)');
           if length(x) < numbits
               x = [x; repmat(0, [numbits-length(x) 1])];
           end
           % x is now 10-bit vector giving trial num, LSB first (at top).
           x(x==1) = slid;
           
           % Insert a gap state between bits, to make reading bit pattern clearer:
           x=[x zeros(size(x))]';
           x=reshape(x,numel(x),1);
           
           y = (101:(100+2*numbits))';
           t = repmat([bittm; gaptm],[numbits 1]);
           m = [y y y+1 t x zeros(size(y))];
           m(end,3) = b+1; % jump back to state that triggers pole descent.
           
           stm = [stm; zeros(101-rows(stm),6)];
           stm = [stm; m];
           
           
           
       case 'FlashLED'
           
           timeon = 1;
           timeoff = 1;
           stm = [stm;
               b     b      b+1  timeoff  0      0  ; ...
               b+1   b+1    b    timeon   LEDid  0  ; ...
               ];
           
       otherwise
           error('Invalid training session type')
   end
   
   stm = [stm; zeros(512-rows(stm),6)];
   
   
   rpbox('send_matrix', stm);
   state_matrix.value = stm;
   return;

   
 case 'reinit',
      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise 
      feval(mfilename, obj, 'init');
   
   
 otherwise
   error('Invalid action!!');
   
end;

   