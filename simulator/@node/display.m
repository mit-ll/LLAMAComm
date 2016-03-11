function display(n)

% NODE class display function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(inputname(1))
  fprintf('\n%s = \n\n', inputname(1));
end

if isempty(n)
  fprintf(1, ' %dx%d node matrix\n', size(n));
elseif length(n) == 1
  fprintf(1, '           name: %s\n', n.name);
  fprintf(1, '       location: %s\n', mat2str(n.location));
  fprintf(1, '       velocity: %s\n', mat2str(n.velocity));
  if isempty(n.controllerFcn)
    fprintf(1, '  controllerFcn: []\n');
  else
    finfo = functions(n.controllerFcn);
    fprintf(1, '  controllerFcn: @%s\n', finfo.function);
  end
  fprintf(1, '          state: ''%s''\n', n.state);
  fprintf(1, '        modules:');
  for r = 1:size(n.modules, 1)
    if r > 1
      fprintf(1, '\n                  ');
    end
    for c = 1:size(n.modules, 2)
      fprintf(1, ' ''%s''', GetModuleName(n.modules(r, c)));
    end
  end
  fprintf(1, '\n\n');
  fprintf(1, ' User Parameters:\n');
  disp(n.user);
  fprintf(1, '\n\n');
else
  fprintf(1, ' %dx%d node matrix with names:\n', size(n));
  for r=1:size(n, 1)
    fprintf(1, '  ''%s''', n(r, :).name);
    fprintf(1, '\n');
  end
  fprintf(1, '\n');  
end



% Copyright (c) 2006-2012, Massachusetts Institute of Technology All rights
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


