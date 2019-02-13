function h = zhengFunLUT(f, t, chanstates)
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

persistent calledBefore
if isempty(calledBefore)
  fprintf(1, ['\n   WARNING Missing MEX function: zhengFunLUT.%s', ...
              '.\n   You can create the mex function by changing', ...
              ' the\n   working directory to', ...
              ' /simulator/channel/\n   and typing "mex', ...
              ' zhengFunLUT.c"\n\n'], mexext);
  calledBefore = true;
end


m = chanstates.M;
phi = repmat(chanstates.phi, size(t));
sphi = repmat(chanstates.sphi, size(t));

h = (2/sqrt(4*m))*sum(complex(cos(2*pi*f*cos(chanstates.alph)*t+ phi), cos(2*pi*f*sin(chanstates.alph)*t + sphi)));

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
