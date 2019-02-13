function modobj = SetRequest(modobj, job, varargin)

% Function @module/SetRequest.m:
% Sets request flag high, sets the job name, and fills in the block length 
% field so that the arbitrator will handle the request.
%
% Setting job='done' is a special case used to end the simulation.  
% Once a module is marked as done, it can not be unmarked.  The module
% acts as if it is in a wait state for the remainder of the simulation.  
% During this time the request flag is kept low.
%
% USAGE: modobj = SetRequest(modobj, job, blockLen)
%    or  modobj = SetRequest(modobj, 'done')
%   For genie modules:
%        modobj = SetRequest(modobj, 'receive')
%    or  modobj = SetRequest(modobj, 'transmit', toNodeName, toModName);
%
% Input arguments:
%  modobj     (module obj) Module to be modified
%  job        (string) Job to be executed.  Must match job names in
%              arbitrator function (RunArbitrator.m).
%  blockLen   (int) Number of samples in the block to be executed.
%  toNodeName (string) Name of node to send to
%  toModName  (string) Name of module within node to send to
%
% Output agruments:
%  modobj     (module obj) Module to be modified
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


% Check for bad requests
if strcmp(modobj.job, 'done')
  error('Module has been marked as ''done''.  No further requests allowed.');
end
if modobj.requestFlag~=0
  error('Module has an outstanding request!  Cannot start new request.');
end

if IsGenie(modobj)
  % Handle requests for genie modules
  switch job
    case 'receive'
      modobj.job = job;
      modobj.requestFlag = 1;
    
    case 'transmit'
      modobj.job = job;
      modobj.requestFlag = 1;
      modobj.genieToNodeName = varargin{1};
      modobj.genieToModName = varargin{2};
      
    otherwise
      error('Bad job name %s for genie module', job);
  end

else
  % Handle requests for ordinary modules
  switch job
    case {'receive', 'transmit', 'wait'}
      modobj.job = job;
      modobj.requestFlag = 1;
      modobj.blockLength = varargin{1};
    
    case 'done'
      modobj.job = job;
    
    otherwise
      error('Bad job name %s', job);
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


