function display(n)

% NODE class display function

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

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



% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


