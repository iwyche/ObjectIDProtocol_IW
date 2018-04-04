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
            disp(['Real Motor!!!']);
            motors = ZaberAMCB2(motors_properties.port);
        end

%         disp('trying to open motors');
        serial_open(motors);
        disp('motors are open');
%         disp(motors);

        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]); next_row(y,1.5);
%        SoloParamHandle(obj, 'motor_num', 'value', 0);
        
        %added by ZG 10/1/11
        SoloParamHandle(obj, 'motor_num', 'value', 2);
        SoloParamHandle(obj, 'ap_motor_num', 'value', 1);
        
        % List of pole positions
        SoloParamHandle(obj, 'previous_pole_distances', 'value', []);
        SoloParamHandle(obj, 'previous_pole_ap_positions', 'value', []);
        SoloParamHandle(obj, 'previous_pole_angles', 'value', []);        
        
        % Set limits in microsteps for actuator. Range of actuator is greater than range of
        % our Del-Tron sliders, so must limit to prevent damage.  This limit is also coded into Zaber
        % TCD1000 firmware, but exists here to keep GUI in range. If a command outside this range (0-value)
        % motor driver gives error and no movement is made.
        SoloParamHandle(obj, 'motor_max_position', 'value', 180000);  
        SoloParamHandle(obj, 'trial_ready_times', 'value', 0);

        MenuParam(obj, 'motor_show', {'view', 'hide'}, 'view', x, y, 'label', 'Motor Control', 'TooltipString', 'Control motors');
        set_callback(motor_show, {mfilename,'hide_show'});

        next_row(y);
        SubheaderParam(obj, 'sectiontitle', 'Motor Control', x, y);

        parentfig_x = x; parentfig_y = y;
       
        
        % ---  Make new window for motor configuration
        SoloParamHandle(obj, 'motorfig', 'saveable', 0);
        motorfig.value = figure('Position', [10 900 500 240], 'Menubar', 'none',...
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
        
        PushButtonParam(obj, 'read_distance', x, y, 'label', 'Read distance');
        set_callback(read_distance, {mfilename, 'read_distance'});

        next_row(y);
               
        NumeditParam(obj, 'motor_distance', 0, x, y, 'label', ...
            'Motor distance','TooltipString','Absolute position in microsteps of motor.');
        set_callback(motor_distance, {mfilename, 'motor_distance'});

        next_row(y)
        PushButtonParam(obj, 'read_ap_positions', x, y, 'label', 'Read anterior-posterior position');
        set_callback(read_ap_positions, {mfilename, 'read_ap_positions'});

        next_row(y);
        NumeditParam(obj, 'ap_motor_position', 140000, x, y, 'label', ...
            'anterio-posterior_motor_position','TooltipString','Absolute position in microsteps of motor.');
        set_callback(ap_motor_position, {mfilename, 'ap_motor_position'});
        
        next_row(y);
        SubheaderParam(obj, 'title', 'Read/set position', x, y);
       
        next_column(x); y = 1;
        
        %--------------- two set positions --------------------------------
        % Radial distance        
        NumeditParam(obj, 'far_dist', 60000, x, y, 'label', ...
            'Farthest distance','TooltipString','The smaller the further away');
        
        next_row(y);
        NumeditParam(obj, 'near_dist', 120000, x, y, 'label', ...
            'Nearest distance','TooltipString','The larger the closer');
        
        next_row(y);
        NumeditParam(obj, 'dist_wo_dstr', 100000, x,y, 'label', ...
            'Distance w/o distractor', 'TooltipString', 'Will be used when Distractor is OFF');
        
        % Angle
        next_row(y);
        NumeditParam(obj, 'pole_angle', 45, x, y, 'label', ...
            'Angle','TooltipString','Angle will be the same for left and right choice. Only the sign will differ');
        
        next_row(y);
        NumeditParam(obj, 'angle_wo_dstr', 45, x, y, 'label', ...
            'Angle w/o distractor', 'TooltipString', 'Will be used when Distractor is OFF'); 
        
        next_row(y);
        NumeditParam(obj, 'angle_offset', 0, x, y, 'label', ...
            'Angle offset', 'TooltipString', 'Angle added for vertical whisking compensation'); 
        
        next_row(y);
        NumeditParam(obj, 'nearup_offset', 5000, x, y, 'label', ...
            'Near up position offset (+)', 'TooltipString', 'Microstepts to be added for L-dL trials to minimize differences in contact angles'); 
        
        next_row(y);
        NumeditParam(obj, 'farup_offset', 0, x, y, 'label', ...
            'Far up position offset (+)', 'TooltipString', 'Microstepts to be added for R-dL trials to minimize differences in contact angles'); 

        next_row(y);
        NumeditParam(obj, 'fardown_offset', 0, x, y, 'label', ...
            'Far down position offset (+)', 'TooltipString', 'Microstepts to be added for R-dL trials to minimize differences in contact angles'); 
                
        next_row(y);
        NumeditParam(obj, 'ap_set_position', 30000, x, y, 'label', ...
            'AP position');
        
        next_row(y);
        NumeditParam(obj, 'apjitter_max', 0, x, y, 'label', ...
            'Max AP axis jitter (-)', 'TooltipString', 'random position variation in AP axis');

        %-----------------------------------------------------------
        
        next_row(y);
        NumeditParam(obj, 'motor_move_time', 0, x, y, 'label', ...
            'motor move time','TooltipString','set up time for motor to move.');

        next_row(y);
        SubheaderParam(obj, 'title', 'Trial position', x, y);
        
        MotorsSection(obj,'hide_show');
        MotorsSection(obj,'read_distance');
        MotorsSection(obj,'read_ap_positions');
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure',value(myfig));
        
        next_absolute_angle = 90;
        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'next_absolute_angle'}); 
        MotorsSection(obj, 'move_next_side');
        
        return;

    case 'move_next_side', % --------- CASE MOVE_NEXT_SIDE -----
        [next_side, next_dstr] = SidesSection(obj,'get_next_side');
        if next_side=='o' % no-go catch trial 2017/11/24 JK
            next_pole_dist = 0;
            next_pole_sign = 'm';
            next_pole_angle = value(round(double(angle_wo_dstr))) ;            
        else
            if strcmp(Distractor, 'Off')

                next_pole_angle = value(round(double(angle_wo_dstr))) ;

                if strcmp(TaskTarget,'Angle')
                    if next_side == 'r'
                        next_pole_sign = 'r'; 
                    elseif next_side == 'l'
                        next_pole_sign = 'l'; 
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_dist = value(dist_wo_dstr);                
                    ap_offset_factor_dist = 1; % The offset factor for determining how far the pole should go to posterior direction, depending on the combination of angle and the position

                elseif strcmp(TaskTarget,'RadialDistance')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist);
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist);
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_sign = 'm';                 
                    ap_offset_factor_dist = 0;
                elseif strcmp(TaskTarget, 'Angle-Continuous') 
                    if next_side == 'r'
                        next_pole_sign = 'ar'; % random-right
                    elseif next_side == 'l'
                        next_pole_sign = 'al'; % random-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_dist = value(dist_wo_dstr);
                    ap_offset_factor_dist = 1;
                elseif strcmp(TaskTarget, 'Angle-Discrete')
                    if next_side == 'r'
                        next_pole_sign = 'dr'; % random-discrete-right
                    elseif next_side == 'l'
                        next_pole_sign = 'dl'; % random-discrete-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_dist = value(dist_wo_dstr);
                    ap_offset_factor_dist = 1;                                       
                elseif strcmp(TaskTarget, 'RadialDistance-Continuous')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + rand/2 * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - rand/2 * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_sign = 'm'; 
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));
                elseif strcmp(TaskTarget, 'RadialDistance-Discrete')
                    discrete_rand = [0,0.25,0.5];
                    rand_ind = ceil(rand*3);
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_sign = 'm'; 
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));
                else
                    error('un-recognized type for task (angle or radial distance)');
                end
                
            elseif strcmp(Distractor, 'On')
                next_pole_angle = value(round(double(pole_angle))) ;

                if strcmp(TaskTarget,'Angle')
                    if next_side == 'r'
                        next_pole_sign = 'r'; 
                    elseif next_side == 'l'
                        next_pole_sign = 'l'; 
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    if next_dstr == 'c'
                        next_pole_dist = value(near_dist);
                    elseif next_dstr == 'f'
                        next_pole_dist = value(far_dist);
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again.
                        if rand < 0.5; next_dstr = 'c'; next_pole_dist = value(near_dist);
                        else next_dstr = 'f'; next_pole_dist = value(far_dist); 
                        end                    
                    else% no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget,'RadialDistance')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist);
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist);
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    if next_dstr == 'c'
                        next_pole_sign = 'l'; 
                    elseif next_dstr == 'f'
                        next_pole_sign = 'r'; 
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again. 
                        if rand < 0.5; next_dstr = 'c'; next_pole_sign = 'l';
                        else next_dstr = 'f'; next_polse_sign = 'r';
                        end                
                    else % no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Continuous')
                    if next_side == 'r'
                        next_pole_sign = 'ar'; % random-right
                    elseif next_side == 'l'
                        next_pole_sign = 'al'; % random-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    if next_dstr == 'c'
                        next_pole_dist = value(near_dist);
                    elseif next_dstr == 'f'
                        next_pole_dist = value(far_dist);
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again.
                        if rand < 0.5; next_dstr = 'c'; next_pole_dist = value(near_dist);
                        else next_dstr = 'f'; next_pole_dist = value(far_dist); 
                        end                    
                    else% no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Discrete')
                    if next_side == 'r'
                        next_pole_sign = 'dr'; % random-discrete-right
                    elseif next_side == 'l'
                        next_pole_sign = 'dl'; % random-discrete-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    if next_dstr == 'c'
                        next_pole_dist = value(near_dist);
                    elseif next_dstr == 'f'
                        next_pole_dist = value(far_dist);
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again.
                        if rand < 0.5; next_dstr = 'c'; next_pole_dist = value(near_dist);
                        else next_dstr = 'f'; next_pole_dist = value(far_dist); 
                        end                    
                    else% no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));                

                elseif strcmp(TaskTarget, 'RadialDistance-Continuous')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + rand/2 * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - rand/2 * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end

                    if next_dstr == 'c'
                        next_pole_sign = 'l'; 
                    elseif next_dstr == 'f'
                        next_pole_sign = 'r'; 
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again. 
                        if rand < 0.5; next_dstr = 'c'; next_pole_sign = 'l';
                        else next_dstr = 'f'; next_polse_sign = 'r';
                        end                
                    else % no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'RadialDistance-Discrete')
                    discrete_rand = [0,0.25,0.5];
                    rand_ind = ceil(rand*3);
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    if next_dstr == 'c'
                        next_pole_sign = 'l'; 
                    elseif next_dstr == 'f'
                        next_pole_sign = 'r'; 
                    elseif next_dstr == 'n' || 'a' % when an error occurred, set next_dstr again. 
                        if rand < 0.5; next_dstr = 'c'; next_pole_sign = 'l';
                        else next_dstr = 'f'; next_polse_sign = 'r';
                        end                
                    else % no next_dstr
                        error('No distractor specified')
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));                

                else
                    error('un-recognized type for task (angle or radial distance)');
                end
                
            elseif strcmp(Distractor, 'Continuous')
                next_pole_angle = value(pole_angle);

                if strcmp(TaskTarget,'Angle')
                    if next_side == 'r'
                        next_pole_sign = 'r'; 
                    elseif next_side == 'l'
                        next_pole_sign = 'l'; 
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    next_pole_dist = value(far_dist) + round(rand*(value(near_dist) - value(far_dist)));
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget,'RadialDistance')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist);
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist);
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    next_pole_sign = 'a'; % a meaning rAndom

                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Continuous')
                    if next_side == 'r'
                        next_pole_sign = 'ar'; % random-right
                    elseif next_side == 'l'
                        next_pole_sign = 'al'; % random-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    next_pole_dist = value(far_dist) + round(rand*(value(near_dist) - value(far_dist)));

                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Discrete')
                    if next_side == 'r'
                        next_pole_sign = 'dr'; % random-discrete-right
                    elseif next_side == 'l'
                        next_pole_sign = 'dl'; % random-discrete-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_dist = value(far_dist) + round(rand*(value(near_dist) - value(far_dist)));
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));    


                elseif strcmp(TaskTarget, 'RadialDistance-Continuous')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + round(rand*(value(near_dist) - value(far_dist)));
                    elseif next_side == 'l'
                        next_pole_dist = value(far_dist) - round(rand*(value(near_dist) - value(far_dist)));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_sign = 'a'; % a meaning rAndom                
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'RadialDistance-Discrete')
                    discrete_rand = [0,0.25,0.5];
                    rand_ind = ceil(rand*3);
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    next_pole_sign = 'a'; % a meaning rAndom
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));      

                else
                    error('un-recognized type for task (angle or radial distance)');
                end
            elseif strcmp(Distractor, 'Discrete')
                next_pole_angle = value(pole_angle);

                if strcmp(TaskTarget,'Angle')
                    if next_side == 'r'
                        next_pole_sign = 'r'; 
                    elseif next_side == 'l'
                        next_pole_sign = 'l'; 
                    else
                        error('un-recognized type of choice (left or right)');
                    end                
                    discrete_rand = linspace(0,1,5);
                    rand_ind = ceil(rand*5);
                    next_pole_dist = value(far_dist) + round(discrete_rand(rand_ind)*(value(near_dist) - value(far_dist)));
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget,'RadialDistance')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist);
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist);
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    if rand < 0.5
                        next_pole_sign = 'dl';
                    else
                        next_pole_sign = 'dr';
                    end

                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Continuous')
                    if next_side == 'r'
                        next_pole_sign = 'ar'; % random-right
                    elseif next_side == 'l'
                        next_pole_sign = 'al'; % random-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end

                    discrete_rand = linspace(0,1,5);
                    rand_ind = ceil(rand*length(discrete_rand));
                    next_pole_dist = value(far_dist) + round(discrete_rand(rand_ind)*(value(near_dist) - value(far_dist)));                
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'Angle-Discrete')
                    if next_side == 'r'
                        next_pole_sign = 'dr'; % random-discrete-right
                    elseif next_side == 'l'
                        next_pole_sign = 'dl'; % random-discrete-left
                    else
                        error('un-recognized type of choice (left or right)');
                    end
                    discrete_rand = linspace(0,1,5);
                    rand_ind = ceil(rand*length(discrete_rand));
                    next_pole_dist = value(far_dist) + round(discrete_rand(rand_ind)*(value(near_dist) - value(far_dist)));     
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'RadialDistance-Continuous')
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + round(rand*(value(near_dist) - value(far_dist)));
                    elseif next_side == 'l'
                        next_pole_dist = value(far_dist) - round(rand*(value(near_dist) - value(far_dist)));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    if rand < 0.5
                        next_pole_sign = 'dl';
                    else
                        next_pole_sign = 'dr';
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));

                elseif strcmp(TaskTarget, 'RadialDistance-Discrete')
                    discrete_rand = linspace(0,0.5,3);
                    rand_ind = ceil(rand*length(discrete_rand));
                    if next_side == 'r'
                        next_pole_dist = value(far_dist) + discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    elseif next_side == 'l'
                        next_pole_dist = value(near_dist) - discrete_rand(rand_ind) * (value(near_dist) - value(far_dist));
                    else 
                        error('un-recognized type of choice (left or right)');
                    end
                    if rand < 0.5
                        next_pole_sign = 'dl';
                    else
                        next_pole_sign = 'dr';
                    end
                    ap_offset_factor_dist = (next_pole_dist - value(far_dist)) / (value(near_dist) - value(far_dist));      

                else
                    error('un-recognized type for task (angle or radial distance)');
                end
            else % No information about Distractor
                error('No variable named Distractor exists')
            end
        end

        angle_offset = value(angle_offset);
        if next_pole_sign == 'r'
            next_absolute_angle = next_pole_angle + angle_offset;
        elseif next_pole_sign == 'l'
            next_absolute_angle = 180 - next_pole_angle + angle_offset;
        elseif next_pole_sign == 'm' % in the middle, not r nor l. -> use angle_wo_dist
            next_absolute_angle = next_pole_angle + angle_offset;
        elseif next_pole_sign == 'a' % for continuous angle distractor (rAndom)
            next_absolute_angle = next_pole_angle + angle_offset + round(rand * (90-next_pole_angle));
        elseif strcmp(next_pole_sign, 'ar') % continous angle target, with right reward
            next_absolute_angle = next_pole_angle + floor(rand*(90-next_pole_angle)) + angle_offset;
        elseif strcmp(next_pole_sign, 'al') % continous angle target, with left reward
            next_absolute_angle = (180 - next_pole_angle) - floor(rand*(90-next_pole_angle)) + angle_offset;            
        elseif strcmp(next_pole_sign, 'dr') % discrete angle target set 1, with right reward
            temp_angle_list = linspace(0,45,4);
            temp_rand = ceil(rand * length(temp_angle_list));
            next_absolute_angle = next_pole_angle + temp_angle_list(temp_rand) + angle_offset;
        elseif strcmp(next_pole_sign, 'dl') % discrete angle target set 1, with left reward
            temp_angle_list = linspace(0,45,4);
            temp_rand = ceil(rand * length(temp_angle_list));
            next_absolute_angle = (180 - next_pole_angle) - temp_angle_list(temp_rand) + angle_offset;            
        else
            error('un-recognized pole angle sign')
        end
        
        if next_pole_angle < 90
%             ap_offset_factor_angle = (next_absolute_angle - angle_offset
%             - next_pole_angle)/(180 - 2 * next_pole_angle);    
            ap_offset_factor_angle = 0;
        else
            ap_offset_factor_angle = 0;
        end
%         ap_offset_dist = determined up above;        
        apjitter = (rand)* value(apjitter_max);
        disp(['jitter = ',num2str(apjitter)])
        
        
        ap_position = round(value(ap_set_position));
        if next_side=='o'
            ap_move = 0;
        else
            if next_absolute_angle <= 90 % right, down
                ap_move = floor(ap_position - apjitter + fardown_offset * (1-ap_offset_factor_dist));
            else
                ap_move = floor(ap_position - apjitter + nearup_offset + (farup_offset - nearup_offset) * (1-ap_offset_factor_dist));
%             ap_move = floor(ap_position - apjitter) + fardown_offset * (1-ap_offset_factor_dist) + farup_offset * ap_offset_factor_angle + (nearup_offset - farup_offset) * ap_offset_factor_angle * ap_offset_factor_dist; % Changed from + apjitter to - apjitter 
%             ap_move = floor(ap_position - apjitter) + fardown_offset * (1-ap_offset_factor_dist) + (nearup_offset - farup_offset) * ap_offset_factor_dist; 
%             ap_move = floor(ap_position - apjitter) + fardown_offset * (1-ap_offset_factor_dist); % Changed from + apjitter to - apjitter 
            end
        end
        % when the pole representation direction is changed from lateral to caudal 2016/07/02 JK
        % Changed to have 2 factors to compensate for touch angle
        % differences. offsets should be within 0~1 2017/02/23 JK. 

        if strcmp(Catch,'On')
            half_point = round(value(far_dist+near_dist)/4);
            ap_half_position = round(value(ap_set_position)/2);            
        else
            half_point = round(value(far_dist+near_dist)/2);
            ap_half_position = round((value(ap_set_position) -apjitter)/2);
        end            
        
        tic
%         move_angle(handle,{90, next_absolute_angle});
        move_absolute_sequence(motors,{ap_half_position,ap_move},value(ap_motor_num));
        move_absolute_sequence(motors,{half_point,next_pole_dist},value(motor_num));
        movetime = toc;
        if movetime<value(motor_move_time) % Should make this min-ITI a SoloParamHandle
            pause( value(motor_move_time)-movetime);
        end
        
        disp(['ap_move = ', num2str(ap_move)]);
%         disp(['radial distance = ', num2str(next_pole_dist)]);
%         disp(['ap_offset_factor_dist = ', num2str(ap_offset_factor_dist)]);        

        MotorsSection(obj,'read_distance');       
        MotorsSection(obj,'read_ap_positions');        
        trial_ready_times.value = clock;  

        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'next_absolute_angle'}); % Moving pole angle is done with state matrix via arduino
        
%         previous_pole_distances(n_started_trials) = next_pole_dist;
%         previous_pole_ap_positions(n_started_trials) = ap_move;
%         previous_pole_angles(n_started_trials) = next_absolute_angle;

        previous_pole_distances(n_started_trials+1) = next_pole_dist;
        previous_pole_ap_positions(n_started_trials+1) = ap_move;
        previous_pole_angles(n_started_trials+1) = next_absolute_angle;

        return;
        

    
    case 'get_previous_pole_position',   % --------- CASE get_next_pole_position ------
        if isempty(value(previous_pole_distances))
            x = nan;
        else
            x = previous_pole_distances(length(previous_pole_distances));
        end
        return;

    case 'get_all_previous_pole_distances',   % --------- CASE get_next_pole_position ------
        x = value(previous_pole_distances);
        return;

%     case 'get_yes_pole_position_easy'
%         x = value(yes_pole_position_ant);
%         return
% 
%     case 'get_no_pole_position_easy'
%         x = value(no_pole_position_pos);
%         return
% 
%     case 'get_num_of_pole_position'
%        
%             x = 1;
%         return
% I don't think I need these 2016/06/11 JK              
        
    
        
    case 'motors_home',     %modified by ZG 10/1/11
%         disp(motors);
%         disp(value(motor_num));
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

    case 'motor_distance',
        position = value(motor_distance);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(motor_num));
            motor_distance.value = p;
        else
            move_absolute(motors,position,value(motor_num));
        end
        return;
        
     case 'ap_motor_position',
        position = value(ap_motor_position);
        if position > value(motor_max_position) | position < 0
            p = get_position(motors,value(ap_motor_num));
            ap_motor_position.value = p;
        else
            move_absolute(motors,position,value(ap_motor_num));
        end
        return;
        
    case 'read_distance'
        p = get_position(motors,value(motor_num));
        motor_distance.value = p;
        return;

     case 'read_ap_positions'
        p = get_position(motors,value(ap_motor_num));
        ap_motor_position.value = p;
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


