% [sma] = add_state(sma, varargin)

% Written by Carlos Brody October 2006

function [sma] = add_state(sma, varargin)
   
   pairs = { ...
     'name',                 ''   ; ...
     'default_statechange'   []   ; ...
     'input_to_statechange'  {}   ; ...
     'self_timer'           100   ; ...
     'output_actions'        []   ; ...
     'iti_state'              0   ; ...
   }; parseargs(varargin, pairs);
   state_name = name;
   
   
   % --- BEGIN error_checking ---
   if ~isempty(state_name) && is_reserved(state_name),
      error(['Sorry, "' state_name '" is a reserved word, cannot ' ...
             'be used as a state name']);
   end;
   if ~isempty(state_name) && any(strcmp(state_name,sma.state_name_list(:,1))),
      error(['Sorry, "' state_name '" has already been used for a ' ...
             'different state']);
   end;
   
   input_to_statechange = rowvec(input_to_statechange');
   output_actions       = rowvec(output_actions');
   if rem(length(input_to_statechange),2) ~= 0,
      error('input_to_statechange must have an even number of elements');
   end;
   for i=1:2:length(input_to_statechange),
      if ~ischar(input_to_statechange{i}),
         error('even elements of input_to_statechange must be strings');
      end;
   end;

   if iti_state && sma.pre35_curr_state==-1,
      error(['To use the ''iti_state'' flag, you must have initialised ' ...
             'the @StateMachineAssembler with the no_dead_time_technology ' ...
             'flag']);
   end;
   
   
   % --- END error_checking ---
   

   if iti_state, this_state = sma.current_iti_state;
   else          this_state = sma.current_state;
   end;
   
   if ~isempty(state_name),
      if iti_state,
         sma.state_name_list = [sma.state_name_list ; ...
                             {state_name  this_state  1}];
      else
         sma.state_name_list = [sma.state_name_list ; ...
                             {state_name  this_state  0}];
      end;
   end;

   new_state = cell(1, rows(sma.input_map) + rows(sma.self_timer_map) + ...
                    rows(sma.output_map));

   % Default statechange:
   if isempty(default_statechange), default_statechange=this_state; end;
   for i=1:rows(sma.input_map), new_state{i} = default_statechange; end;
   
  
   % Now whatever input acts we are passed:
   for i=1:2:length(input_to_statechange),
      input       = input_to_statechange{i};
      statechange = input_to_statechange{i+1};
      
      u = find(strcmp(input, sma.input_map(:,1)));
      if isempty(u),
         error(['Don''t know input "' input '".']);
      else
         new_state{sma.input_map{u,2}} = statechange;
      end;
   end;
   % Self_timer:
   new_state{sma.self_timer_map{2}} = self_timer;
   % Default output_actions are zero:
   for i=1:rows(sma.output_map), new_state{sma.output_map{i,2}} = 0; end;
   % Now whatever we are passed:
   for i=1:2:length(output_actions),
      output = output_actions{i};
      outval = output_actions{i+1};
      
      u = find(strcmp(output, sma.output_map(:,1)));
      if isempty(u),
         error(['Don''t know output "' output '".']);
      else
         new_state{sma.output_map{u,2}} = outval;
      end;
   end;
      
      
   if ~iti_state,
      % Append as usual:
      sma.states = [sma.states ; new_state];
      sma.default_actions = [sma.default_actions ; {default_statechange}];
      sma.current_state = sma.current_state + 1;
   else
      % Append to the iti states:
      sma.iti_states = [sma.iti_states ; new_state];
      sma.default_iti_actions=[sma.default_iti_actions ; {default_statechange}];
      sma.current_iti_state = sma.current_iti_state + 1;
   end;
   