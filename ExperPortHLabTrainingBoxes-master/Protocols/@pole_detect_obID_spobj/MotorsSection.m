% [x, y] = MotorsSection(obj, action, x, y)
%
% Section that takes care of controlling the stepper motors.
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

% Lines 198-210 are where we need to make changes for object ID protocol

function [x, y] = MotorsSection(obj, action, x, y)

GetSoloFunctionArgs;

global Solo_Try_Catch_Flag
global motors_properties;
global motors; 

switch action

    case 'init',   % ------------ CASE INIT ----------------
        
        if strcmp(motors_properties.type,'@FakeZaberAMCB2')
            motors = FakeZaberAMCB2;
        else
            disp(['Real Motor!!!']);
            motors = ZaberAMCB2(motors_properties.port);
        end

        disp('trying to open motors');
        serial_open(motors);
        disp('motors are open');
        disp(motors);

        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]); next_row(y,1.5);
%        SoloParamHandle(obj, 'motor_num', 'value', 0);
        
        %added by ZG 10/1/11
        SoloParamHandle(obj, 'motor_num', 'value', 1);
        SoloParamHandle(obj, 'lateral_motor_num', 'value', 2);
        
        % List of pole positions
        SoloParamHandle(obj, 'previous_rt_positions', 'value', []);        
                
        
        % Set limits in microsteps for actuator. Range of actuator is greater than range of
        % our Del-Tron sliders, so must limit to prevent damage.  This limit is also coded into Zaber
        % TCD1000 firmware, but exists here to keep GUI in range. If a command outside this range (0-value)
        % motor driver gives error and no movement is made.
        SoloParamHandle(obj, 'motor_max_position', 'value', 180000);  
        SoloParamHandle(obj, 'trial_ready_times', 'value', 0);

        MenuParam(obj, 'motor_show', {'view', 'hide'}, 'hide', x, y, 'label', 'Motor Control', 'TooltipString', 'Control motors');
        set_callback(motor_show, {mfilename,'hide_show'});

        next_row(y);
        SubheaderParam(obj, 'sectiontitle', 'Motor Control', x, y);

        parentfig_x = x; parentfig_y = y;
       
        
        % ---  Make new window for motor configuration
        SoloParamHandle(obj, 'motorfig', 'saveable', 0);
        motorfig.value = figure('Position', [3 800 400 200], 'Menubar', 'none',...
            'Toolbar', 'none','Name','Motor Control','NumberTitle','off');

        x = 1; y = 1;

        %       PushButtonParam(obj, 'serial_open', x, y, 'label', 'Open serial port');
        %       set_callback(serial_open, {mfilename, 'serial_open'});
        %       next_row(y);

        PushButtonParam(obj, 'serial_reset', x, y, 'label', 'Reset serial port connection');
        set_callback(serial_reset, {mfilename, 'serial_reset'});
        next_row(y);

%         PushButtonParam(obj, 'reset_motors_firmware', x, y, 'label', 'Reset Zaber firmware parameters',...
%             'TooltipString','Target acceleration, target speed, and microsteps/step');
%         set_callback(reset_motors_firmware, {mfilename, 'reset_motors_firmware'});
%         next_row(y);

        PushButtonParam(obj, 'motors_home', x, y, 'label', 'Home motor');
        set_callback(motors_home, {mfilename, 'motors_home'});
        next_row(y);

        PushButtonParam(obj, 'motors_stop', x, y, 'label', 'Stop motor');
        set_callback(motors_stop, {mfilename, 'motors_stop'});
        next_row(y);

        PushButtonParam(obj, 'motors_reset', x, y, 'label', 'Reset motor');
        set_callback(motors_reset, {mfilename, 'motors_reset'});
        next_row(y, 2);
        
        next_column(x); y = 1;
        
        PushButtonParam(obj, 'read_positions', x, y, 'label', 'Read position');
        set_callback(read_positions, {mfilename, 'read_positions'});
        
        next_row(y);
        NumeditParam(obj, 'motor_position', 0, x, y, 'label', ...
            'Motor position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(motor_position, {mfilename, 'motor_position'});
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Read/set position', x, y);

        
        
        
        %--------------- extreme positions for the multi-pole task --------------------------------
        next_row(y);
        NumeditParam(obj, 'no_rt_position_easy', 0, x, y, 'label', ...
            '"No" position','TooltipString','No trial position in microsteps.');
        
        next_row(y);
        NumeditParam(obj, 'yes_rt_position_easy', 0, x, y, 'label', ...
            '"Yes" position','TooltipString','Yes trial position in microsteps.');

        next_row(y); % num_of_rt_position is number of possible objects to present
        NumeditParam(obj, 'num_of_rt_position', 3, x, y, 'label', ...
            'Pole positions','TooltipString','Number of Yes/No pole position');

        % switch between 2 pole task and multi-pole
        next_row(y);
        ToggleParam(obj, 'multi_go_position', 1, x, y, 'label', 'Multi Go Positions',...
            'TooltipString', 'Multiple pole position will be used.');
        %-----------------------------------------------------------
        
        
        
        next_row(y);
        NumeditParam(obj, 'motor_move_time', 2, x, y, 'label', ...
            'motor move time','TooltipString','set up time for motor to move.');

        next_row(y)
        PushButtonParam(obj, 'read_lateral_positions', x, y, 'label', 'Read lateral position');
        set_callback(read_lateral_positions, {mfilename, 'read_lateral_positions'});

        next_row(y);
        NumeditParam(obj, 'lateral_motor_position', 50000, x, y, 'label', ...
            'lateral_motor_position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(lateral_motor_position, {mfilename, 'lateral_motor_position'});

        next_row(y);
        SubheaderParam(obj, 'title', 'Trial position', x, y);
        

        MotorsSection(obj,'hide_show');
        MotorsSection(obj,'read_positions');
        MotorsSection(obj,'read_lateral_positions');
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure',value(myfig));
        return;

    case 'move_next_side', % --------- CASE MOVE_NEXT_SIDE -----
       
        next_side = SidesSection(obj,'get_next_side'); % decides if go or nogo should be next
%         if value(multi_go_position)==0
% 
%             if next_side == 'r'
%                 next_rt_position = value(yes_rt_position_easy);
%             elseif next_side == 'l'
%                 next_rt_position = value(no_rt_position_easy);
%             else
%                 error('un-recognized type for next_side');
%             end
% 
%             half_point = round((value(no_rt_position_easy)-value(yes_rt_position_easy))/2 + value(yes_rt_position_easy));
% 
%         else
            % spacing between pole positions
            pole_pos_interval = round((value(no_rt_position_easy)-value(yes_rt_position_easy))/(value(num_of_rt_position)*2-1));
            % pole_pos_interval=(*steps per rotation*)/num_of_rt_positions;
            
            if next_side == 'r' % go trial
                pole_ind = randsample(value(num_of_rt_position-1),1); % generates 1 integer between 1 and the number of go positions
                next_rt_position = pole_ind*pole_pos_interval + value(yes_rt_position_easy);
%                 next_rt_position = pole_ind*pole_pos_interval; % calculates how many steps to rotate in positive direction
            elseif next_side == 'l' % nogo trial
                pole_ind = 0; %randsample(value(num_of_rt_position),1)-1;
                next_rt_position = value(no_rt_position_easy) - pole_ind*pole_pos_interval;
%                 next_rt_position = -pole_ind*pole_pos_interval; % calculates how many steps to rotate in negative direction
            else
                error('un-recognized type for next_side');
            end

            % not really the half point, but a random position btw "yes" and "no" position to make motor movement unpredictable
%             half_point = round(rand(1)*(value(no_rt_position_easy)-value(yes_rt_position_easy))/1000)*1000 + value(yes_rt_position_easy);
            half_point = 0;
%         end
                
        
        tic
        move_absolute_sequence(motors,{half_point,next_rt_position},value(motor_num)); % moves to half point, then next motor position
        movetime = toc
        if movetime<value(motor_move_time) % Should make this min-ITI a SoloParamHandle
            pause( value(motor_move_time)-movetime);
        end

        MotorsSection(obj,'read_positions');        
        trial_ready_times.value = clock;  
        
        previous_rt_positions(n_started_trials) = next_rt_position;        
        

        return;
        

    
    case 'get_previous_rt_position',   % --------- CASE get_next_rt_position ------
        if isempty(value(previous_rt_positions))
            x = nan;
        else
            x = previous_rt_positions(length(previous_rt_positions));
        end
        return;

    case 'get_all_previous_rt_positions',   % --------- CASE get_next_rt_position ------
        x = value(previous_rt_positions);
        return;

    case 'get_yes_rt_position_easy'
        x = value(yes_rt_position_easy);
        return

    case 'get_no_rt_position_easy'
        x = value(no_rt_position_easy);
        return

    case 'get_num_of_rt_position'
        if value(multi_go_position)==0
            x = 1;
        else
            x = value(num_of_rt_position);
        end
        return
        
        
    
        
    case 'motors_home',     %modified by ZG 10/1/11
        disp(motors);
        disp(value(motor_num));
        move_home(motors, value(motor_num));
        return;

    case 'serial_open',
        serial_open(motors);
        return;

    case 'serial_reset',     
        close_and_cleanup(motors);
        
        global motors_properties;
        global motors; 
        
        if strcmp(motors_properties.type,'@FakeZaberAMCB2')
            motors = FakeZaberAMCB2;
        else
            motors = ZaberAMCB2;
        end
        
        serial_open(motors);
        return;

    case 'motors_stop',
        stop(motors);
        return;

    case 'motors_reset',
        reset(motors);
        return;

    case 'reset_motors_firmware',
        set_initial_parameters(motors)
        display('Reset speed, acceleration, and motor bus ID numbers.')
        return;

    case 'motor_position',
        position = value(motor_position);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(motor_num));
            motor_position.value = p;
        else
            move_absolute(motors,position,value(motor_num));
        end
        return;
        
     case 'lateral_motor_position',
        position = value(lateral_motor_position);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(lateral_motor_num));
            lateral_motor_position.value = p;
        else
            move_absolute(motors,position,value(lateral_motor_num));
        end
        return;
        
    case 'read_positions'
        p = get_position(motors,value(motor_num));
        motor_position.value = p;
        return;

     case 'read_lateral_positions'
        p = get_position(motors,value(lateral_motor_num));
        lateral_motor_position.value = p;
        return;
        
        
        
        
    case 'get_yes_rt_position_easy'
        x = value(yes_rt_position_easy);
        return
        
    case 'get_no_rt_position_easy'
        x = value(no_rt_position_easy);
        return

    case 'get_num_of_rt_position'
        x = value(num_of_rt_position);
        return
        
        
        
        
        % --------- CASE HIDE_SHOW ---------------------------------

    case 'hide_show'
        if strcmpi(value(motor_show), 'hide')
            set(value(motorfig), 'Visible', 'off');
        elseif strcmpi(value(motor_show),'view')
            set(value(motorfig),'Visible','on');
        end;
        return;


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
        return;
end


