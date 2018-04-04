function [obj] = compute_next_trial(obj)

% This is the function used by SessionModel to evaluate the active training
% stage, whenever it is called (presumably, at the end of each trial in the
% session).
% If there are no more training strings to be evaluated, no values are
% changed.
% However, if there is an active training string, the following steps get
% taken:
% 1. The statement (active training string) is evaluated, and associated
% callbacks are called.
% 2. The string to test for training stage completion is evaluated. If it
% evaluates to FALSE, the training stage is retained as the active training
% stage and is evaluated again at the time of the next call to
% compute_next_trial. However, if it evaluates to TRUE, the current
% training stage is flagged as being complete, and SessionModel sets the
% next training stage (in order of registration) as being the active
% training stage. 
%

GetSoloFunctionArgs('func_owner', get_owner(obj), 'func_name', 'SessionModel');    % should now have access to all variables owned by its owner

% struct('training_stages', {{}}, ...
%    'current_train_stage', 1, ...
%    'train_string_COL', 1, ...
%    'completion_test_COL', 2, ...
%    'is_complete_COL', 3, ...
%    'name_COL', 4, ...
%    'vars_COL', 5, ...           
%    'param_owner', '' );


curr = obj.current_train_stage;
ts = get_training_stages(obj);

if curr <= rows(ts) & ~ts{curr, obj.is_complete_COL}
    eval_stmt = ts{obj.current_train_stage, obj.train_string_COL};    
    t = cellstr(eval_stmt);
    t1 = get_string(eval_stmt);
    try,
        eval(['dummy = strcat(' t1 ');']);
        eval(dummy);
    catch
        fprintf(1, ['Unable to evaluate training stage string! Error was:' ...
               lasterr]);
    end;
          
    new_curr = get_current_training_stage(value(SessionDefinition_my_session_model));
    if new_curr ~= curr % some jumping has been going on
       delete_current_sphandles(obj, curr);
       create_current_sphandles(obj, new_curr);
       
       % sync the two objects
        obj = value(SessionDefinition_my_session_model);
        return;
    end;                
    
    test_complete = ts{curr, obj.completion_test_COL};        
    t = cellstr(test_complete);
    t1 = get_string(test_complete);
    try,
        eval(['dummy = strcat(' t1 ');']);
        eval(['done = ' dummy ';']);
    catch
       fprintf(1, ['Unable to test completion of current training stage! ' ...
                   'Error was:' lasterr]);
       done = 0;
    end;

    if done > 0
       obj = mark_as_complete(obj, curr);        
       obj = set_current_training_stage_unchecked(obj, curr+1);
    end;    
else
    return; % do nothing
end;

% ------------------------------------------------------------------------
function [concat] = get_string(str)
t = cellstr(str);
concat = 't{1}';
for ctr = 2:size(t,1)
    temp = t{ctr}; t{ctr} = [' ' temp ' '];
    concat = [concat ', t{' num2str(ctr) '}'];
end;
return;


