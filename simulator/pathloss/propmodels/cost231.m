function [L, alpha] = cost231(dkm,fmhz,hmm,hbm,hrm,bm,wm,phideg,env)
% function [L, alpha] = cost231(dkm,fmhz,hmm,hbm,hrm,bm,wm,phi,env)
% given horizontal range in Km, and frequency in MHz, returns
% median average power loss in dB, and range exponent,
% (linear L  is proportional to dkm^alpha)
% predicted by the COST231 Walfish Ikegami non-line-of-sight
% propagation model
% (Digital Mobile Radio Towards Future Generation Systems: COST 231
% Final Report, at http://www.lx.it.pt/cost231/final_report.htm,
% downloaded June 25, 2005, also in Low, VTC 1992, pp 936-942)
% input:
% dkm    = range in km (0.02-5)
% fmhz   = frequency in MHz (800-2000)
% hbm    = base station antenna height in m, (4,50)
% hmm    = mobile station antenna height in m, (1,3)
% hrm    = average roof height in m, typically 3*no. floors, +3 if roof slants
% bm     = distance between buildings in m, typically 20-50
% wm     = street width in m, typically bm/2
% phideg = prop. angle w.r.t. street, in degrees, (0,90), 90 is worst case
% env    = environment, 0 = suburban, 1 = metro center

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
if nargin <9 || isempty(env)
  env = 1;
end
if nargin <8 || isempty(phideg)
  phideg = 45;
end
if nargin <6 || isempty(bm)
  bm = 35;
end
if nargin <7 || isempty(wm)
  wm = bm/2;
end
if nargin <5
  error('first five arguments required, function cost231');
end
if ~checkmatscalar(dkm,fmhz,hmm,hbm,hrm,bm,wm,phideg)
  error('non-scalar arguments must be same size, function cost231');
end
if ~isscalar(env)
  error('environment variable must be scalar, function cost231');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% free space loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L0 = 32.4 + db20(dkm) + db20(fmhz);
alpha = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rooftop to street scattering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% orientation factor
phideg = mod(phideg,180);
phideg(phideg>90) = 180-phideg(phideg>90);
if phideg < 35
  Lori = -10 + 0.354*phideg;
elseif  abs(phideg) < 55
  Lori = 2.5 + 0.075*(phideg-35);
else
  Lori = 4.0 - 0.114*(phideg-55);
end

Lrts = -16.9 - db10(wm) + db10(fmhz) + db20(hrm-hmm) + Lori;
if Lrts <0
  Lrts=0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multi screen diffraction loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% base station height term
if hbm>hrm
  Lbsh = -18.0*bels(1+hbm-hrm);
  ka = 54.0;
else
  Lbsh = 0.0;
  if ( dkm >= 0.5 )
    ka = 54.0 - 0.8*(hbm-hrm);
  else
    ka = 54.0 - 0.8*(hbm-hrm).*2.0.*dkm;
  end
end

% distance dependence
if hbm>hrm
  kd = 18.0;
else
  kd = 18.0 - 15.0*(hbm-hrm)./hrm;
end

% frequency dependence
if env == 0
  kf = -4.0 + 0.7*(fmhz/925 - 1.0);
else
  kf = -4.0 + 1.5*(fmhz/925 - 1.0);
end

Lmsd = Lbsh + ka + kd.*bels(dkm) + kf.*bels(fmhz) - 9.0*bels(bm);
alpha = alpha + kd/10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conclusion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Lrts + Lmsd < 0
  L = L0;
else
  L = L0 + Lrts + Lmsd;
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


