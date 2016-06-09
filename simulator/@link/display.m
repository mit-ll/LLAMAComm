function display(k)

% LINK class display function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
% reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%      * Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      * Redistributions in binary form must reproduce the above  copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      * Neither the name of the Massachusetts Institute of Technology nor
%        the names of its contributors may be used to endorse or promote
%        products derived from this software without specific prior written
%        permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


