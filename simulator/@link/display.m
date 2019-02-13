function display(k)

% LINK class display function

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

if isempty(k)
  fprintf(1, ' %dx%d LINK object array\n', size(k));    
elseif length(k) ==1  % Single link
  if isempty(k.fromID)
    fprintf(1, ' Empty LINK object\n');
  elseif ~isstruct(k.pathLoss) % Node self-link
    fprintf(1, ' %dx%d LINK object with ID:\n', size(k));
    fprintf(1, '\n   ''%s:%s'' -> ''%s:%s:%.2f MHz''  (SELF LINK)\n', ...
            k.fromID{1}, k.fromID{2}, ...
            k.toID{1}, k.toID{2}, k.toID{3}/1e6);
    disp(['   ', inputname(1), '.channel'])
    disp(k.channel)
    %disp(['   ', inputname(1), '.pathLoss'])
    %disp(k.pathLoss)
    %disp(['   ', inputname(1), '.propParams'])
    %disp(k.propParams)        
    fprintf(1, '\n');
  else
    fprintf(1, '\n   ''%s:%s'' -> ''%s:%s:%.2f Mhz''\n', ...
            k.fromID{1}, k.fromID{2}, ...
            k.toID{1}, k.toID{2}, k.toID{3}/1e6);
    fprintf(1, '\n');        
    fprintf(1, '        channel.\n');
    disp(k.channel)
    fprintf(1, '\n');
    fprintf(1, '       pathLoss.\n');
    disp(k.pathLoss)
    fprintf(1, '\n');
    fprintf(1, '     propParams.\n');            
    disp(k.propParams)
    fprintf(1, '\n');  
  end
else
  fprintf(1, ' %dx%d LINK object array with ID''s:\n', size(k));    
  for kLoop = 1:length(k)
    if isempty(k(kLoop).fromID)
      fprintf(1, '   Empty LINK object\n');
    elseif ~isstruct(k(kLoop).pathLoss) % Node self-link
      fprintf(1, '\n   ''%s:%s'' -> ''%s:%s:%.2f Mhz''  (Self Link)\n', ...
              k(kLoop).fromID{1}, k(kLoop).fromID{2}, ...
              k(kLoop).toID{1}, k(kLoop).toID{2}, k(kLoop).toID{3}/1e6);
      disp(['   ', inputname(1), '.channel'])
      disp(k(kLoop).channel)
      %disp(['   ', inputname(1), '.pathLoss'])
      %disp(k(kLoop).pathLoss)
      %disp(['   ', inputname(1), '.propParams'])
      %disp(k(kLoop).propParams)            
      fprintf(1, '\n');
    else
      fprintf(1, '\n   ''%s:%s'' -> ''%s:%s:%.2f Mhz''\n', ...
              k(kLoop).fromID{1}, k(kLoop).fromID{2}, ...
              k(kLoop).toID{1}, k(kLoop).toID{2}, k(kLoop).toID{3}/1e6);    
      fprintf(1, '        channel.\n');
      disp(k(kLoop).channel)
      fprintf(1, '\n');
      fprintf(1, '       pathLoss.\n');
      disp(k(kLoop).pathLoss)
      fprintf(1, '\n');
      fprintf(1, '     propParams.\n');            
      disp(k(kLoop).propParams)
      fprintf(1, '\n');             
    end
  end % END kLoop
end  


% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


