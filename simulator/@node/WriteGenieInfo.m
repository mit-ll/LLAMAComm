function nodeobj = WriteGenieInfo(nodeobj,modname,info)

% Function @node/WriteGenieInfo.m:
% Adds info structure into the genie transmit queue for the named
% module.
%
% USAGE: nodeobj = WriteGenieInfo(nodeobj,modname,info)
%
% Input arguments:
%  nodeobj    (node obj) Node object
%  modname    (string) Module name for transmitting genie module
%  info       (struct) Data to transmit over genie channel
%
% Output arguments:
%  nodeobj    (node obj) Modified node object where info has been written
%              to the specified module for transmission
%

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

% Find genie module by name
[modobj,modIdx] = FindModule(nodeobj.modules,modname);

% Check that this is a transmit module
if ~strcmp(GetType(modobj),'transmitter')
    error('WriteGenieInfo is meant for use with genie transmitter modules.');
end

% Add to genie transmit queue
modobj = AddToQueue(modobj,info);

% Copy back into node object
nodeobj.modules(modIdx) = modobj;



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


