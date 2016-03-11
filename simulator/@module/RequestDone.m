function modobj = RequestDone(modobj,fPtr)

% Function @module/RequestDone.m:
% Sets request flag low to signal completion of request.  Also
% adjusts the nextBlockStart parameter and stores the previous
% request into the history structure.
%
% USAGE: modobj = RequestDone(modobj,fPtr)
%
% Input arguments:
%  modobj     (module obj) Module to be modified
%  fPtr       (int) Offset that points to start of block in save file.
%              This value is returned by WriteSigBlock.  If fPtr is not
%              provided, the value will be set to -1 in the history
%              entry.
%
% Output agruments:
%  modobj     (module obj) Module to be modified
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if modobj.requestFlag==0
  error('Module object has no outstanding request.');
end
if nargin < 2
  fPtr = -1;
end

% Add previous block to history
N = length(modobj.history);
modobj.history{N+1} = struct(...
    'start', modobj.blockStart, ... 
    'blockLength', modobj.blockLength, ...
    'job', modobj.job, ...
    'fc', modobj.fc, ...
    'fs', modobj.fs, ...
    'fPtr', fPtr);

% Set position for start of next block
modobj.blockStart = modobj.blockStart + modobj.blockLength;

% Clear finished request
modobj.job = '';
modobj.blockLength = [];
modobj.requestFlag = 0;



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


