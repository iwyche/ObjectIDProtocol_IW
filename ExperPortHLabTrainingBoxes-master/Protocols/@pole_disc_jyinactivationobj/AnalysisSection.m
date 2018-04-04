% [x, y] = AnalysisSection(obj, action, x, y)
%
% For doing online analysis of behavior.
%
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it;
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%           
%            Several other actions are available (see code of this file).
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
% x        When action = 'get_next_side', x will be either 'l' for
%          left or 'r' for right.
%

function [x, y] = AnalysisSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action

    case 'init',   % ------------ CASE INIT ----------------
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]); next_row(y,1.5);


        MenuParam(obj, 'analysis_show', {'view', 'hide'}, 'view', x, y, 'label', 'Analysis', 'TooltipString', 'Online behavior analysis');
        set_callback(analysis_show, {mfilename,'hide_show'});

        next_row(y,1.5);
        SubheaderParam(obj, 'sectiontitle', 'Analysis', x, y);

        parentfig_x = x; parentfig_y = y;

        % ---  Make new window for online analysis
        SoloParamHandle(obj, 'analysisfig', 'saveable', 0);
        analysisfig.value = figure('Position', [10   789   400   200], 'Menubar', 'none',... %1000 500 400 200
            'Toolbar', 'none','Name','Analysis','NumberTitle','off');

        x = 1; y = 1;
 
        DispParam(obj, 'NumTrials', 0, x, y); next_row(y);
        DispParam(obj, 'NumRewards', 0, x, y); next_row(y);
        DispParam(obj, 'PercentCorrect', 0, x, y); next_row(y);
        DispParam(obj, 'HR', 0, x, y); next_row(y);
        DispParam(obj, 'FAR', 0, x, y); next_row(y);
        DispParam(obj, 'HRMinusFAR', 0, x, y); next_row(y);
        DispParam(obj, 'Dprime', 0, x, y); next_row(y);
   
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure',value(myfig));
        return;

   
    case 'update' 
        resp = response_history; % 1 for lick, 0 for no-lick
        tt = value(previous_trial_types);
        tt = tt(1:(end-1));
               
%         go_trials = cellfun(@isempty, strfind(tt,'Go'))';       
%         nogo_trials = cellfun(@isempty, strfind(tt,'Nogo'))';
        go_trials = cellfun(@(x) ~isempty(strfind(x,'Go')),tt)'; 
        nogo_trials = cellfun(@(x) ~isempty(strfind(x,'Nogo')),tt)';
        
        %---------------------------------------------------
        fa = find(nogo_trials & resp);
        hit = find(go_trials & resp);
        cr = find(nogo_trials & ~resp);
        
        num_go = sum(go_trials);
        num_nogo = sum(nogo_trials);       

        if isempty(fa)
  
            far = 0;
        else
            far = length(fa)/num_nogo;
        end
   
        if isempty(hit)
            hr = 0;
        else
            hr = length(hit)/num_go;
        end
        
        
        dp = dprime(hr, far, num_go, num_nogo);
        
        NumTrials.value = sum([num_go,num_nogo]); % This is used to set the trial number for saving, *must* account
                                   % for *all* trials.
                                   
        NumRewards.value = sum(go_trials & resp);
        PercentCorrect.value = (length(hit) + length(cr))/(num_go + num_nogo);
        HR.value = hr;
        FAR.value = far;
        HRMinusFAR.value = hr-far;
        Dprime.value = dp;
        
        
    case 'hide_show'
        if strcmpi(value(analysis_show), 'hide')
            set(value(analysisfig), 'Visible', 'off');
        elseif strcmpi(value(analysis_show),'view')
            set(value(analysisfig),'Visible','on');
        end;
        return;


    case 'reinit'
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
        return;
end


