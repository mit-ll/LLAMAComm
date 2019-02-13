function sms = sizematscalar(varargin)
% function sms = sizematscalar(varargin)
% return matrix size if all input matrices are the same size, 
% nan otherwise
% some inputs may be scalar without causing an error

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

% it could happen
if nargin==1
  sms = size(varargin(1)); 
  return; 
end

% get index to non-scalar inputs
%matidx = [];
%for ii=1:nargin
%  if ~isscalar(varargin{ii}); 
%    matidx = [ matidx; ii ]; 
%  end
%end
matidx = find(~cellfun(@isscalar, varargin));
if isempty(matidx)
  sms=[1 1];
  return;
end

% check each matrix has same number of dimensions
%for ii=1:length(matidx);
%  nd(ii) = ndims(varargin{matidx(ii)});
%end
nd = cellfun(@ndims, varargin);

if ~all( nd == nd(1))
  sms = nan;
  return; 
end

% check that each matrix is same size
sms = size(varargin{matidx(1)});
for ii=2:length(matidx)
  if ~all(size(varargin{matidx(ii)})==sms)
    sms = nan;
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


