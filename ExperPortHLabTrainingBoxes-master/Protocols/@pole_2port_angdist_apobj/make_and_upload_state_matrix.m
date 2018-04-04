function [] = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;


switch action
 case 'init'
   clear global autosave_session_id;
   SoloParamHandle(obj, 'state_matrix');
   
   SoloParamHandle(obj, 'RealTimeStates', 'value', struct(...
     'bitcode', 0, ...  
     'pretrial_pause', 0, ...  
     'sampling_period', 0, ... 
     'preanswer_pause',  0, ...
     'answer_epoch', 0,...
     'miss',0, ...
     'posttrial_pause', 0, ...
     'punish', 0, ...
     'reward_left', 0, ...
     'reward_right',0, ...
     'second_chance',0, ...
     'reward_cue',0, ...
     'reward_catch_trial', 0, ...
     'reward_collection',0, ...
     'withdraw_lickport_sample',0, ...
     'withdraw_lickport_preans',0, ...
     'present_lickport', 0, ...
     'restart_delay', 0));

   SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');
   SoloFunctionAddVars('MotorsSection', 'ro_args', 'RealTimeStates');   
   
   make_and_upload_state_matrix(obj, 'next_matrix');

   return;
   
 case 'next_matrix',
   % SAVE EVERYTHING before anything else is done!
   %autosave(value(MouseName));
   SavingSection(obj, 'autosave');
   
   % ----------------------------------------------------------------------
   % - Set parameters used in matrix:
   % ----------------------------------------------------------------------
   % Setting Andrew
%    jnk = 2^0
%    jnk =2^1
%    Festo =2^2
%    jnk =2^3
%    jnk =2^4
%    jnk =2^5
%    watervalve=2^6
%    watervalve=2^7
% R = mouse right
% L = mouse left
%    
   % Settings S. Peron
   wvLid = 2^7; % water valve (left) % CHANGE PER BOX!!!!
   ledLid = 2^1; % lickport LED (left)
   wvRid = 2^6; % water valve (right) % CHANGE PER BOX!!!!
   ledRid = 2^0; % lickport LED (right)
   pvid = 2^2; % Pneumatic (Festo) valve ID.
   etid = 2^4; % EPHUS (electrophysiology) trigger ID.
   slid = 2^5; % Signal line for signaling trial numbers and fiducial marks.
   rcid = 2^3; % Reward cue ID (sound)
   
   puffid = 0; % Airpuff valve ID. DISABLED
   
   rwvtm = RWaterValveTime; % Defined in ValvesSection.m.  
   lwvtm = LWaterValveTime; % Defined in ValvesSection.m.  
   
   % Compute answer period time as 2 sec minus SamplingPeriodTime (from TimesSection.m) , 
   % unless SamplingPeriodTime is > 1 s (for training purposes), in which case it is 1 sec.
   % MOVED THIS PART TO TIMESECTION. - NX 4/9/09
      
       
      
   % program starts in state 40 (41st row)
   stm = [0 0 0 0 40 0.01  0 0];
   stm = [stm ; zeros(40-rows(stm), 8)];
   stm(36,:) = [35 35 35 35 35 1   0 0];
   b = rows(stm); % b = 40
   
% Alexis 9-3-14 MUST BE RENAMED BASED ON 2-PORT DISCRIM TO MAKE SURE HITS
% AND INCORRECTS ARE MONITORED (refer to assignment of state times in
% parse_trial in RewardsSection in state35 in state RPbox via the send
% matrix line in this m-file--> this is done in the pstruct variable
% struct). 
%
% Assigned unused states names with unused state numbers (DO NOT ASSIGN <--
% fills in areas of the pstruct that we do not currently want filled
   RealTimeStates.bitcode = b; 
   RealTimeStates.pretrial_pause = b+1;
   RealTimeStates.sampling_period = b+2;
   RealTimeStates.preanswer_pause = b+3;
   RealTimeStates.answer_epoch = b+12;%4;
   RealTimeStates.miss = b+4;%5;
   RealTimeStates.posttrial_pause = b+5;%6;
   RealTimeStates.punish = b+6;%7;
   RealTimeStates.reward_left = b+7;%8;
   RealTimeStates.reward_right = b+8;%9;     
   RealTimeStates.second_chance = b+13;%10; % if RewardOnWrong
   RealTimeStates.reward_cue = b+14;%11;
   RealTimeStates.reward_catch_trial = b+9;%12;
   RealTimeStates.reward_collection = b+10;%13;
   RealTimeStates.withdraw_lickport_sample = b+15;%14;
   RealTimeStates.withdraw_lickport_preans = b+16;%15;
   RealTimeStates.present_lickport = b+17;%16;
   RealTimeStates.restart_delay = b+11;%17;   
   
   next_side = SidesSection(obj, 'get_next_side');
   
   % ----------------------------------------------------------------------
   % - Build matrix:
   % ----------------------------------------------------------------------
   switch SessionType % determined by SessionTypeSection
        
      case 'LWater-Valve-Calibration'
             % On beam break (eg, by hand), trigger ndrops water deliveries
             % with delay second delays.
             ndrops = 100; delay = 0.5;
             openLvalve = [b+1 b+1 b+1 b+1 b+2 lwvtm wvLid 0]; 
             closeLvalve = [b+1 b+1 b+1 b+1 b+2 delay 0 0];
             oneLcycle = [openLvalve; closeLvalve];
             m = repmat(oneLcycle, ndrops, 1);    
             x = [repmat((0:(2*ndrops-1))',1,5) zeros(2*ndrops,3)];
             m = m+x; m = [b+1 b b+1 b 35 999 0 0; m];
             m(end,5) = 35; stm = [stm; m];
       
       case 'RWater-Valve-Calibration'
             % On beam break (eg, by hand), trigger ndrops water deliveries
             % with delay second delays.
             ndrops = 100; delay = 0.5;
             openRvalve = [b+1 b+1 b+1 b+1 b+2 rwvtm wvRid 0]; 
             closeRvalve = [b+1 b+1 b+1 b+1 b+2 delay 0 0];
             oneRcycle = [openRvalve; closeRvalve];
             m = repmat(oneRcycle, ndrops, 1);    
             x = [repmat((0:(2*ndrops-1))',1,5) zeros(2*ndrops,3)];
             m = m+x; m = [b+1 b b+1 b 35 999 0 0; m];
             m(end,5) = 35; stm = [stm; m];
             
       case 'Licking'
           %Lin     Lout  Rin Rout   Tup  Tim  Dou Aou  (Dou is bitmask format)
%            stm = [stm ;
%                b+1   b    b+2  b     35  999    0     0  ; ... % wait for lick  (This is state 40)
%                b+1   b+1  b+1  b+1   35  lwvtm  wvLid     0  ; ... % licked left -- reward left
%                b+2   b+2  b+2  b+2   35  rwvtm  wvRid   0  ; ... % licked right -- reward right
%                ];
          stm = [stm ;
               b   b    b+1  b     35  999    0     0  ; ... % wait for lick  (This is state 40)
%  we only use right lick port for licking protocol.
               b+1   b+1  b+1  b+1   35  rwvtm  wvRid   0  ; ... % licked right -- reward right
               ];

           
       case 'Beam-Break-Indicator'
           stm = [stm ;
               b+1   b  b+2 b    35  999  0      0  ; ...
               b+1   b  b+1 b    35  999  ledLid  0  ; ...
               b+2   b  b+2 b    35  999  ledRid  0  ; ...
               ];
           

        % 2 port task
        case '2port-Discrim' 
            
           % ---- labeling of states
           sBC = b; % bitcode
           sPrTP = b+1; % pretrial pause
           sPMS = b+2; % pole move & sample period
           sPrAP = b+3; % preanswer pause
           sLoMi = b+4; % log miss/ignore
           sPoTP = b+5; % posttrial pause
           sPun = b+6; % punish (be it airpuff, timeout, or whatev)  
           sRwL = b+7; % reward left
           sRwR = b+8; % reward right
           sRCaT = b+9;%12; % to log unrewarded correct trals (catch)
           sRCol = b+10;%13; % give animal time to collect reward         
           sRDel = b+11;%17 ; % restart delay         
           
           % ---- assign gui variables
           ap_t = value(AnswerPeriodTime);
           sp_t = SamplingPeriodTime;
           eto_t = max(.01,ExtraITIOnError);
           pr_t = PoleRetractTime;
           pa_t = PreAnswerTime;
           prep_t = PreTrialPauseTime;
           postp_t = PostTrialPauseTime;
           rc_t = RewardCueTime;
           rcoll_t = RewardCollectTime;
           lpt_t = LickportTravelTime;
           
%            puff_t = AirpuffTime;
           
           wdraw_t = 0.3; % how long to stay in withdraw state and allow its detection
           
           % Check for (min,max) PreAnswerTime
%            if (~isnumeric(pa_t)) % assume format is correct!
%               comIdx = find(pa_t == ',');
%               if (length(comIdx) > 0)
%                   minValuePAT = str2num(pa_t(2:comIdx-1));
%                   maxValuePAT = str2num(pa_t(comIdx+1:end-1));
%                   pa_t = minValuePAT + ((maxValuePAT-minValuePAT)*rand(1));
%               else 
%                   disp('Bad format ; settig PreAnswerTime to 0');
%                   pa_t= 0;
%               end
%            end 
% 02/17/16 JK Don't use min,max format for pa_t
              
           % puff disabled? can't have 0 time or RT freaks; set valve id
           % off instead
%            if (puff_t == 0)
%                puff_t = 0.01;
%                puffid = 0;
%            else
%                disp('*** At this time, airpuff is disabled. ***');
%            end
% 02/17/16 JK Not using air puff
            
           % Reward cue disabled? turn off valve, but must be at least
           % minimal time long
           if (rc_t == 0)
               rc_t = 0.01;
               rcid = 0;
           end
           
           % Adjust prepause based on bitcode, initial trigger
           prep_t = prep_t - 0.01 - 0.077; % 2 ms bit, 5 ms interbit, 11 bits = 77 ms = .077 s

                % Alexis 9-2-14 DECLARE A WRONG
                pps = sPoTP; % post-punish state default is post trial pause

           onLickS = sPMS;

           % Adjust extra time out based on airpuf time
%            eto_t = eto_t - puff_t; % JK 01/29/16 We are not having air puff aren't we?
%            eto_t = max(eto_t,.01);

           if next_side=='r' % 'r' means right trial.
               onlickL = sPun; % incorrect
               onlickR = sRwR; % correct
               water_t = RWaterValveTime; % Defined in ValvesSection.m.  
           else %left 
               onlickR = sPun; % punish
               onlickL = sRwL; % water to left port
               water_t = LWaterValveTime; % Defined in ValvesSection.m.  
           end  
           
           % Disable reward?  If so, do it by setting wv
           pas = sPoTP;
           if (FracNoReward > 0)
               rvReward = rand;
               if (rvReward < FracNoReward)
                   disp('Random cancellation of reward.')
                   wvLid = 0;
                   wvRid = 0;
                   pas = sRCaT;
               end
           end
               
           stm = [stm ;
               %LinSt   LoutSt   RinSt    RoutSt   TimeupSt Time      Dou      Aou  (Dou is bitmask format)
               % line b (sBC = b = 40 @ 41st row of the final stm)
               sBC      sBC      sBC      sBC      101      .01       etid       0; ... % sBC: bitcode
               sPrTP    sPrTP    sPrTP    sPrTP    sPMS     prep_t    0          0; ... % sPrPT: pretrial pause
               onLickS  onLickS  onLickS  onLickS  sPrAP    pr_t+sp_t pvid       0; ... % sPMS: pole move & sample period % onLickS = sPMS @ line 235
               onlickL  onlickL  onlickR  onlickR  sLoMi    ap_t      pvid       0; ... % sPrAP: preanswer pause
               sLoMi    sLoMi    sLoMi    sLoMi    sPoTP    0.001     0          0; ... % sLoMi: log miss/ignore
               sPoTP    sPoTP    sPoTP    sPoTP    201      postp_t   0          0; ... % sPoTP: posttrial pause; 201 is for turning the pole 90 again after each trial.
               sRDel    sPun     sRDel    sPun     pps      eto_t     pvid       0; ... % sPun: punish & pps = sPoTP @ line 203
               sRwL     sRwL     sRwL     sRwL     sRCol    water_t   pvid+wvLid 0; ... % sRwL: reward left
               sRwR     sRwR     sRwR     sRwR     sRCol    water_t   pvid+wvRid 0; ... % sRwR: reward right                      
               sRCaT    sRCaT    sRCaT    sRCaT    sPoTP    0.001     pvid       0; ... % sRCaT: to log unrewarded correct trials              
               sRCol    sRCol    sRCol    sRCol    sPoTP    rcoll_t   pvid       0; ... % sRCol: give animal time to collect reward              
               sRDel    sRDel    sRDel    sRDel    sPun     0.001     pvid       0; ... % sRDel: restart delay              
               ];
    
           %------ Signal trial number on digital output given by 'slid':
           % Requires that states 101 through 101+2*numbits be reserved
           % for giving bit signal.
           
           trialnum = n_done_trials + 1;
           
           bittm = 0.002; % bit time
           gaptm = 0.005; % gap (inter-bit) time
           numbits = 11; %2^10=1024 possible trial nums
           % + 1 bit for arrival indication 02/22/16 JK for scanbox

           
%            x = double(dec2binvec(trialnum)');
           x = double(dec2binvec(trialnum * 2 + 1)');
           % + 1 before LSB to signal when the code has been sent %
           % 02/22/16 JK for scanbox 

           if length(x) < numbits
               x = [x; repmat(0, [numbits-length(x) 1])];
           end
           % x is now 10-bit vector giving trial num, LSB first (at top).
           % + 1 before LSB to signal when the code has been sent %
           % 02/22/16 JK for scanbox 
           x(x==1) = slid;
           
           % Insert a gap state between bits, to make reading bit pattern clearer:
           x=[x zeros(size(x))]';
           x=reshape(x,numel(x),1);
           
           y = (101:(100+2*numbits))';
           t = repmat([bittm; gaptm],[numbits 1]);
           m = [y y y y y+1 t x zeros(size(y))];
           m(end,5) = 151; % jump to arduino angle defining bitcodes
           
           stm = [stm; zeros(101-rows(stm),8)];
           stm = [stm; m]; % m starts at 102nd row of the final stm (sending bitcode)
           
           % Move the pole with the target angle before pole up
           R_bittm = 0.02;
           R_gaptm = 0.02;
          
           
           R_numbits = 8; 
           R_x = double([1,dec2binvec(double(next_absolute_angle),R_numbits)]');   
           next_absolute_angle
           R_x(R_x==1) = rcid;
           R_x = [R_x zeros(size(R_x))]';
           R_x = reshape(R_x,numel(R_x),1);
           R_y = (151:(150+2*(R_numbits+1)))';
           R_t = repmat([R_bittm; R_gaptm],[R_numbits+1 1]);
           R_m = [R_y R_y R_y R_y R_y+1 R_t R_x zeros(size(R_y))];
           R_m(end,5) = sPrTP; % jump back to PREPAUSE.
           stm = [stm; zeros(151-rows(stm),8)];
           stm = [stm; R_m];
           

           % Move the pole down and turn it to 90 
                      
           R_numbits = 8; 
           R_x = double([1,dec2binvec(double(90),R_numbits)]');   
           R_x(R_x==1) = rcid;
           R_x = [R_x zeros(size(R_x))]';
           R_x = reshape(R_x,numel(R_x),1);
           R_y = (201:(200+2*(R_numbits+1)))';
           R_t = repmat([R_bittm; R_gaptm],[R_numbits+1 1]);
           R_m = [R_y R_y R_y R_y R_y+1 R_t R_x zeros(size(R_y))];
           R_m(end,5) = 35; % jump to state 35.
           stm = [stm; zeros(201-rows(stm),8)];
           stm = [stm; R_m];
          
                    
       otherwise
           error('Invalid training session type')
   end
   
   stm = [stm; zeros(512-rows(stm),8)];
   
   
   rpbox('send_matrix', stm);
   state_matrix.value = stm;
   

   
%    %for test 02/23/16 JK
           if exist('trialnum')
% %                temp_stm_name = strcat('stm','_',num2str(trialnum));
% %                eval([temp_stm_name, '= stm;'])
% %                if exist('test_sm.mat')
% %                    eval(['save ''test_sm.mat'' ', temp_stm_name, ' -append'])
% %                else
% %                    eval(['save ''test_sm.mat'' ', temp_stm_name])
% %                end
% %                disp('saving stm')
% %            end
%            
%           % send the trial number to scanbox as a message
           trialnumstr = strcat('M',int2str(trialnum));
           judp('SEND', 7000, '68.181.112.192', [int8(trialnumstr) 10])
           end

   
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

   