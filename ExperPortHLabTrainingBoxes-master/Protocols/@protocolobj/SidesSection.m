function [x, y, side_list, WaterDelivery, RewardPorts, LeftProb, bias]=SidesSection(obj,action,x,y);
%
% [x, y, side_list, WaterDelivery, RewardPorts] = ...
%    SidesSection(obj, action, x, y);
%
% args:    x, y                  current UI pos, in pixels
%          n_done_trials         handle to number of completed trials
%          hit_history           handle to history of hits versus errors
%                                (vector: 1=hit, 0=error, len=n_done_trials)
%          maxtrials             max number of trials in experiment
%          obj                   A locsamp3obj object
%
% returns: x, y                  updated UI pos
%          side_list             handle to vector of correct sides,
%                                   one per trial.
%          WaterDelivery         handle to type of delivery (direct, etc).
%          RewardPorts           handle to type of reward (correct, etc.)
%          update_sidesplot_fn  function that updates sides and rewards plot
%          set_next_side_fn     fn, uses error hist to override correct side
%

GetSoloFunctionArgs;
child_class= ['@' class(value(mychild))];
%
% pairs = {
% 	'n_done_trials', 0	; ...
% 	'n_started_trials', 0	; ...
% 	'hit_history', []	; ...
% 	'maxtrials', 0		; ...
% }; parse_knownargs(varargin, pairs);

child_vars = { 'sidesfig', 'Stubbornness', 'MaxSame', 'LeftProb', 'side_list', 'WaterDelivery', 'RewardPorts', 'SidesParameters',...
    'h', 'p', 'g', 'r', 'o', 'thl', 'thr', 'thh', 'thm', 'width'};

if ~strcmp(action, 'init')
    for c_var = 1:length(child_vars)
        func_name = [ mfilename '_' child_vars{c_var} ];
        sph = get_sphandle('owner', child_class, 'name', child_vars{c_var}, ...
            'fullname', func_name); sph = sph{1};
        eval([child_vars{c_var} ' =  sph;']);
    end;
end;

switch action,

    case 'init', % ----------  INIT  -------------------------
        % main protocol window
        parentfig = gcf; figure(parentfig);
        parent_x = x; parent_y = y;

        % new popup window
        x = 5; y = 5;
        SoloParamHandle(obj, 'sidesfig', 'value', figure, 'saveable', 0, 'param_owner', child_class);

        EditParam(obj, 'Stubbornness', 0,   x, y, 'param_owner', child_class); next_row(y);
        MenuParam(obj, 'MaxSame', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' 'Inf'}, 6, x, y, ...
            'param_owner', child_class); next_row(y);
        EditParam(obj, 'LeftProb',     0.5, x, y, 'param_owner', child_class); next_row(y);
        next_row(y, 0.5);
        SoloParamHandle(obj, 'side_list', 'value', zeros(1, value(maxtrials)), ...
                        'param_owner', child_class);
         SoloParamHandle(obj, 'bias_array', 'value', zeros(1, value(maxtrials)), 'param_owner', child_class);

        set_callback({LeftProb, MaxSame}, { ...
            'SidesSection', 'super', 'set_future_sides' ; ...
            'SidesSection', 'super', 'update_plot'});

        % Params that control the reward mode:
        MenuParam(obj, 'WaterDelivery', {'direct', 'next corr poke', 'only if nxt pke corr'}, 2, x, y, ...
            'param_owner', child_class); next_row(y);
        MenuParam(obj, 'RewardPorts',   {'correct port', 'both ports'},1, x, y, ...
            'param_owner', child_class); next_row(y);next_row(y,0.5);

        SubheaderParam(obj, 'sides_sbh', 'Trial Side & Schedule', x, y);next_row(y);

        % wrap up child figure stuff and return control to parent
        set(value(sidesfig), ...
            'Visible', 'off', 'MenuBar', 'none', 'Name', 'Trial Sides and Schedule', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['SidesSection(' class(value(mychild)) '(''empty''), ''sides_param_hide'')']);
        set(value(sidesfig), 'Position', [980 781 288 151]);

        x = parent_x; y = parent_y; figure(parentfig); % make master protocol figure gcf
        MenuParam(obj, 'SidesParameters', {'hidden', 'view'}, 1, x, y, 'param_owner', child_class); next_row(y);
        set_callback({SidesParameters}, {'SidesSection', 'sides_param_view'});

        % ---- Now initialize plot
        oldunits = get(gcf, 'Units'); set(gcf, 'Units', 'normalized');
        SoloParamHandle(obj, 'h',  'value', axes('Position', [0.06, 0.86, 0.8, 0.08]), ...
            'param_owner', child_class); % axes
        SoloParamHandle(obj, 'p',  'value', plot(-1, 1, 'b.'), ...
            'param_owner', child_class); hold on; % blue dots
        SoloParamHandle(obj, 'g',  'value', plot(-1, 1, 'g.'), ...
            'param_owner', child_class); hold on; % green dots
        SoloParamHandle(obj, 'r',  'value', plot(-1, 1, 'r.'), ...
            'param_owner', child_class); hold on; % red dots
        SoloParamHandle(obj, 'o',  'value', plot(-1, 1, 'ro'), ...
            'param_owner', child_class); hold on; % next trial indicator
        SoloParamHandle(obj, 'thl','value', text( -1 * ones(1,maxtrials), 0.5*ones(1,maxtrials),'l'), ...
            'param_owner', child_class);
        SoloParamHandle(obj, 'thr','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'r'), ...
            'param_owner', child_class);
        SoloParamHandle(obj, 'thh','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'h'), ...
            'param_owner', child_class);
        SoloParamHandle(obj, 'thm','value', text(-ones(1,maxtrials), 0.5*ones(1,maxtrials),'m'), ...
            'param_owner', child_class);
        set_saveable({h;p;g;r;o;thl;thh;thm}, 0);
        set([value(thl);value(thr);value(thh);value(thm)], ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', ...
            'middle', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'b', ...
            'FontName', 'Helvetica', 'Clipping', 'on');

        set(value(h), 'YTick', [0 1], 'YTickLabel', {'Right', 'Left'});
        xlabel('');

        set(gcf, 'Units', oldunits);

        % "width", an EditParam to control the # of trials in the plot:
        SoloParamHandle(obj, 'width', 'type', 'edit', 'label', 'ntrials', ...
            'labelpos', 'bottom','TooltipString', 'number of trials in plot', ...
            'value', 90, 'position', [490 645 35 40], ...
            'param_owner', child_class);
        set(get_ghandle(width), 'Units','normalized', 'Position',[0.88 0.9 0.05 0.02]);
        set(get_lhandle(width), 'Units','normalized', 'Position', [0.88 0.87 0.05 0.02]);
        set_callback(width, {'SidesSection', 'super', 'update_plot'});
        
        SoloParamHandle(obj, 'opp_hit_ctr', 'value', 0,  'param_owner', child_class);
        SoloParamHandle(obj, 'onesidemode', 'value', 0,  'param_owner', child_class);
        SoloParamHandle(obj, 'last_change', 'value', 0,  'param_owner', child_class);
        
        SoloParamHandle(obj, 'bias', 'value', 0, 'param_owner', ...
                        child_class);

        % --- ok, initialize actual values

        SidesSection(obj, 'set_future_sides');
        SidesSection(obj, 'update_plot');


    case 'update_plot', % ----------  UPDATE_PLOT  -------------------------

        % first assign these child vars in your workspace so you can work
        % with them.
        child_class = ['@' class(value(mychild)) ];

        [x, mn, mx] = SidesSection(obj, 'get_width');

        % First, the future:
        set(value(p), 'XData', n_done_trials+1:mx, 'YData', side_list(n_done_trials+1:mx));
        set(value(h), 'Ylim', [-0.5 1.5], 'XLim', [mn-1 mx+1]);
        set(value(o), 'XData', n_done_trials+1, 'YData', side_list(n_done_trials+1));
        u = n_done_trials;
        if u==0, return; end;

        % Will redraw all points; first clear them off the screen
        set(value(r), 'XData', -1, 'YData', -1);
        set(value(g), 'XData', -1, 'YData', -1);
        % Loop over all done trials:
        for i=1:u,
            % the both-ports-reward trials-- no hit or miss defined here,
            % what matters is just r and l
            if strcmp(get_history(RewardPorts, i), 'both ports'),
                if (side_list(i)==1 & hit_history(i)==1) | ...
                        (side_list(i)==0 & hit_history(i)==0),
                    set(thl(i), 'Position', [i 0.5]);
                elseif (side_list(i)==0 & hit_history(i)==1) | ...
                        (side_list(i)==1 & hit_history(i)==0),
                    set(thr(i), 'Position', [u 0.5]);
                end;


                % Next the guys with direct water delivery or next correct poke:
                % rat *always* gets water here but hit and miss are well-defined
            elseif ismember(get_history(WaterDelivery, i), ...
                    {'next corr poke', 'direct'})
                if hit_history(i)==1, set(thh(i), 'Position',[i side_list(i)]);
                else                  set(thm(i), 'Position',[i side_list(i)]);
                end;

                % Remaining possibility:
                % RewardPorts=correct, WaterDelivery=only if next poke correct
            elseif ~isnan(hit_history(i)) && hit_history(i),
                gh = value(g);
                set(gh, 'XData', [get(gh, 'XData') i], ...
                    'YData', [get(gh, 'YData') side_list(i)]);
            else
                gh = value(r);
                set(gh, 'XData', [get(gh, 'XData') i], ...
                    'YData', [get(gh, 'YData') side_list(i)]);
            end;
        end;

    case 'set_future_sides', % ----------  SET_FUTURE_SIDES  ----------------
        set(get_ghandle(MaxSame), 'Enable', 'on');
        set(get_ghandle(Stubbornness), 'Enable', 'on');
        set(get_ghandle(LeftProb), 'Enable', 'on');

        sl          = value(side_list);
        starting_at = n_started_trials+1;

        % generate L-R
        sl(starting_at:maxtrials) = rand(1,maxtrials-starting_at+1)<=LeftProb;

        no_change1=0; no_change2=0; no_change3=0;
        sl_sub = sl(starting_at:maxtrials);
        while ~(no_change1 && no_change2 && no_change3)
            [sl_sub, no_change1] = MaxSame_correction(sl_sub, value(MaxSame));
            [sl_sub, no_change2] = correct_alternation(sl_sub, value(LeftProb), 5);   % HARDCODED value: Any block of alternation > 5 is considered a run
            [sl_sub, no_change3] = correct_sidebias(sl_sub, value(LeftProb), 0.1, value(MaxSame));  % HARDCODED value: Lenience of 20%
        end;

        sl(starting_at:maxtrials) = sl_sub;
        side_list.value = sl;
        %         sides_sbh.value = 'Look Maw, I''m working!';


    case 'fix_future_sides', % --------- FIX_FUTURE_SIDES -------------------
        % instead of generating future sides based on the SidesSection
        % algorithm, set to hard-coded future sides
        set(get_ghandle(MaxSame), 'Enable', 'off');
        set(get_ghandle(Stubbornness), 'Enable', 'off');
        set(get_ghandle(LeftProb), 'Enable', 'off');
        
        temp = value(side_list); start = n_started_trials+1;
        trials = (maxtrials-start)+1;
        if sum(size(x) == size(zeros(1,trials))) < 2,error('Invalid array size from which to fix trials!');
        end;
        
        temp(start:maxtrials) = x;
        side_list.value = temp;        


    case 'choose_next_side', % ----------  CHOOSE_NEXT_SIDE  ----------------
        lasthit = hit_history(n_started_trials);
        if ~isnan(lasthit) & lasthit==0, % If have response, and it was error, act:
            if rand(1) <= Stubbornness,
                side_list(n_started_trials+1) = side_list(n_started_trials);
            end;
        end;


    case 'get_width',  % --- GET_WIDTH ---  VpdsSection sometimes requests this
        x         = width;
        y         = max(round(n_started_trials-2*width/3), 1);
        side_list = min(floor(y+width), length(side_list));

    case 'sides_param_view',	% --- SIDES_PARAM_VIEW ---
        switch value(SidesParameters)
            case 'hidden',
                set(value(sidesfig), 'Visible', 'off');
            case 'view',
                set(value(sidesfig), 'Visible', 'on');
        end;
    case 'sides_param_hide',
        SidesParameters.value = 'hidden';
        set(value(sidesfig), 'Visible', 'off');

    case 'delete'
        delete(value(sidesfig));


    otherwise,
        error(['Don''t know how to handle action ' action]);
end;
