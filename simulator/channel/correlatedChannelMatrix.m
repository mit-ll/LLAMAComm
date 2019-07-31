function [f, h] = correlatedChannelMatrix(alpha, n, firstV)

% correlatedChannelMatrix(alpha, n, firstCol)
%
%  This function produces random flat fading channel matrices with
%  a give spatial correlation.
%
% Inputs
%   alpha   correlation paramenter 0 >= alpha >= 1,
%           where 0 indicates a rank 1 channel, and 1 indicates a
%           gaussian channel.  If alpha is a scalar then the channel
%           correlation is symmetric. Otherwise, two entries indicate
%           the receiver and transmitter alpha respectively.
%
%   n       number of antennas.  If n is a scalar then the channel
%           channel matrix is symmetric.  Otherwise, two entries
%           indicate the number of receiver and transmitter channels
%           respectively.
%
%   firstV  is an optional parameter that is used to specify the
%           first (dominant) column of the unitary matrix associated
%           with the channel

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

nRow = n(1);
if length(n) > 1
  nCol = n(2);
else
  nCol = n(1);
end

alphaLeft  = alpha(1);
if length(alpha) > 1
  alphaRight = alpha(2);
else
  alphaRight = alpha(1);
end

dLeft  = alphaLeft.^(0:(nRow-1)) * ...
         sqrt(nRow / sum(alphaLeft.^(2*(0:(nRow-1)))));
dRight = alphaRight.^(0:(nCol-1)) * ...
         sqrt(nCol / sum(alphaRight.^(2*(0:(nCol-1)))));

g1 = complex(randn(nRow), randn(nRow))/sqrt(2);
[uLeft, dummy] = qr(g1); %#ok - dummy unused

g2 = complex(randn(nCol), randn(nCol))/sqrt(2);
[uRight, dummy] = qr(g2); %#ok - dummy unused

g = complex(randn(nRow, nCol), randn(nRow, nCol))/sqrt(2);

f = uLeft * diag(dLeft) * g * diag(dRight) * uRight';

if nargin > 2
  [u, s, v]  = svd(f);
  [val, in] = max(diag(s)); %#ok - val unused
  if in ~= 1
    tval     = s(1, 1);
    s(1, 1)   = s(in, in);
    s(in, in) = tval;
  end
  g3 = complex(randn(nRow), randn(nRow))/sqrt(2);
  g3(:, in) = firstV;
  [uLeft, dummy] = qr(g3); %#ok - dummy unused
  f = u*s*v';
end

h.h      = f;
h.u      = uLeft;
h.v      = uRight;
h.aLeft  = dLeft;
h.aRight = dRight;
h.g      = g; % fix for forced firstV !!!!!!




%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


