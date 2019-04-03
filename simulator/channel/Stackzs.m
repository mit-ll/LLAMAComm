function Z=Stackzs(z, shifts)
% Function: stackzs: Form
%   z_{1, 1+shift_1} \ldots z_{1, m+shift_1}
%   z_{1, 1+shift_2} \ldots z_{1, m+shift_2}
%   z_{1, 1+shift_s} \ldots z_{1, m+shift_s}
%                  \vdots
%   z_{n, 1+shift_1} \ldots z_{n, m+shift_1}
%   z_{n, 1+shift_2} \ldots z_{n, m+shift_2}
%   z_{n, 1+shift_s} \ldots z_{n, m+shift_s}
% All shifts are taken cyclically
%Arguments
%       Z                       as above (out)
%       z                       as above (in)
%       shifts                  [shift_1 \ldots shift_s] (in)

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

[nr, nc] = size(z);
shifts = -shifts ;
Z = zeros(nr*length(shifts), nc);
for cnt=1:length(shifts)
  perm = cycle(nc, shifts(cnt));
  Z((cnt-1)*nr+1:cnt*nr, :) = z(:, perm);
end


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


