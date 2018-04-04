function sm = softsound(a)
   
   if nargin==0,

      myfig = figure('Visible', 'off');
      mydata = struct( ...
          'samplerate',    8000,   ...
          'sound1',        [],      ...
          'sound2',        [],      ...
          'sound4',        [],      ...
          'allowed_trigs', [1 2 4]  ...
          );   
      set(myfig, 'UserData', mydata);
      
      sm = struct('myfig', myfig);      
      sm = class(sm, 'softsound');

      Initialize(sm);
      return;
      
   elseif isa(ssm, 'softsm'),
      ssm = a;
      return;
      
   else
      error(['Don''t understand this argument for creation of a ' ...
             'softsound']);
   end;
   
          