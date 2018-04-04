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
            motors = ZaberAMCB2(motors_properties.port);
        end
       
        serial_open(motors);

        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]); next_row(y,1.5);
        SoloParamHandle(obj, 'motor_num', 'value', 0);

        % Set limits in microsteps for actuator. Range of actuator is greater than range of
        % our Del-Tron sliders, so must limit to prevent damage.  This limit is also coded into Zaber
        % TCD1000 firmware, but exists here to keep GUI in range. If a command outside this range (0-value)
        % motor driver gives error and no movement is made.
        SoloParamHandle(obj, 'motor_max_position', 'value', 180000);  
        SoloParamHandle(obj, 'trial_ready_times', 'value', 0);

        MenuParam(obj, 'motor_show', {'view', 'hide'}, 'hide', x, y, 'label', 'Motor Control', 'TooltipString', 'Control motors');
        set_callback(motor_show, {mfilename,'hide_show'});

        next_row(y,1.5);
        SubheaderParam(obj, 'sectiontitle', 'Motor Control', x, y);

        parentfig_x = x; parentfig_y = y;
       
        
        % ---  Make new window for motor configuration
        SoloParamHandle(obj, 'motorfig', 'saveable', 0);
        motorfig.value = figure('Position', [3 500 400 200], 'Menubar', 'none',...
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
        next_row(y);


        next_column(x); y = 1;
        
        PushButtonParam(obj, 'read_positions', x, y, 'label', 'Read position');
        set_callback(read_positions, {mfilename, 'read_positions'});
        
        next_row(y);
        NumeditParam(obj, 'motor_position', 0, x, y, 'label', ...
            'Motor position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(motor_position, {mfilename, 'motor_position'});
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Read/set position', x, y);

        next_row(y);
        NumeditParam(obj, 'nogo_position', 45000, x, y, 'label', ...
            'No-go position','TooltipString','No-go trial position in microsteps.');
        
        next_row(y);
        NumeditParam(obj, 'go_position', 0, x, y, 'label', ...
            'Go position','TooltipString','Go trial position in microsteps.');
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Trial position', x, y);


        MotorsSection(obj,'hide_show');
        MotorsSection(obj,'read_positions');
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure',value(myfig));
        return;

    case 'move_next_side', % --------- CASE MOVE_NEXT_SIDE -----
       
        next_side = SidesSection(obj,'get_next_side');
         
        % Manually start pedestal at mid-point (90000).
        if next_side == 'r'
              position = value(go_position);
        elseif next_side == 'l'
              position = value(nogo_position);
        else
            error('Invalid next side.')
        end
        
        halfpoint = abs(round((value(nogo_position)-value(go_position))/2)) + min(value(nogo_position),value(go_position));
%         if Solo_Try_Catch_Flag == 1
%             try
%                 move_absolute_sequence(motors,{90000,position},value(right_motor_num));
%             catch
%                 pause(1)
%                 warning('Error in move_absolute_sequence, forcing state 35...');
%                 SMControlSection(obj,'force_state_35');
%                 return
%             end
%         else
             tic
             move_absolute_sequence(motors,{halfpoint,position},value(motor_num));
             movetime = toc;
             if movetime<1.9 % Should make this min-ITI a SoloParamHandle
                 pause(1.9-movetime); %4
             end
%         end
        
         
        previous_sides(n_started_trials+1) = next_side;
        MotorsSection(obj,'read_positions');
        
%         trial_ready_times.value = datestr(now);
        trial_ready_times.value = clock;
        
        return;
        
    case 'motors_home',
        move_home(motors);
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

    case 'read_positions'
        p = get_position(motors,value(motor_num));
        motor_position.value = p;
        return;

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


