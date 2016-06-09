function ok = checkmatscalar(varargin)
% function ok = checkmatscalar(varargin)
% return 1 if all input matrices are the same size, 0 otherwise
% some inputs may be scalar without causing an error

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% it could happen
if nargin<=1; 
  ok=1; 
  return; 
end

% get index to non-scalar inputs
%matidx = [];
%for ii = 1:nargin
%  if ~isscalar(varargin{ii}); 
%    matidx = [ matidx; ii ]; 
%  end
%end
matidx = find(~cellfun(@isscalar, varargin));
if isempty(matidx); 
  ok = 1;
  return;
end

% check each matrix has ok number of dimensions
%nd = zeros(1, length(matidx));
%for ii = 1:length(matidx);
%  nd(ii) = ndims(varargin{matidx(ii)});
%end
nd = cellfun(@dims, varargin);
ok = all( nd == nd(1));
if ok == 0 
  return; 
end

% check that each matrix is ok size
matsize = zeros(length(matidx),nd(1));
for ii=1:length(matidx);
  matsize(ii,:) = size(varargin{matidx(ii)});
end
ok = all(all(matsize == repmat(matsize(1,:),length(matidx),1)));


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


