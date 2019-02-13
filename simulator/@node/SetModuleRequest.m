function nodeobj = SetModuleRequest(nodeobj, modname, job, blockLen)

% Function @node/SetModuleRequest.m:
% Sets request flag high for the specified module so that its
% requested function will be executed by the arbitrator.  The
% block length (number of time samples) is required for scheduling
% purposes.
%
% Settging job='done' is a special case used to end the simulation 
% that does not require a blocklen.
%
% USAGE: nodeobj = SetModuleRequest(nodeobj, modname, job, blockLen)
%   or   nodeobj = SetModuleRequest(nodeobj, modname, 'done')
%
% Input arguments:
%  nodeobj    (node obj) Node containing module that needs execution.
%  modname    (string) Module name
%  job        (string) Job to be executed.  Should match job names in
%              callback function.
%  blockLen   (int) Number of samples in the block to be executed.
%
% Output agruments:
%  nodeobj    (node obj) Modified copy of the node object
%
% See @module/SetRequest.m for details.
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

% Error Checking
if exist('blockLen', 'var')
  if length(blockLen(:)) > 1
    disp('blockLen is:')
    disp(num2str(blockLen))
    error('''blockLen'' is not a scalar! %s-%s', ...
          nodeobj.name, modname);
  end
  
  if blockLen < 0
    error('''blockLen = %i'' is negative! %s-%s', blockLen, nodeobj.name, modname);
  end
  
  if isempty(blockLen)
    error('''blockLen'' is empty! %s-%s', nodeobj.name, modname);
  end
  
end

% Find the module requested
[modobj, modidx] = FindModule(nodeobj.modules, modname);

if isempty(modobj)
  % Module not found.  Display error
  error('Module name "%s" not found.', modname);
else
  % Forward request to module object
  if exist('blockLen', 'var')
    nodeobj.modules(modidx) = SetRequest(modobj, job, blockLen);
  else
    nodeobj.modules(modidx) = SetRequest(modobj, job);
  end
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


