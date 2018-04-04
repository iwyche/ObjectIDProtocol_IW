% [stm] = assemble(sma)

% Written by Carlos Brody October 2006

function [stm] = assemble(sma)

   TupCol = sma.input_map{find(strcmp('Tup', sma.input_map(:,1))), 2};

   base_iti_state = rows(sma.states);
   if sma.pre35_curr_state == 1,
      sma.states(36,1:TupCol) = num2cell(base_iti_state*ones(1,TupCol));
   end;

   sma.states = [sma.states ; sma.iti_states];

   stm = zeros(size(sma.states));

   sw_outcol = find(strcmp('SchedWaveTrig', sma.output_map(:,1)));
   if ~isempty(sw_outcol), sw_outcol = sma.output_map{sw_outcol,2}; end;

   for i=1:rows(sma.state_name_list),
      if sma.state_name_list{i,3} == 0,
         eval([lower(sma.state_name_list{i,1}) ' = ' ...
               num2str(sma.state_name_list{i,2}) ';']);
      else
         eval([lower(sma.state_name_list{i,1}) ' = base_iti_state + ' ...
               num2str(sma.state_name_list{i,2}) ';']);
      end;
   end;

   for i=1:rows(stm),
      for j=1:cols(stm),
         if isnumeric(sma.states{i,j}), 
            stm(i,j) = sma.states{i,j};
            if j <= TupCol && i > base_iti_state, 
               stm(i,j) = stm(i,j) + base_iti_state;
            end;
         else
            current_state = i-1;
            if ~isempty(sw_outcol) && j==sw_outcol,
               stm(i,j) =  resolve_schedwave_strs(i-1, sma.states{i,j}, ...
                                                  sma.sched_waves);
            else
               try, 
                  entry = eval(lower(sma.states{i,j}));
                  
                  if ~isnumeric(entry), error_message(i-1, sma.states{i,j});
                  end;
                  
               catch,
                  error_message(i-1, sma.states{i,j});
               end;
               stm(i,j) = entry;
               
               % stm(i,j)=resolve_strs(i-1,sma.states{i,j}, ...
               % sma.state_name_list);
            end;
         end;
      end;
   end;
   
   
% -------------

function [] = error_message(current_state, str)

   error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                  'in state %d, the entry "%s" ' ...
                  'could not be resolved!!!\n'], current_state,str));
   
   
   
% -------------

function [entry] = resolve_strs(current_state, str, state_names)
   
   for i=1:rows(state_names),
      eval([lower(state_names{i,1}) ' = ' num2str(state_names{i,2}) ';']);
   end;
   
   try,
      entry = eval(lower(str));
   
      if ~isnumeric(entry),
         error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                        'in state %d, the entry "%s" ' ...
                        'could not be resolved!!!\n'], current_state,str));
      end;
   catch,
      error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                     'in state %d, the entry "%s" ' ...
                     'could not be resolved!!!\n'], current_state,str));
   end;
   
   return;
   
   
% -----------

function [entry] = resolve_schedwave_strs(current_state, str, sched_waves)
   
   for i=1:length(sched_waves),
      eval([sched_waves(i).name ' = 2.^(' num2str(sched_waves(i).id) ');']);
   end;
   
   try,
      entry = eval(str);
   
      if ~isnumeric(entry),
         error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                        'in state %d, the SchedWaveTrig entry "%s" ' ...
                        'could not be resolved!!!\n'], current_state,str));
      end;
   catch,
      error(sprintf(['StateMachineAssembler ERROR:\n\n' ...
                     'in state %d, the SchedWaveTrig entry "%s" ' ...
                     'could not be resolved!!!\n'], current_state,str));
   end;
   