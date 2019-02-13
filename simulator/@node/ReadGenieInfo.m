function [nodeobj,info] = ReadGenieInfo(nodeobj,modname)

% Function @node/ReadGenieInfo.m:
% Reads one item from the genie queue of the specified module
%
% USAGE: [nodeobj,info] = WriteGenieInfo(nodeobj,modname)
%
% Input arguments:
%  nodeobj    (node obj) Node object
%  modname    (string) Module name for transmitting genie module
%
% Output arguments:
%  nodeobj    (node obj) Modified node object where the first item has
%              been removed from the receive queue.
%  info       (struct) Data to read from the receive queue
%

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

% Find genie module by name
[modobj,modIdx] = FindModule(nodeobj.modules,modname);

% Check that this is a receiver module
if ~strcmp(GetType(modobj),'receiver')
    error('ReadGenieInfo is meant for use with genie receiver modules.');
end
    
% Read from genie receive queue
[modobj,info] = ReadFromQueue(modobj);

% Copy back into node object
nodeobj.modules(modIdx) = modobj;



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


