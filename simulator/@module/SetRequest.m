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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


