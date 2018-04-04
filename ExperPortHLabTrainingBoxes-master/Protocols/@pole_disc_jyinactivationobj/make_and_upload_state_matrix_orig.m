function [] = make_and_upload_state_matrix(obj, action)

GetSoloFunctionArgs;

global state_machine_properties
machine = state_machine_properties.sm; % RTLSM constructor is called in InvokeWrapper.m

pathstr = fileparts(mfilename('fullpath'));
embCPath = [pathstr filesep 'embc' filesep];

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
            'airpuff',0,...
            'no_feedback_lick',0,...
            'no_feedback_nolick',0));

        SoloFunctionAddVars('RewardsSection', 'ro_args', 'RealTimeStates');


        make_and_upload_state_matrix(obj, 'next_matrix');
        return;

    case 'next_matrix',

        display ('doing this again')

        next_trial_type = TrialTypeSection(obj, 'get_next_trial_type'); % The upcoming trial type.

        if isempty(strfind(next_trial_type,'Stim'))
            stim_trial = false;
        else
            stim_trial = true;
        end



        % All the followings are for the real-time stuff, comment them out
        %
        %         if ismember(next_trial_type,{'Go','Nogo'})
        %             stim_delay_in_ms = 0;   % Dummy; for 'Go','Nogo', this doesn't matter since no stim is given anyway
        %         elseif ~isempty(strfind(next_trial_type,'Stim_0ms'))
        %             stim_delay_in_ms = 0;
        %         elseif ~isempty(strfind(next_trial_type,'Stim_5ms'))
        %             stim_delay_in_ms = 5;
        %         elseif ~isempty(strfind(next_trial_type,'Stim_10ms'))
        %             stim_delay_in_ms = 10;
        %         elseif ~isempty(strfind(next_trial_type,'Stim_20ms'))
        %             stim_delay_in_ms = 20;
        %         elseif ~isempty(strfind(next_trial_type,'Stim_50ms'))
        %             stim_delay_in_ms = 50;
        %         else
        %             error('Unrecognized trial type.')
        %         end
        %
        %         if ismember(next_trial_type,{'Go','Nogo'})
        %                 stim_dur_in_ms = 1;  % Dummy; for 'Go','Nogo', this doesn't matter since no stim is given anyway
        %         elseif ~isempty(strfind(next_trial_type,'1_1ms'))  % Single 1 ms pulse
        %                 stim_dur_in_ms = 1;
        %         elseif ~isempty(strfind(next_trial_type,'1_1.33ms')) % Single 1.33 ms pulse
        %                 stim_dur_in_ms = 1.33;
        %         elseif ~isempty(strfind(next_trial_type,'5@40Hz_1ms')) % 5 pulses at 40 Hz, 1 ms each
        %                 stim_dur_in_ms = 125 + 1;
        %         elseif ~isempty(strfind(next_trial_type,'10@40Hz_1ms')) % 10 pulses at 40 Hz, 1 ms each
        %                 stim_dur_in_ms = 250 + 1;
        %         elseif ~isempty(strfind(next_trial_type,'1@40Hz_1.33ms')) % Single 1.33 ms pulse
        %                 stim_dur_in_ms = 1.33;
        %         elseif ~isempty(strfind(next_trial_type,'2@40Hz_1.33ms')) % Two 1.33 ms pulses at 40 Hz
        %                 stim_dur_in_ms = 25 + 1.33;
        %         elseif ~isempty(strfind(next_trial_type,'3@40Hz_1.33ms')) % Three 1.33 ms pulses at 40 Hz
        %                 stim_dur_in_ms = 50 + 1.33;
        %         elseif ~isempty(strfind(next_trial_type,'1@40Hz_2ms')) % Single 2 ms pulse
        %                 stim_dur_in_ms = 2;
        %         elseif ~isempty(strfind(next_trial_type,'2@40Hz_2ms')) % Two 2 ms pulses at 40 Hz
        %                 stim_dur_in_ms = 25 + 2;
        %         elseif ~isempty(strfind(next_trial_type,'3@40Hz_2ms')) % Three 2 ms pulses at 40 Hz
        %                 stim_dur_in_ms = 50 + 2;
        %         else
        %             error('Unrecognized trial type.')
        %         end

        % pulse_width_in_ms=5; % defined in stupLaserParameters;

        %         % MenuParam(obj, 'StimType', {'constant','5ms_pulse_20Hz','5ms_pulse_50Hz', '5ms_grid', 's1', 'grid_and_s1'}, ...
        %             '5ms_pulse_50Hz', x, y);

        galvo=0;
       
        switch next_trial_type
            case {'Go','Nogo'}
                stim_dur_in_ms = 1;  % Dummy; for 'Go','Nogo', this doesn't matter since no stim is given anyway
                stim_freq=0;
                dur=Stimduration;
                ramp=Ramp;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_5ms_pulse', 'NogoStim_5ms_pulse'}  %
                stim_freq=Stimfreq;
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;
            case {'GoStim_constant', 'NogoStim_constant'}
                if Stimfreq>10
                    stim_freq=0;
                else
                    stim_freq=Stimfreq;
                end;
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;
            case {'GoStim_5ms_grid', 'NogoStim_5ms_grid'}
                galvo=1;
                [x, y]=derivegalvo('grid');
                stim_freq=20*5; % 100 hz laser pulases, distributed over 5 nodes in a grid
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;
            case {'GoStim_shift', 'NogoStim_shift'}
                galvo=1;
                [x, y]=derivegalvo('shift', xshiftvar, yshiftvar);
                stim_freq=Stimfreq;
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_constant_shift', 'NogoStim_constant_shift'}
                galvo=1;
                [x, y]=derivegalvo('shift', xshiftvar, yshiftvar);
                stim_freq=0;
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_grid_and_s1', 'NogoStim_grid_and_s1'}
                galvo=1;
                [x, y]=derivegalvo('grid_and_s1', xshiftvar, yshiftvar);
                stim_freq=120;
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_shiftgrid', 'NogoStim_shiftgrid'}
                galvo=1;
                [x, y]=derivegalvo('shiftgrid', xshiftvar, yshiftvar);
                stim_freq=20*5; % 100 hz laser pulases, distributed over 5 nodes in a grid
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_depblock', 'NogoStim_depblock'}
                galvo=1;
                [x, y]=derivegalvo('depblock', xshiftvar, yshiftvar);
                stim_freq=Stimfreq; % 100 hz laser pulases, distributed over 5 nodes in a grid
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            case {'GoStim_collision', 'NogoStim_collision'}
                galvo=1;
                [x, y]=derivegalvo('collision', xshiftvar, yshiftvar);
                stim_freq=Stimfreq; % 100 hz laser pulases, distributed over 5 nodes in a grid
                ramp=Ramp;
                dur=Stimduration;
                onsetjitt=OnsetJitt;
                testfreq=Testfreq;
                Normfactor=CondNorm;
                if rand>.5
                    Normfactor=1;
                end;
                onsetrand=OnsetRand;

            otherwise
                error('Bummer!')
        end;

        setupLaserParameters;

        if onsetjitt==0
            onsetjitt=0;
        else
            if onsetrand==1
                onsetjitt=[0 onsetjitt];
                iperm=randperm(2);
                onsetjitt=onsetjitt(iperm(1));
            else
                onsetjitt=onsetjitt;
            end;
        end;

        % ----------------------------------------------------------------------
        % - Set parameters used in matrix:
        % ----------------------------------------------------------------------
        wvid = 2^6;
        LEDid = 2^1;

        puffid = 2^4; % Airpuff valve ID.
        pvid = 2^2; % Pneumatic (Festo) valve ID.
        cmid = 2^7; % AOS hi speed camera trigger ID.
        etid = 2^3; % EPHUS (electrophysiology) trigger ID.
        slid = 2^5; % Signal line for signaling trial numbers and fiducial marks.

        wvtm = WaterValveTime; % Defined in ValvesSection.m.
        pfdr = 0.2; % Duration of airpuff.
        eiti = ExtraITIOnError; % Defined in TimesSection.m.
        sptm = SamplingPeriodTime;  % Defined in TimesSection.m.

        % Compute answer period time as 2 sec minus SamplingPeriodTime (from TimesSection.m) ,
        % unless SamplingPeriodTime is > 1 s (for training purposes), in which case it is 1 sec.
        if value(SamplingPeriodTime)>1
            aptm = 1;
        else
            aptm = 2 - value(SamplingPeriodTime);
        end
        SoloParamHandle(obj, 'AnswerPeriodTime', 'value', aptm);

        % program starts in state 40
        stm = [0 0 0 0 0 0 40 0.01  0 0];
        stm = [stm ; zeros(40-rows(stm), 10)];
        stm(36,:) = [35 35 35 35 35 35 35 1   0 0];
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

        % ----------------------------------------------------------------------
        % - Build matrix:
        % ----------------------------------------------------------------------
        % Will use second pair of input channel columns to allow reading in whisker
        % position using EmbC readAI() function and also for recording scheduled
        % wave events.  Second channel will not allow built-in input event detection
        % because it will be disabled through use of a custom EmbC threshfunc.


        switch SessionTypeSection(obj,'get_session_type')

            case 'Water-Valve-Calibration'
                % On beam break (eg, by hand), trigger ndrops water deliveries
                % with delay second delays.
                ndrops = 100; delay = 1;
                openvalve = [b+1 b+1 b+1 b+1 b+1 b+1 b+2 wvtm wvid 0];
                closevalve = [b+1 b+1 b+1 b+1 b+1 b+1 b+2 delay 0 0];
                onecycle = [openvalve; closevalve];
                m = repmat(onecycle, ndrops, 1);
                x = [repmat((0:(2*ndrops-1))',1,7) zeros(2*ndrops,3)];
                m = m+x; m = [b+1 b b b b b 35 999 0 0; m];
                m(end,7) = 35; stm = [stm; m];
                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;
                SetStateMatrix(machine,stm,1);

            case 'Licking'
                onlk1 = RealTimeStates.reward(1);
                    %Cin Cout Tup  Tim   Dou Aou  (Dou is bitmask format)
                stm = [stm ;
                    onlk1   b  b    b    b     b     35  999    0     0  ; ... % wait for lick  (This is state 40)
                    b+1   b+1  b+1  b+1  b+1   b+1   35  1      0     0  ; ... % irrelevant
                    b+2   b+2  b+2  b+2  b+2   b+2   35  1      0     0  ; ... % irrelevant
                    b+3   b+3  b+3  b+3  b+3   b+3    35  wvtm  wvid   0  ; ... % reward
                    ];
                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;
                stm
                SetStateMatrix(machine,stm,1);

            case 'LaserTest'

                setupScheduledWaves;

                %                 stim_delay_in_task_periods = stim_delay_in_ms*task_periods_per_ms; % task_periods_per_ms defined in setupScheduledWaves
                %                 stim_dur_in_task_periods = ceil(stim_dur_in_ms*task_periods_per_ms); % Can't have fractional task periods.
                %
                %
                % sw = 2^wave_id_masking_flash_blue + 2^wave_id_aom_473 + 2^wave_id_x_galvo + 2^wave_id_y_galvo ...
                %     + 2^wave_id_shutter; % IDs defined in setupScheduledWaves.m

                sw = 2^wave_id_aom_473 + 2^wave_id_x_galvo + 2^wave_id_y_galvo ...
                    + 2^wave_id_shutter; % IDs defined in setupScheduledWaves.m



                texplore=4;
                tpost=.1;

                stm = [stm ;
                    b     b      b    b    b     b     101  .01   cmid+etid  0   ; ... % trigger camera gate sched wave and EPHUS; 10 ms later jump to state 101 to start triggering camera frames and give trial num bit code.
                    b+1   b+1    b+1  b+1  b+1   b+1   b+2 texplore  0 sw  ; ... % wait for poles to descend, wait duration of sampling period.
                    b+2   b+2    b+2  b+2  b+2   b+2   b+3 tpost  0 0
                    b+3   b+3    b+3  b+3  b+3   b+3   35    .75    0       0  ; ... % raise poles by unsetting pvid, then go state 35 for new trial.3
                    ];


                %------ Signal trial number on digital output given by 'slid':
                % Requires that states 101 through 101+2*numbits be reserved
                % for giving bit signal.

                trialnum = n_done_trials + 1;

                %             trialnum = 511; %63;
                % Should maybe make following 3 SPHs in State Machine Control
                % GUI:
                bittm = 0.002; % bit time
                gaptm = 0.005; % gap (inter-bit) time
                numbits = 10; %2^10=1024 possible trial nums; will error after that.


                x = dec2binvec_behav(trialnum)';
                if length(x) < numbits
                    x = [x; repmat(0, [numbits-length(x) 1])];
                end
                % x is now 10-bit vector giving trial num, LSB first (at top).
                x(x>0) = slid;

                % Insert a gap state between bits, to make reading bit pattern clearer:
                x=[x zeros(size(x))]';
                x=reshape(x,numel(x),1);

                y = (101:(100+2*numbits))';
                t = repmat([bittm; gaptm],[numbits 1]);
                m = [y y y y y y y+1 t x zeros(size(y))];

                %m(end,7) = b+1; % jump back to state that triggers pole descent.
                nm=100+size(m, 1)+1;

                % add a .5 sec wait time
                m(end+1, :)= [nm nm nm nm nm nm b+1 0.25 0 0];

                stm = [stm; zeros(101-rows(stm),10)];
                stm = [stm; m];

                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;

                SetStateProgram(machine,'matrix',stm);

            case 'Pole-up-pole-down'

                setupScheduledWaves;

                %                 stim_delay_in_task_periods = stim_delay_in_ms*task_periods_per_ms; % task_periods_per_ms defined in setupScheduledWaves
                %                 stim_dur_in_task_periods = ceil(stim_dur_in_ms*task_periods_per_ms); % Can't have fractional task periods.
                %

                sw = 2^wave_id_masking_flash_blue + 2^wave_id_aom_473 + 2^wave_id_x_galvo + 2^wave_id_y_galvo ...
                    + 2^wave_id_shutter; % IDs defined in setupScheduledWaves.m


                texplore=4;
                tpost=1;

                stm = [stm ;
                    b     b      b    b    b     b     101  .01   cmid+etid  0   ; ... % trigger camera gate sched wave and EPHUS; 10 ms later jump to state 101 to start triggering camera frames and give trial num bit code.
                    b+1   b+1    b+1  b+1  b+1   b+1   b+2 texplore  pvid sw  ; ... % wait for poles to descend, wait duration of sampling period.
                    b+2   b+2    b+2  b+2  b+2   b+2   b+3 tpost  0 0
                    b+3   b+3    b+3  b+3  b+3   b+3   35    .75    0       0  ; ... % raise poles by unsetting pvid, then go state 35 for new trial.3
                    ];


                %------ Signal trial number on digital output given by 'slid':
                % Requires that states 101 through 101+2*numbits be reserved
                % for giving bit signal.

                trialnum = n_done_trials + 1;

                %             trialnum = 511; %63;
                % Should maybe make following 3 SPHs in State Machine Control
                % GUI:
                bittm = 0.002; % bit time
                gaptm = 0.005; % gap (inter-bit) time
                numbits = 10; %2^10=1024 possible trial nums; will error after that.


                x = dec2binvec_behav(trialnum)';
                if length(x) < numbits
                    x = [x; repmat(0, [numbits-length(x) 1])];
                end
                % x is now 10-bit vector giving trial num, LSB first (at top).
                x(x>0) = slid;

                % Insert a gap state between bits, to make reading bit pattern clearer:
                x=[x zeros(size(x))]';
                x=reshape(x,numel(x),1);

                y = (101:(100+2*numbits))';
                t = repmat([bittm; gaptm],[numbits 1]);
                m = [y y y y y y y+1 t x zeros(size(y))];

                %m(end,7) = b+1; % jump back to state that triggers pole descent.
                nm=100+size(m, 1)+1;

                % add a .5 sec wait time
                m(end+1, :)= [nm nm nm nm nm nm b+1 0.05 0 0];

                stm = [stm; zeros(101-rows(stm),10)];
                stm = [stm; m];

                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;

                SetStateProgram(machine,'matrix',stm);
                %                 SetStateProgram(machine,'matrix',stm,'globals',G,'tickfunc','tick_func','threshfunc','thresh_func',...
                %                     'entryfuncs',{40,'start_trial_func'},'initfunc','init_func','fsm_swap_on_state_0',1);
                %

            case 'Beam-Break-Indicator'
                stm = [stm ;
                    b+1   b  b    b   b   b      35  999  0      0  ; ...
                    b+1   b  b+1  b+1 b+1 b+1    35  999  LEDid  0  ; ...
                    ];
                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;
                SetStateMatrix(machine,stm,1);

            case 'Laser-473nm-On-Min'
                G = wrap_c_file_in_string([embCPath 'laser_on_min.c']); % Add preprocessing based on SoloParamHandle menus

                stm = [stm ;
                    b   b  b    b   b   b      35  999  0      0  ; ...
                    ];
                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;

                SetStateProgram(machine,'matrix',stm,'globals',G,'initfunc','init_func','cleanupfunc','cleanup_func','fsm_swap_on_state_0',0);

            case 'Laser-473nm-On-Max'
                G = wrap_c_file_in_string([embCPath 'laser_on_max.c']); % Add preprocessing based on SoloParamHandle menus

                stm = [stm ;
                    b   b  b    b   b   b      35  999  0      0  ; ...
                    ];
                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;

                SetStateProgram(machine,'matrix',stm,'globals',G,'initfunc','init_func','cleanupfunc','cleanup_func','fsm_swap_on_state_0',0);

            case 'Discrim'
                setupScheduledWaves;

                %                 stim_delay_in_task_periods = stim_delay_in_ms*task_periods_per_ms; % task_periods_per_ms defined in setupScheduledWaves
                %                 stim_dur_in_task_periods = ceil(stim_dur_in_ms*task_periods_per_ms); % Can't have fractional task periods.

                %                 G = wrap_c_file_in_string([embCPath 'globals.c']);
                %
                % %                 G = preprocessEmbC(G,stim_trial,stim_delay_in_task_periods,stim_dur_in_task_periods,...
                % %                     value(WhiskerThreshLow),value(WhiskerThreshHigh)); % re-write with inputParser
                % %
                %                  stim_state_for_EmbC = b+1; % state 41
                %
                %                 G = preprocessEmbC(G,stim_trial,stim_delay_in_task_periods,stim_dur_in_task_periods,...
                %                     value(WhiskerThreshLow),value(WhiskerThreshHigh),stim_state_for_EmbC,stim_AOM_power); % re-write with inputParser
                %
                %
                if ~isempty(strfind(next_trial_type,'Go'))
                    onlk = RealTimeStates.reward(1);
                    tmout = RealTimeStates.miss(1);
                elseif ~isempty(strfind(next_trial_type,'Nogo'))
                    onlk = RealTimeStates.airpuff(1);
                    tmout = RealTimeStates.correct_nogo(1);
                else
                    error(['Unrecognized trial type: ' next_trial_type])
                end


                sw0 = 2^wave_id_masking_flash_blue;
                sw =  2^wave_id_aom_473 + 2^wave_id_x_galvo + 2^wave_id_y_galvo ...
                    + 2^wave_id_shutter; % IDs defined in setupScheduledWaves.m


                stm = [stm ;
                    b     b      b    b    b     b     101  .01   cmid+etid  0   ; ... % trigger camera gate sched wave and EPHUS; 10 ms later jump to state 101 to start triggering camera frames and give trial num bit code.
                    b+1   b+1    b+1  b+1  b+1   b+1   b+2 sptm  pvid 0  ; ... % wait for poles to descend, wait duration of sampling period.
                    onlk onlk  b+2  b+2  b+2   b+2   tmout aptm   pvid   0  ; ... % wait for lick for aptm seconds.
                    b+3   b+3    b+3  b+3  b+3   b+3   b+4  wvtm  pvid+wvid+slid 0  ; ... % give water - HIT. Give pulse on signal line too, for measuring clock drift.
                    b+4   b+4    b+4  b+4  b+4   b+4   b+8  1.25-wvtm  pvid 0  ; ... % Time to drink after closing valve.
                    b+9   b+5    b+5  b+5  b+5   b+5   b+8  eiti  pvid   0 ; ... % incorrect lick, airpuff + extra ITI - FALSE ALARM
                    b+6   b+6    b+6  b+6  b+6   b+6   b+8  .001    pvid+slid    0  ; ... % didn't lick before timeout - MISS
                    b+7   b+7    b+7  b+7  b+7   b+7   b+8  .001    pvid+slid    0  ; ... % correct nogo - CORRECT REJECTION
                    b+8   b+8    b+8  b+8  b+8   b+8   35    1    0       0  ; ... % raise poles by unsetting pvid, then go state 35 for new trial.
                    b+9   b+9    b+9  b+9  b+9   b+9   b+5  pfdr    pvid+slid   0 ; ... % FALSE ALARM. Second extra ITI state, to retrigger extra ITI.
                    ];


                %------ Signal trial number on digital output given by 'slid':
                % Requires that states 101 through 101+2*numbits be reserved
                % for giving bit signal.

                trialnum = n_done_trials + 1;

                %             trialnum = 511; %63;
                % Should maybe make following 3 SPHs in State Machine Control
                % GUI:
                bittm = 0.002; % bit time
                gaptm = 0.005; % gap (inter-bit) time
                numbits = 10; %2^10=1024 possible trial nums; will error after that.


                x = dec2binvec_behav(trialnum)';
                if length(x) < numbits
                    x = [x; repmat(0, [numbits-length(x) 1])];
                end
                % x is now 10-bit vector giving trial num, LSB first (at top).
                x(x>0) = slid;

                % Insert a gap state between bits, to make reading bit pattern clearer:
                x=[x zeros(size(x))]';
                x=reshape(x,numel(x),1);

                y = (101:(100+2*numbits))';
                t = repmat([bittm; gaptm],[numbits 1]);
                m = [y y y y y y y+1 t x zeros(size(y))];

                %m(end,7) = b+1; % jump back to state that triggers pole descent.
                nm=100+size(m, 1)+1;

                % add a .5 sec wait time, trigger waves
                tx0=0.25;
                tx=0.5;
                m(end+1, :)= [nm nm nm nm nm nm nm+1 tx0 0 sw0];
                % fire another wave set
                m(end+1, :)= [nm+1 nm+1 nm+1 nm+1 nm+1 nm+1 b+1 tx 0 sw];

                stm = [stm; zeros(101-rows(stm),10)];
                stm = [stm; m];

                stm = [stm; zeros(512-rows(stm),10)]; state_matrix.value = stm;

                SetStateProgram(machine,'matrix',stm);
                %                 SetStateProgram(machine,'matrix',stm,'globals',G,'tickfunc','tick_func','threshfunc','thresh_func',...
                %                     'entryfuncs',{40,'start_trial_func'},'initfunc','init_func','fsm_swap_on_state_0',1);
                %

            otherwise
                error('Invalid session type')
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

