% [t, errnum, message] = interpolate_value(wt, valve, dispense,
%              {'maxdays_error', 10}, {'maxdistance', 0.15}, {'gui_warning', 0})
%
% Main function for a WaterCalibrationTable! given a table, a
% valvename, and a desired dispense amount, it tries to calculate how
% much time the valve should be open in order to dispense that
% amount. Only locally linear calculations, near entries in the water
% table, are allowed. Anything further away produces a warning message
% and no result.
%
% PARAMETERS:
% -----------
%
% wt        A WaterCalibrationTable object
%
% valve     A string identifying the name of the valve we're talking
%           about
%
% dispense  The desired dispense volume, in uL.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% maxdays_error   Any entries more than this days old are discarded from
%                 the table before any calculation begins. Default is 100,
%                 meaning that if you don't calibrate in 100 days, it is as
%                 if you had no entries at all!
%
% maxdays_warning   If no entries more recent than this days old, a warning
%                   is generated. Default is 10 days. Added by GF 12/19/06.
%
% maxdistance  Default 0.15. This is the maximum fractional distance
%              away from an entry in the water table that your request
%              can be. For example, say the only entry is for 20 uL,
%              and you ask for 23 uL. That is exactly 20*1.15 = 0.15
%              away, so you will get an answer. If, however, you ask
%              for 24 uL, the answer will be "I don't know-- too far
%              away from known points!"
%
% gui_warning  Default 0. If set to 1, then when there is no
%              well-defined answer (because of maxdays or maxdistance)
%              a little warning window saying so pops up. This window
%              does not halt other processing or anything, it just pops
%              up and quietly stays there until clicked away.
%
% RETURNS:
% --------
%
% t            How long to open the valve for in order to get the
%              requested amount of water. If an error occurred (see
%              above), this returns as NaN
%
% error        Error number: 1 means no valve with the name you asked
%              for exists in the table.; 2 means maxdays was exceeded;
%              3 means maxdistance was exceeded.
% 
% message      A text string that reports the error in human-readable
%              form (if an error occurred, otherwise empty). 
%


function [t, errnum, message] = interpolate_value(wt, valve, dispense,varargin)
   
   pairs = { ...
     'maxdays_error'       1000  ; ...
     'maxdays_warning'       10  ; ...
     'maxdistance'   0.15  ; ...
     'gui_warning'    0    ; ...
   }; parseargs(varargin, pairs);
   errnum = 0; message = '';

   [valves, times, dispenses, dates] = deal_table(wt);
   
   wt = wt(find(strcmp(valve, valves)));
   [valves, times, dispenses, dates] = deal_table(wt);
   if isempty(wt),
      t = NaN; errnum = 1;
      message = sprintf('No valve named "%s" found in table.', valve);
      if gui_warning,
         fnum = gcf;
         errordlg(message, 'Water Calibration Table Manager');
         figure(fnum);
      end;
      return;
   end;
   
   
   % if no calibration entries within maxdays_warning, generate warning
   % message
   if length(find(now - dates <= maxdays_warning)) == 0 
   
      most_recent = floor(min(now - dates));
      message = sprintf(['Most recent calibration measurement for %s was ' ...
                         '%g days ago. This is only a warning.'], valve, most_recent);
      if gui_warning,
         fnum = gcf;
         errordlg(message, 'Water Calibration Table Manager');
         figure(fnum);
      end;

   end
   
   wt = wt(find(now - dates <= maxdays_error));
   [valves, times, dispenses, dates] = deal_table(wt);
   % if no calibration entries within maxdays_error, generate error
   % message
   if isempty(wt),
      t = NaN;
      errnum = 2;
      message = sprintf(['No calibration measurements for %s less than ' ...
                         '%g days old'], valve, maxdays_error);
      if gui_warning,
         fnum = gcf;
         errordlg(message, 'Water Calibration Table Manager');
         figure(fnum);
      end;
      return;
   end;
   
   wt = wt(find(abs(log(dispenses) - log(dispense)) <= ...
                abs(log(1+maxdistance))));
   [valves, times, dispenses, dates] = deal_table(wt);
   if isempty(wt),
      t = NaN;
      errnum = 3;
      message = sprintf(['No calibration measurements for %s less than ' ...
                         'a factor of %g away'], valve, maxdistance);
      if gui_warning,
         fnum = gcf;
         errordlg(message, 'Water Calibration Table Manager');
         figure(fnum);
      end;
      return;
   end;
   

   times = [0 times]; dispenses = [0 dispenses];
   [times, I] = sort(times); dispenses = dispenses(I);
   
   if dispense<=max(dispenses)
      t = interp1(dispenses, times, dispense);
      message = '';
      return;
   else
      dtimes = diff(times); ddispenses = diff(dispenses);
      dtimes = dtimes(end); ddispenses = ddispenses(end);
      if ddispenses<=0,
         dtimes = diff(times([1 end])); 
         ddispenses = diff(dispenses([1 end]));
      end;
      
      t = times(end) + (dtimes/ddispenses)*(dispense - dispenses(end));
      message = '';
   end;
   
   