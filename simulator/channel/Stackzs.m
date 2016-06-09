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

%%%%%%%%%%%%%%%%%%%%%%%r%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nr, nc] = size(z);
shifts = -shifts ;
Z = zeros(nr*length(shifts), nc);
for cnt=1:length(shifts)
  perm = cycle(nc, shifts(cnt));
  Z((cnt-1)*nr+1:cnt*nr, :) = z(:, perm);
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


