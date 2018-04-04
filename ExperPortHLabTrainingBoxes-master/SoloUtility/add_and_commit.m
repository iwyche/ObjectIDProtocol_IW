% [] = add_and_commit(fname)
%
% Tries to add to CVS, and then commit to CVS, a file. If the extension is
% .mat, adds it in binary. Otherwise adds it in ASCII.
%
% DOES NOT CHECK TO SEE IF IT WORKED!
%
% fname may include a path, or a relative path.
%

function [] = add_and_commit(fname)

[path, fname, ext]  = fileparts(fname); fname = [fname ext];

currdir = pwd;

try,
    croot = get_cvs_root;
    % Change to right directory:
    if ~isempty(path), cd(path); end;
    
    % If necessary, add the directory:
    [myparent, mydir] = fileparts(pwd);
    if ~isempty(myparent) && ~isempty(mydir),
        cd(myparent); [s,w] = system(['cvs -d ' croot ' add -- ' mydir]);
        fprintf(1, w);
        cd(mydir);
    end;
    
    % Add the file to CVS:
    if strcmp(ext, '.mat'), [s, w] = system(['cvs -d ' croot ' add -kb -- ' fname]);
    else                    [s, w] = system(['cvs -d ' croot ' add     -- ' fname]);
    end;
    fprintf(1, w);
    
    % Now commit:
    [s, w] = system(['cvs -d ' croot ' commit -m "auto_commit" -- ' fname]);
    fprintf(1, w);
catch,
end;

cd(currdir);


function [croot] = get_cvs_root;
   [s, hname] = system('hostname');
   u = find(hname=='.'); if ~isempty(u), u=u(1); hname = hname(1:u-1); end;
   hname = lower(hname(~isspace(hname)));
   
   % HACK to make username cnmc1 always, but we should change
   % this later so rig is reflected in the username
   switch computer,
    case 'MAC',
      switch hname,
       case 'tripiscum',
         croot = sprintf(['":pserver:carlos@deprong.cshl.org/cvs"']); 
           
       otherwise,
         hname = 'cnmc1';
         croot = sprintf(['":pserver:%s:%s@' ...
                            'deprong.cshl.org/cvs"'],  hname, hname);
      end;
    
    
      % Not a MAC: --------
    otherwise,
      hname = 'cnmc1';
      croot = sprintf([':pserver;username=%s;password=%s:%s@' ...
                       'deprong.cshl.org/cvs'],  hname, hname, hname);
   end;
   
   return;
   
