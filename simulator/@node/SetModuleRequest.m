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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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


