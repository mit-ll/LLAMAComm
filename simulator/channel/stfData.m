function zStf = stfData(z, nDelay, nFreq, sampRatioT, sampRatioF)
%
%  This function produces random space-time-frequency channel matrices
%  with a give spatial correlation.
%
% Outputs
%  zSTF      - stf channel matrix with the dimension of
%              nRx by (nTx*nReDelay*nReFreq) where
%              nReDelay = ceil(nDelay*sampRatioT(1)/sampRatioT(2));
%              nReFreq  = ceil(nFreq*sampRatioF(1)/sampRatioF(2));
%
% Inputs
%
%   z       - the number of antennas by number of sample data matrix
%
%   nDelay  - number of delay taps
%
%   nFreq   - number of frequency taps
%
%   sampRatioT - array [p q] which could have been used by "resample"
%           to create temporally over-sampled data.  If q is
%           absent, it is assumed to be 1.
%
%   sampRatioF - array [p q] which could have been used by "resample"
%           to create frequency shifts of less then that
%           determined by the coherent processing interval.  If q is
%           absent, it is assumed to be 1.

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

if nargin < 4
  sampRatioT = [1 1];
elseif length(sampRatioT) < 2
  sampRatioT(2) = 1;
end

if nargin < 5
  sampRatioF = [1 1];
elseif length(sampRatioF) < 2
  sampRatioF(2) = 1;
end

nReDelay = ceil(nDelay*sampRatioT(1)/sampRatioT(2));
nReFreq  = ceil(nFreq*sampRatioF(1)/sampRatioF(2));

zST = Stackzs(z, 0:(nReDelay-1));
freqOffs = (-((nReFreq-1)/2):((nReFreq-1)/2) )*nFreq/nReFreq;

[nRows, samps] = size(zST);
zStf = zeros(nReFreq*nRows, samps);

for idx = 1:nReFreq
  zStf(1+nRows*(idx-1):nRows*idx, :) = ...
      repmat(exp(2*pi*freqOffs(idx)*1i/samps*(0:(samps-1))), ...
             rows(zST), 1) .* zST;
end

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


