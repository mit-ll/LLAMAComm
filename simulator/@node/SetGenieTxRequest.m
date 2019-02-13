function nodeobj = SetGenieTxRequest(nodeobj,modname,toNodeName,toModName)

% Function @node/SetGenieTxRequest.m:
% Sets request flag high for genie transmit request.  Also specifies
% the module that the information is being sent to.
%
% USAGE: nodeobj = SetGenieTxRequest(nodeobj,modname,toNodeName,toModName)
%
% Input arguments:
%  nodeobj    (node object) Node object
%  modname    (string) Module name
%  toNodeName (string) Node name to send info to
%  toModName  (string) Modname to send info to
%
% Output argument:
%  nodeobj    (node object) Modified node object
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

% Find the module requested
[modobj,modidx] = FindModule(nodeobj.modules,modname);

% Forward request to module object
nodeobj.modules(modidx) = SetRequest(modobj,'transmit',...
    toNodeName,toModName);



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


