function ok = checkmatscalar(varargin)
% function ok = checkmatscalar(varargin)
% return 1 if all input matrices are the same size, 0 otherwise
% some inputs may be scalar without causing an error

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

% it could happen
if nargin<=1
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
if isempty(matidx)
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
for ii=1:length(matidx)
  matsize(ii,:) = size(varargin{matidx(ii)});
end
ok = all(all(matsize == repmat(matsize(1,:),length(matidx),1)));


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


