function [] = RewardsSection(obj, action)

global state_machine_properties;

GetSoloFunctionArgs;

switch action
    case 'init',
        SoloParamHandle(obj, 'pstruct');
        SoloParamHandle(obj, 'LastTrialEvents', 'value', []);
        SoloParamHandle(obj, 'LastTrialEmbCLogItems', 'value', {});
        SoloParamHandle(obj, 'EmbCLogItemCounter', 'value', 0);

    case 'trial_finished',
        % Make sure we've collected up to the latest events from the RT machine:
        RewardsSection(obj, 'update');

        % Parse the events from the last trial:
        pstruct.value = parse_trial(value(LastTrialEvents), RealTimeStates);

        %       % Parse the events from the last trial:
        %       pstruct.value = parse_trial(value(LastTrialEvents), RealTimeStates,...
        %           {'statename_list', 'all'}, {'parse_pokes', false});

        % Take the current raw events and push them into the history:
        push_history(LastTrialEvents); LastTrialEvents.value = [];

%                             onlk = RealTimeStates.no_feedback_lick(1);
%                     tmout = RealTimeStates.no_feedback_nolick(1);
                    
        if rows(pstruct.reward) > 0 || rows(pstruct.airpuff) > 0 
            resp = 1; % lick lick
        else
            resp = 0; % no lick
        end

        response_history.value = [response_history(:) ; resp];


        %---- Retrieve and store the EmbCFSM log buffer. Only bring new
        % items over the network. 
        numVarLog = GetVarLogCounter(state_machine_properties.sm);
        disp(['Number of items in EmbC log: ' int2str(numVarLog)])
        disp(['Number of items retrieved so far: ' int2str(value(EmbCLogItemCounter))])
        numNewItems = numVarLog - value(EmbCLogItemCounter);
        disp(['Retrieving ' int2str(numNewItems) ' new items.'])
        if numNewItems > 0
            varLog = GetVarLog(state_machine_properties.sm, value(EmbCLogItemCounter)+1, numVarLog);
            EmbCLogItemCounter.value = value(EmbCLogItemCounter) + numNewItems;
            LastTrialEmbCLogItems.value = varLog;
        else
            LastTrialEmbCLogItems.value = {};
        end

        push_history(LastTrialEmbCLogItems); LastTrialEmbCLogItems.value = {};
%         disp('Called RewardsSection')
        %-------------------------------------------------
        
        
    case 'update',
        Event = GetParam('rpbox', 'event', 'user');
        LastTrialEvents.value = [value(LastTrialEvents); Event];

    case 'reinit',

        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);

        % Reinitialise
        feval(mfilename, obj, 'init');
end;


