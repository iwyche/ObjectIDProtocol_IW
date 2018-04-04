% [x, y] = TrialTypeSection(obj, action, x, y)
%
% Section that takes care of choosing the next trial type and keeping
% track of a plot of sides and hit/miss history.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it; also calls 'choose_next_trial_type' and
%                        'update_plot' (see below)
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
%            'choose_next_trial_type'  Picks what will be the next correct
%                        side.
%
%            'get_next_trial_type'  Returns either 'l' for left or 'r' for right.
%
%            'update_plot'    Update plot that reports on sides and hit
%                        history
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI.
%
% x        When action = 'get_next_trial_type', x will be either 'l' for
%          left or 'r' for right.
%

function [x, y] = TrialTypeSection(obj, action, x, y)

GetSoloFunctionArgs;


switch action

    case 'init',   % ------------ CASE INIT ----------------
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

        SoloParamHandle(obj, 'previous_trial_types', 'value', {});

        % Give read-only access to AnalysisSection.m:
        SoloFunctionAddVars('AnalysisSection', 'ro_args', 'previous_trial_types');

        % Max number of times same go/no-go trial type can appear
        MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' 'Inf'}, ...
            '3', x, y); % Applies to Go vs Nogo, not to pulse train type on Go trials.

        MenuParam(obj, 'StimDelay', {'[0,5,10,20,50]ms','[0,5,50]ms','5ms'}, ...
            '5ms', x, y);
        next_row(y);

        next_row(y);
        MenuParam(obj, 'Pulsedur', {'50', '100','200', '500'}, ...
            '100', x, y);
        next_row(y);
        MenuParam(obj, 'StimType', {'constant','5ms_pulse', '5ms_grid', 'shift','constant_shift', 'grid_and_s1', 'shiftgrid', 'depblock', 'collision'}, ...
            '5ms_pulse', x, y);
        
        next_row(y);
        NumeditParam(obj, 'StimProb', 0, x, y,'TooltipString',...
            'Probability that a trial will have photostimulation.');
        
        next_row(y);
        NumeditParam(obj, 'GoProb', 0.5, x, y,'TooltipString',...
            'Probability of a go trial.');
        
        next_row(y);
        NumeditParam(obj, 'WhiskerThreshLow', 0.2, x, y,'TooltipString',...
            'Position threshold (low) for real-time whisker detector.');

        next_row(y);
        NumeditParam(obj, 'WhiskerThreshHigh', 0.6, x, y,'TooltipString',...
            'Position threshold (low) for real-time whisker detector.');
       
        next_row(y);
        NumeditParam(obj, 'yshiftvar', 2.5, x, y,'TooltipString',...
            'y shift');

        next_row(y);
        NumeditParam(obj, 'xshiftvar', -3, x, y,'TooltipString',...
            'x shift');
        
        next_row(y);
        NumeditParam(obj, 'Stimfreq', 50, x, y,'TooltipString',...
            'stimulation frequency');

        next_row(y);
        NumeditParam(obj, 'Testfreq', 5, x, y,'TooltipString',...
            'stimulation frequency');

        next_row(y);
        NumeditParam(obj, 'CondNorm', 1, x, y,'TooltipString',...
            'normalizing factor for conditioning pulses');

        next_row(y);
        NumeditParam(obj, 'Ramp', 0, x, y,'TooltipString',...
            'ramping time');

        next_row(y);
        NumeditParam(obj, 'Stimduration', 2000, x, y,'TooltipString',...
            'stimulation time');

        next_row(y);
        NumeditParam(obj, 'OnsetJitt', 0, x, y,'TooltipString',...
            'onset jitter time');
        
                next_row(y);
        NumeditParam(obj, 'OnsetRand', 0, x, y,'TooltipString',...
            'randomize?');

        next_row(y, 1.5);

        SubheaderParam(obj, 'sidestitle', 'Trial type/stim settings', x, y);
        next_row(y);

        pos = get(gcf, 'Position'); % [left, bottom, width, height]
        SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
        set(value(myaxes), 'Units', 'pixels');
        set(value(myaxes), 'Position', [135 pos(4)-140 pos(3)-150 100]);
        set(value(myaxes), 'YTick', 1:4, 'YLim', [0.5 6.5], 'YTickLabel', ...
            {'StimNogo', 'StimGo','Nogo','Go'});
        
        NumeditParam(obj, 'ntrials', 100, x, y, ...
            'position', [5 pos(4)-50 40 40], 'labelpos', 'top', ...
            'TooltipString', 'How many trials to show in plot');
        set_callback(ntrials, {mfilename, 'update_plot'});
        xlabel('trial number');

        TrialTypeSection(obj, 'choose_next_trial_type');
        TrialTypeSection(obj, 'update_plot');

        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'StimType','CondNorm', 'Pulsedur','WhiskerThreshHigh', 'xshiftvar', 'yshiftvar', 'Stimfreq', 'Testfreq','Ramp', 'Stimduration', 'OnsetJitt', 'OnsetRand'});
        SoloFunctionAddVars('setupScheduledWaves', 'ro_args', 'StimType');

    case 'choose_next_trial_type', % --------- CASE choose_next_trial_type -----
        tt = value(previous_trial_types);
        
        if rand(1) <= value(GoProb)
            next_type = 'Go';
        else
            next_type = 'Nogo';
        end

%         nogo_types = {'Nogo','NogoStim_0ms','NogoStim_5ms','NogoStim_10ms','NogoStim_20ms','NogoStim_50ms'};
       
%       Enforce run limit:
        runlim = value(MaxSame);
        
        if runlim ~= Inf && runlim < n_started_trials
           prev_types = strfind(tt((end-(runlim-1)):end),'Nogo');
           prev_types = cellfun(@(x) ~isempty(x), prev_types);

            if all(prev_types)
                next_type = 'Go';
            elseif ~any(prev_types)
                next_type = 'Nogo';        
            end
        end

        % Decide randomly whether this is a stim trial:
        if rand(1) <= value(StimProb)
            next_type = [next_type 'Stim'];
        end
         
        if ismember(next_type,{'GoStim','NogoStim'})
            % If it's a stim trial, decide on stim delay:
            switch value(StimDelay)
                case '[0,5,10,20,50]ms'
                    r = randsample([0,5,10,20,50],1,true);
                    next_trial_type = [next_type '_' int2str(r) 'ms'];
                case '[0,5,50]ms'
                    r = randsample([0,5,50],1,true);
                    next_trial_type = [next_type '_' int2str(r) 'ms'];
                case '5ms'
                    next_trial_type = [next_type '_5ms'];
                otherwise
                    error('Unrecognized value of StimDelay.')
            end
            
            % Next decide on pulse type (duration, number, frequency):
%             MenuParam(obj, 'StimType', {'constant','5ms_pulse_20Hz','5ms_pulse_50Hz'}, ...
%                 '5ms_pulse_50Hz', x, y);

            switch value(StimType)
                case {'constant','5ms_pulse','5ms_grid', 'shift','constant_shift', 'grid_and_s1', 'shiftgrid', 'depblock', 'collision'} 
                    next_trial_type = [next_type '_' value(StimType)];
%                 case '[1,2,3]@40Hz_1.33ms' % Either 1, 2 or 3 pulses (randomly chosen), 1.33 ms each, at 40 Hz 
%                     r = randsample([1,2,3],1,true);
%                     next_trial_type = [next_trial_type '_' int2str(r) '@40Hz_1.33ms'];
%                 case '[1,2,3]@40Hz_2ms' % Either 1, 2 or 3 pulses (randomly chosen), 2 ms each, at 40 Hz 
%                     r = randsample([1,2,3],1,true);
%                     next_trial_type = [next_trial_type '_' int2str(r) '@40Hz_2ms'];
                otherwise
                    error('Unrecognized value of StimType.')
            end
        else
            next_trial_type = next_type;
        end
            
    
        % For licking session, override.
        session_type = SessionTypeSection(obj,'get_session_type');
        if strcmp(session_type,'Licking')
            next_trial_type = 'Go'; % Make it always the go-trial position, so mouse doesn't have to unlearn anything.
        end

        tt{n_started_trials+1} = next_trial_type;
        previous_trial_types.value = tt;

        disp(['Next trial type: ' next_trial_type]);


    case 'get_next_trial_type'   % --------- CASE get_next_trial_type ------
        tt = value(previous_trial_types);
        if isempty(tt),
            error('Don''t have next trial type chosen! Did you run choose_next_trial_type?');
        end
        x = tt{end};
        return;


    case 'update_plot'     % --------- UPDATE_PLOT ------
        tt = value(previous_trial_types);

        if isempty(tt)
            return
        end

        thisTrialType = tt{end};

        ax = value(myaxes);
        axes(ax); cla; hold on

              
        % Plot current trial in blue:
        if strcmp(thisTrialType,'Go')
            plot(length(tt), 4, 'b.')
        elseif strcmp(thisTrialType,'Nogo')
            plot(length(tt), 3, 'b.')
        elseif ~isempty(strfind(thisTrialType,'GoStim'))
            plot(length(tt), 2, 'b.')
        elseif ~isempty(strfind(thisTrialType,'NogoStim'))
            plot(length(tt), 1, 'b.')
        else
            error('Unrecognized last trial type.')
        end
        
        % Plot past trials, colored by outcome.
        resp = response_history; % 1 for lick, 0 for no-lick
        tt = value(previous_trial_types);
        tt = tt(1:(end-1));
        
        if ~isempty(tt)
            go_trials = ismember(tt,{'Go'})';
            nogo_trials = ismember(tt,{'Nogo'})';

%             go_stim_trials = ismember(tt,{'GoStim_0ms','GoStim_5ms','GoStim_10ms','GoStim_20ms','GoStim_50ms'})';
%             nogo_stim_trials = ismember(tt,{'NogoStim_0ms','NogoStim_5ms','NogoStim_10ms','NogoStim_20ms','NogoStim_50ms'})';

            go_stim_trials = cellfun(@(x) ~isempty(strfind(x,'GoStim')), tt)'; 
            nogo_stim_trials = cellfun(@(x) ~isempty(strfind(x,'NogoStim')), tt)'; 
                        
            xx = find(go_trials & resp); yy = repmat(4,size(xx)); plot(ax,xx,yy,'g.')
            xx = find(go_trials & ~resp); yy = repmat(4,size(xx)); plot(ax,xx,yy,'r.')
            xx = find(nogo_trials & ~resp); yy = repmat(3,size(xx)); plot(ax,xx,yy,'g.')
            xx = find(nogo_trials & resp); yy = repmat(3,size(xx)); plot(ax,xx,yy,'r.')

            xx = find(go_stim_trials & resp); yy = repmat(2,size(xx)); plot(ax,xx,yy,'g.')
            xx = find(go_stim_trials & ~resp); yy = repmat(2,size(xx)); plot(ax,xx,yy,'r.')
            xx = find(nogo_stim_trials & ~resp); yy = repmat(1,size(xx)); plot(ax,xx,yy,'g.')
            xx = find(nogo_stim_trials & resp); yy = repmat(1,size(xx)); plot(ax,xx,yy,'r.')
         end

        minx = n_done_trials - ntrials; if minx < 0, minx = 0; end;
        maxx = n_done_trials + 2; if maxx <= ntrials, maxx = ntrials+2; end;

        set(ax, 'XLim', [minx, maxx],'YTick', 1:4, 'YLim', [0.5 4.5], 'YTickLabel', ...
            {'NogoStim', 'GoStim','Nogo','Go'});

    case 'reinit',   % ------- CASE REINIT -------------
        currfig = gcf;

        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

        delete(value(myaxes));

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);

        % Reinitialise at the original GUI position and figure:
        [x, y] = feval(mfilename, obj, 'init', x, y);

        % Restore the current figure:
        figure(currfig);
end;


