% [] = send(sma, sm)

% Written by Carlos Brody October 2006

function [] = send(sma, sm)
   
   stm = assemble(sma);
   
   
   % --- Make right number of inputs ---
   
   input_map = sma.input_map;
   u = find(~strcmp('Tup', input_map(:,1)));
   input_map = input_map(u,:);
   
   inputcols    = cell2mat(input_map(:,2)');
   inputrouting = zeros(size(inputcols));
   for i=1:length(inputcols),
       switch input_map{i,1},
           case 'Cin',  inputrouting(i) = +1;
           case 'Cout', inputrouting(i) = -1;
           case 'Lin',  inputrouting(i) = +2;
           case 'Lout', inputrouting(i) = -2;
           case 'Rin',  inputrouting(i) = +3;
           case 'Rout', inputrouting(i) = -3;
           otherwise,   inputrouting(i) = 0;
       end;
   end; 
   sm = SetInputEvents(sm, inputrouting, 'ai');

   
   % --- Now outputs ---
   outputs = {};
   for i=1:rows(sma.output_map),
      switch sma.output_map{i,1},
       case 'DOut', 
         outputs = [outputs ; ...
                    {struct('type', 'dout', 'data', '0-15')}];
         
       case 'SoundOut',
         outputs = [outputs ; ...
                    {struct('type', 'sound', 'data', '0')}];
         
       case 'SchedWaveTrig',
         outputs = [outputs ; ...
                    {struct('type', 'sched_wave', 'data', [])}];
      end;
   end;
   
   sm = SetOutputRouting(sm, outputs);
   
   
   % --- Now sched waves ---
   swm = [];
   for i=1:length(sma.sched_waves),
      swm = [swm ; sma.sched_waves(i).id sma.sched_waves(i).in_column-1 ...
             sma.sched_waves(i).out_column-1 sma.sched_waves(i).dio_line ...
             sma.sched_waves(i).preamble sma.sched_waves(i).sustain ...
             sma.sched_waves(i).refraction];
   end;
   if ~isempty(swm),
      sm = SetScheduledWaves(sm, swm);
   end;
   
   sm = SetStateMatrix(sm, stm, 1);
   
   