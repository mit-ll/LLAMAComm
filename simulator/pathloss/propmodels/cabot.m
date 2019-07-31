function [ Ldb, sigmadb ] = cabot(dm, fmhz, hmm, hbm, delh, pol)
% function L = cabot(dm, fmhz, hmm, hbm, delh, pol)
% Plot mobile system propagation loss for short ranges in rural
% setting by interpolating between LOS loss at 10 m and Longley-
% Rice loss at 1 km
%
% All input parameters may be either scaler, or equal size arrays
% input:  dm    = range in m, between 10 and 1000
%         fmhz  = carrier frequency, MHz
%         hmm   = mobile station height, m
%         hbm   = base station height, m
%         delh  = terrain variablility parameter, m, default 90
%         pol   = polarization, 'v'=vertical, 'h'=horizontal, default 'v'
% output: Ldb   = pathloss, in dB
%         sigma = shadowing standard deviation, in dB
%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% housekeeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
  error('Too few input arguments, function cabot');
end
if nargin<5; delh = 90; end
if nargin<6; pol  = 'v'; end

[dm, fmhz, hmm, hbm, delh] = matsize(dm, fmhz, hmm, hbm, delh);
if isnan(dm)
  error('non-scalar arguments must be same size, function cabot');
end

if ~( strcmp(pol, 'v') || strcmp(pol, 'h') )
  error('unknown polarization value, function cabot');
end

if ( any(dm<10) || any(dm>1000) )
  error('range outside allowed values, function cabot');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ldb     = zeros(size(dm));
sigmadb = zeros(size(dm));
Ne      =  numel(dm); % number of matrix elements
for ii = 1:Ne

  rr10  = sqrt( 100 + (hbm(ii)-hmm(ii))^2 ); % slant range at dm=10 m
  L10 = los(rr10, fmhz(ii)); % LOS pathloss at 10 m ground range

  % longley-rice loss at 1 km
  [L1000, sigmadb1000] = ...
      longley_rice(1, fmhz(ii), [ hbm(ii) hmm(ii) ], delh(ii), pol);

  rr = sqrt( dm(ii)^2 + (hbm(ii)-hmm(ii))^2 ); % need for continuity at 10 m
  rr1000 = sqrt( 1e6 + (hbm(ii)-hmm(ii))^2 );
  Ldb(ii) = L10 + ( bels(rr) - bels(rr10) )* ...
            (L1000-L10 )/(bels(rr1000)-bels(rr10));
  sigmadb(ii) = sqrt(( bels(dm(ii)) - bels(10) )* ...
                     sigmadb1000^2 / (bels(1000)-bels(10)));

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


