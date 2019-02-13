function n = node(a)

% NODE class constructor

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

if nargin == 0
  n = emptyNode;
  n = class(n, 'node');
elseif isa(a, 'node')
  n = a;
elseif isstruct(a)
  n = emptyNode;
  n.name = a.name;
  n.location = a.location;
  n.velocity = a.velocity;
  n.controllerFcn = a.controllerFcn;
  n.modules = a.modules;
  if isfield(a,  'isCritical')
    n.isCritical = a.isCritical;
  else
    n.isCritical = true; % Defaults to true
  end
  n = class(n, 'node');
else
  error('Bad input argument to NODE constructor.');
end


function n = emptyNode()

n.name = '';
n.location = [];         % [x y z] (m)
n.velocity = [];         % [x y z] (m/s)
n.controllerFcn = [];
n.state = 'start';
n.modules = [];
% User parameters
n.user = [];
n.isCritical = true;




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


