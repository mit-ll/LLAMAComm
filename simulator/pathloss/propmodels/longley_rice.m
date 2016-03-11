function [ medLdb, stdLdb ] = longley_rice(dkm, fmhz, hm, delh, pol, deploy, ...
                                           gelev, climate, ground)

% [ medLdb, stdLdb ] = longley_rice(dkm, fmhz, hm, delh, pol, deploy, ...
%                                   gelev, climate, ground);
% run the Longley-Rice propagation model in the area mode
% as described in G. A. Hufford, A. G. Longley, W. A. Kissick, 
% A Guide to the Use of the ITS Irregular Terrain Model in the 
% Area Prediction Mode, NTIA Report 82-100, April 1982. Also
% described in Parsons
%
% inputs:  dkm     = ground range in km, vector 
%          fmhz    = frequency in MHz, scalar
%          hm      = 2-vector of antenna heights, m
%          delh    = terrain variablility parameter, m (see below), default 90
%          pol     = polarization, 'v'=vertical, 'h'=horizontal, default 'v'
%          deploy  = 2-vector indicating antenna site selection, 
%                    0='random', 1='careful', 2='very careful', default [0, 0]
%          gelev   = avg. ground elevation in m, default 0
%          ground  = ground condition (see below), default 'avg'
%          climate = climate descriptor (see below), default 'conttemp'
%          
% outputs: medLdb  = median channel loss, dB
%          stdLdb  = channel loss standard deviation, in dB
%
% region of application:
% frequency           20 MHz to    20 GHz
% range                1 km  to 2, 000 km
% antenna height       0.5 m to     3 km
% polarization        vertical or horizontal
%
% terrain variablity is defined as difference between 90% quantile 
% elevation and 10% quantile elevation in m, in the limit as path length
% grows but terrain variation is uniform. Recommended values are
% flat or water             0
% plains                   30
% hills (average terrain)  90
% mountains               200
% rugged mountains        500
%
% ground condition is used to select ground electrical characteristics
% value    ground type    relative permittivity   conductivity
% 'avg'    average ground           15                0.005
% 'poor'   poor ground               4                0.001
% 'good'   good ground              25                0.020
% 'fwater' fresh water              81                0.010
% 'swater' salt water               81                5.000
%
% climate is used to set the L-R climate parameter and surface refractivity 
% at sea level (No)
% value        climate type                example         No
% 'equat'      equatorial                  Congo           360
% 'contsub'    continental sub-trobical    Sudan           320
% 'marsub'     maritime subtropical        West Africa     370
% 'desert'     desert                      Sahara          280
% 'conttemp'   continental temperate       most of US      301
% 'martemp'    maritime temperate land     Seattle, UK     320
% 'martempsea' maritime temperate over sea duh             350

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% house keeping

if nargin< 9 || isempty(ground);  ground  = 'avg';      end;
if nargin< 8 || isempty(climate); climate = 'conttemp'; end;
if nargin< 7 || isempty(gelev);   gelev   = 0;          end;
if nargin< 6 || isempty(deploy);  deploy  = [ 0, 0];   end;
if nargin< 5 || isempty(pol);     pol     = 'v';        end;
if nargin< 4 || isempty(delh);    delh    = 90;         end;

% debugging values: compare with plot on p 29 of Coverage Prediction
% for Mobile Radio Systems Operating in the 800/900 MHz Frequency
% Range, by IEEE Vehicular Technology Society Committee on Radio
% Propagation, IEEE Trans. Veh. Tech., Vol. 37, No. 1, Feb. 1988, pp 3-72.
%dkm = logspace(0, 2, 100);
%fmhz = 900;
%hm = [ 61 1.2 ];
%pol     = 'v';
%delh    = 0;
%deploy  = [ 0, 0];
%gelev   = 0;
%climate = 'conttemp';
%ground  = 'avg';

switch climate;  % set climate parameters
  case 'equat';      climno = 1; No = 360;
  case 'contsub';    climno = 2; No = 320;
  case 'marsub';     climno = 3; No = 370;
  case 'desert';     climno = 4; No = 280;
  case 'conttemp';   climno = 5; No = 301;
  case 'martemp';    climno = 6; No = 320;
  case 'martempsea'; climno = 7; No = 350;
  otherwise; error('unknown climate specifier, function longley-rice');
end;

if strcmp(pol, 'v'); ipol = 1; else ipol=0; end; % set polarization flag

switch ground;
  case 'poor';   eps = 4;  sgm = 0.001;
  case 'avg';    eps = 15; sgm = .005;
  case 'good';   eps = 25; sgm = 0.02;
  case 'fwater'; eps = 81; sgm = 0.01;
  case 'swater'; eps = 81; sgm = 5;
  otherwise; error('unknown ground condition specifier, function longley-rice');
end;

% initialize propagation parameters
kwxqlrps = qlrps(fmhz, hm, delh, gelev, No, ipol, eps, sgm); %#ok - kwxqlrps unused
%if kwxqlrps>1;
%   error(['error, kwx = ' int2str(kwxqlrps) ', function qlrps in function longley_rice']);
%end;

% set required parameters and call qlra, the 'area mode initialization'
% sub-routine

% set mode flag, mdvar, allowed values:
% mdvar = 0, "single message mode", reliability is time, location, 
%            and situation variability combined
% mdvar = 1, "individual mode", reliability is time, confidence is combined 
%            location and situation
% mdvar = 2, "mobile mode", reliability is time and location, confidence 
%            is situation
% mdvar = 3, "broadcast mode", reliability is two-fold: at least qt of time 
%            in at least ql of locations, confidence is situation variability
mdvar = 2; 

% set area-prediction-mode parameters
kwxqlra = qlra(deploy, climno, mdvar); %#ok - kwxqlra unused
%if kwxqlra>1;
%   error(['error, kwx = ' int2str(kwxqlra) ', function qlra in function longley_rice']);
%end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run propagation routine

Llrprop = zeros(size(dkm));
medLdb = zeros(size(dkm));
stdLdb = zeros(size(dkm));
kwxlrprop = zeros(size(dkm));
kwxmedL = zeros(size(dkm));
kwx1sigma =  zeros(size(dkm));
for ii=1:length(dkm);
  [ Llrprop(ii) kwxlrprop(ii) ] = lrprop(1000*dkm(ii));
  %   if kwxlrprop(ii)>1;
  %      error(['error, kwx = ' int2str(kwxlrprop(ii)) ...
  %             ', function lrprop in function longley_rice at range ' ...
  %             num2str(dkm(ii)) ' km']);
  %      end;
  [ medLdb(ii) kwxmedL(ii) ] = avar(0, 0, 0);
  %   if kwxmedL(ii)>1;
  %      error(['error, kwx = ' int2str(kwxmedL(ii)) ...
  %             ', function avar in function longley_rice at range ' ...
  %             num2str(dkm(ii)) ' km']);
  %      end;
  [ Ldb1sigma  kwx1sigma(ii) ] = avar(1, 0, 0);
  %if kwx1sigma(ii)>1;
  %      error(['error, kwx = ' int2str(kwx1sigma(ii)) ...
  %             ', function avar in function longley_rice at range ' ...
  %             num2str(dkm(ii)) ' km']);
  %      end;
  stdLdb(ii) = medLdb(ii) - Ldb1sigma;
end;

medLdb = medLdb + los(sqrt( (1000*dkm).^2 + (hm(1)-hm(2))^2 ), fmhz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Longley-Rice Subroutines %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kwx_out = qlrps(fmhz, hm, delh, zsys, en0, ipol, epss, sgm)
% function kwx = qlrps(fmhz, hm, delh, zsys, en0, ipol, epss, sgm)
% calculates wn, ens, gme, zgnd
% inputs: fmhz = frequency, MHz
%         hm   = antenna heights, m (2-vector)
%         delh = ground variablity, m
%         zsys = avg. ground elevation, m
%         en0  = atmospheric refractivity at sea level
%         ipol = polarization, 0 = horizontal, 1 = vertical
%         epss = ground relative permittivity
%         sgm  = ground conductivity 
% output: kwx  = error flag
%                0 = no warning
%                1 = parameters are close to limits
%                2 = impossible parameters, default values substituted
%                3 = internal calculations show parameters out of range
%                4 = parameters out of range

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
global kwx hg wn dh ens gme zgnd

hg  = hm;
dh  = delh;
gma = 157e-9;
wn  = fmhz/47.7;
ens = en0;
kwx = 0;

if zsys ~= 0
  ens=ens*exp(-zsys/9460);
end

gme=gma*(1-0.04665*exp(ens/179.3));
zq=epss+sqrt(-1)*376.62*sgm/wn;
zgnd=sqrt(zq-1);
if ipol ~= 0
  zgnd=zgnd/zq;
end
kwx_out = kwx;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kwx_out = qlra(kst, klimx, mdvarx)
% function kwx = qlra(kst, klimx, mdvarx)
% calculates he, dl, the, mdp, lvar for sub-routine avar
% will also set mdvar, klim with correct inputs
% inputs: kst    = deployment criteria, 0 = random, 1 = careful, 
%                  2 = very careful (2-vector)
%         klimx  = climate flag, 1 = equatorial, 2 = continental sub-tropical
%                  3 = maritime sub-tropical, 4 = desert, 
%                  5 = maritime temperate over land, 
%                  6 = maritime temperate over sea
%         mdvarx = statistical variation analysis mode flag
%                  0 = single message mode
%                  1 = individual mode
%                  2 = mobile mode
%                  3 = broadcast mode
% output: kwx    = error flag
%                  0 = no warning
%                  1 = parameters are close to limits
%                  2 = impossible parameters, default values substituted
%                  3 = internal calculations show parameters out of range
%                  4 = parameters out of range

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
%global lvar sgc mdvar klim
global kwx mdp hg dh gme he dl the
global lvar mdvar klim

for jj=1:2
  if kst(jj) <= 0
    he(jj)=hg(jj);
  else
    q=4;
    if kst(jj) ~= 1
      q=9;
    end
    if hg(jj) < 5
      q = q*sin(0.3141593*hg(jj));
    end
    he(jj)=hg(jj)+(1+q)*exp(-min(20, 2*hg(jj)/max(1e-3, dh)));
  end
  q=sqrt(2*he(jj)/gme);
  dl(jj)=q*exp(-0.07*sqrt(dh/max(he(jj), 5)));
  the(jj)=(0.65*dh*(q/dl(jj)-1)-2*he(jj))/q;
end
mdp=1;
lvar=max(lvar, 3);
if mdvarx > 0
  mdvar=mdvarx;
  lvar=max(lvar, 4);
end
if klimx > 0
  klim=klimx;
  lvar=5;
end
kwx_out = kwx;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [aref_out, kwx_out] = lrprop(d)
% function [ aref, kwx ] = lrprop(d)
% calculates dls, dlsa, dla, tha, kwx, aed, emd, ak2, ak1, aref, dx, ems, aes
% input:  d    = distance, m
% outputs:aref = median channel loss, dB 
%         kwx  = error flag
%                0 = no warning
%                1 = parameters are close to limits
%                2 = impossible parameters, default values substituted
%                3 = internal calculations show parameters out of range
%                4 = parameters out of range

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
global kwx aref mdp dist hg wn ens gme zgnd he dl the
global dlsa dx ael ak1 ak2 aed emd aes ems dls dla tha
persistent wlos wscat dmin xae

third=1/3;
wlos=0;
wscat=0;
%wq=0;
if mdp ~= 0
  for jj=1:2
    dls(jj)=sqrt(2*he(jj)/gme);
  end
  dlsa=dls(1)+dls(2);
  dla=dl(1)+dl(2);
  tha=max(the(1)+the(2), -dla*gme);
  wlos=0;
  wscat=0;
  if wn < 0.838 || wn > 210
    kwx=max(kwx, 1);
  end
  for jj=1:2
    if hg(jj) < 1 || hg(jj) > 1000
      kwx=max(kwx, 1);
    end
  end
  for jj=1:2
    if abs(the(jj)) > 200e-3 || dl(jj) < 0.1*dls(jj) || dl(jj) > 3*dls(jj)
      kwx=max(kwx, 3);
    end
  end
  if ens < 250 || ens > 400 || gme < 75e-9 || gme > 250e-9 || ...
        real(zgnd) <= abs(imag(zgnd)) || wn < 0.419 || wn > 420
    kwx=4;
  end
  for jj=1:2
    if hg(jj) < 0.5 || hg(jj) > 3000
      kwx=4;
    end
  end
  dmin=abs(he(1)-he(2))/200e-3;
  q=adiff(0); %#ok - q unused
  xae=(wn*gme^2)^(-third);
  d3=max(dlsa, 1.3787*xae+dla);
  d4=d3+2.7574*xae;
  a3=adiff(d3);
  a4=adiff(d4);
  emd=(a4-a3)/(d4-d3);
  aed=a3-emd*d3;
end
if mdp >= 0
  mdp=0;
  dist=d;
end
if dist > 0
  if dist > 1000e3
    kwx=max(kwx, 1);
  end
  if dist < dmin
    kwx=max(kwx, 3);
  end
  if dist < 1e3 || dist > 2000e3
    kwx=4;
  end
end
if dist < dlsa
  if ~wlos
    q=alos(0); %#ok - q unused
    d2=dlsa;
    a2=aed+d2*emd;
    d0=1.908*wn*he(1)*he(2);
    if aed >= 0
      d0=min(d0, 0.5*dla);
      d1=d0+0.25*(dla-d0);
    else
      d1=max(-aed/emd, 0.25*dla);
    end
    a1=alos(d1);
    wq=0;
    if d0 < d1
      a0=alos(d0);
      q=log(d2/d0);
      ak2=max(0, ((d2-d0)*(a1-a0)-(d1-d0)*(a2-a0))/((d2-d0)*log(d1/d0)-(d1-d0)*q));
      wq = (aed > 0 || ak2 > 0);
      if wq
	ak1=(a2-a0-ak2*q)/(d2-d0);
	if ak1 < 0
	  ak1=0;
	  ak2=dim(a2, a0)/q;
	  if ak2 == 0
	    ak1=emd;
   end
 end
      end
    end
    if ~wq
      ak1=dim(a2, a1)/(d2-d1);
      ak2=0;
      if ak1 == 0
	ak1=emd;
      end
    end
    ael=a2-ak1*d2-ak2*log(d2);
    wlos=1;
  end
  if dist > 0
    aref=ael+ak1*dist+ak2*log(dist);
  end
end
if dist <= 0 || dist >= dlsa
  if ~wscat
    q=ascat(0); %#ok - q unused
    d5=dla+200e3;
    d6=d5+200e3;
    a6=ascat(d6);
    a5=ascat(d5);
    if a5 < 1000
      ems=(a6-a5)/200e3;
      dx=max([dlsa, dla+0.3*xae*log(47.7*wn), (a5-aed-ems*d5)/(emd-ems)]);
      aes=(emd-ems)*dx+aed;
    else
      ems=emd;
      aes=aed;
      dx=10e6;
    end
    wscat=1;
  end
  if dist > dx
    aref=aes+ems*dist;
  else
    aref=aed+emd*dist;
  end
end
aref=max(aref, 0);

aref_out = aref;
kwx_out = kwx;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res, kwx_out] = avar(zzt, zzl, zzc)
% function [ res, kwx ] = avar(zzt, zzl, zzc)
% inputs vary depending on mdvar, but in general zzx represent
% values such that q = qerf(z), for q the desired quantile
% mdvar = 0 (single message mode), zzt, zzl unused, zzc is total variance
%           (time, location, and situation)
% mdvar = 1 (individual mode) zzt is reliability (time), zzl is unused, 
%            zzc is confidence (location and situation)
% mdvar = 2 (mobile mode) zzt is reliability (time and location), zzl is
%           unused, zzc is confidence (situation)
% mdvar = 3 (broadcast mode) zzt is time reliability, zzl is location
%           reliability (signal exceeds quantile at least qt of time, in
%           at lest ql of locations), zzc is confidence (situation)
% outputs: res  = desired quantile
%          kwx  = error flag
%                 0 = no warning
%                 1 = parameters are close to limits
%                 2 = impossible parameters, default values substituted
%                 3 = internal calculations show parameters out of range
%                 4 = parameters out of range

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
%global lvar sgc mdvar klim
global kwx aref dist wn dh he 
global lvar sgc mdvar klim
persistent kdv wl ws dexa de vmd vs0 sgl sgtm sgtp sgtd tgtd gm gp cv1
persistent cv2 yv1 yv2 yv3 csm1 csm2 ysm1 ysm2 ysm3 csp1 csp2 ysp1 ysp2 ysp3
persistent csd1 zd cfm1 cfm2 cfm3 cfp1 cfp2 cfp3

third=1/3;
bv1 = [-9.67 -0.62 1.26 -9.21 -0.62 -0.39 3.15];
bv2 = [12.7 9.19 15.5 9.05 9.19 2.86 857.9];
xv1 = [144.9e3 228.9e3 262.6e3 84.1e3 228.9e3 141.7e3 2222.e3];
xv2 = [190.3e3 205.2e3 185.2e3 101.1e3 205.2e3 315.9e3 164.8e3];
xv3 = [133.8e3 143.6e3 99.8e3 98.6e3 143.6e3 167.4e3 116.3e3];
bsm1 = [2.13 2.66 6.11 1.98 2.68 6.86 8.51];
bsm2 = [159.5 7.67 6.65 13.11 7.16 10.38 169.8];
xsm1 = [762.2e3 100.4e3 138.2e3 139.1e3 93.7e3 187.8e3 609.8e3];
xsm2 = [123.6e3 172.5e3 242.2e3 132.7e3 186.8e3 169.6e3 119.9e3];
xsm3 = [94.5e3 136.4e3 178.6e3 193.5e3 133.5e3 108.9e3 106.6e3];
bsp1 = [2.11 6.87 10.08 3.68 4.75 8.58 8.43];
bsp2 = [102.3 15.53 9.60 159.3 8.12 13.97 8.19];
xsp1 = [636.9e3 138.7e3 165.3e3 464.4e3 93.2e3 216.0e3 136.2e3];
xsp2 = [134.8e3 143.7e3 225.7e3 93.1e3 135.9e3 152.0e3 188.5e3];
xsp3 = [95.6e3 98.6e3 129.7e3 94.2e3 113.4e3 122.7e3 122.9e3];
bsd1 = [1.224 0.801 1.380 1.000 1.224 1.518 1.518];
bzd1 = [1.282 2.161 1.282 20. 1.282 1.282 1.282];
bfm1 = [1. 1. 1. 1. 0.92 1. 1.];
bfm2 = [0. 0. 0. 0. 0.25 0. 0.];
bfm3 = [0. 0. 0. 0. 1.77 0. 0.];
bfp1 = [1. 0.93 1. 0.93 0.93 1. 1.];
bfp2 = [0. 0.31 0. 0.19 0.31 0. 0.];
bfp3 = [0. 2.00 0. 1.79 2.00 0. 0.];
rt = 7.8;
rl = 24;
wl = 0;
ws = 0;

donext=0;
if lvar > 0
  if lvar >= 5
    if klim <= 0 || klim > 7
      klim=5;
      kwx=max(kwx, 2);
    end
    cv1=bv1(klim);
    cv2=bv2(klim);
    yv1=xv1(klim);
    yv2=xv2(klim);
    yv3=xv3(klim);
    csm1=bsm1(klim);
    csm2=bsm2(klim);
    ysm1=xsm1(klim);
    ysm2=xsm2(klim);
    ysm3=xsm3(klim);
    csp1=bsp1(klim);
    csp2=bsp2(klim);
    ysp1=xsp1(klim);
    ysp2=xsp2(klim);
    ysp3=xsp3(klim);
    csd1=bsd1(klim);
    zd=bzd1(klim);
    cfm1=bfm1(klim);
    cfm2=bfm2(klim);
    cfm3=bfm3(klim);
    cfp1=bfp1(klim);
    cfp2=bfp2(klim);
    cfp3=bfp3(klim);
    donext=1;
  end % lvar >= 5
  if lvar == 4 || donext
    kdv=mdvar;
    ws = (kdv >= 20);
    if ws
      kdv=kdv-20;
    end
    wl = (kdv >= 10);
    if wl
      kdv=kdv-10;
    end
    if kdv < 0 || kdv > 3
      kdv=0;
      kwx=max(kwx, 2);
    end
    donext=1;
  end % lvar == 4 || donext
  if lvar == 3 || donext
    q=log(0.133*wn);
    gm=cfm1+cfm2/((cfm3*q)^2+1);
    gp=cfp1+cfp2/((cfp3*q)^2+1);
    donext=1;
  end % lvar == 3 || donext
  if lvar == 2 || donext
    dexa=sqrt(18e6*he(1))+sqrt(18e6*he(2))+(575.7e12/wn)^third;
    donext=1;
  end % lvar == 2 || donext
  if lvar == 1 || donext
    if dist < dexa
      de=130e3*dist/dexa;
    else
      de=130e3+dist-dexa;
    end
    vmd=curv(cv1, cv2, yv1, yv2, yv3, de);
    sgtm=curv(csm1, csm2, ysm1, ysm2, ysm3, de)*gm;
    sgtp=curv(csp1, csp2, ysp1, ysp2, ysp3, de)*gp;
    sgtd=sgtp*csd1;
    tgtd=(sgtp-sgtd)*zd;
    if wl 
      sgl=0;
    else
      q=(1-0.8*exp(-dist/50e3))*dh*wn;
      sgl=10*q/(q+13);
    end
    if ws      
      vs0=0;
    else
      vs0=(5+3*exp(-de/100e3))^2;
    end
    donext=1; %#ok if unused
  end % lvar == 1 || donext
  lvar=0;
end % lvar > 0
zt=zzt;
zl=zzl;
zc=zzc;
if kdv == 0
  zt=zc;
  zl=zc;
elseif kdv == 1
  zl=zc;
elseif kdv == 2
  zl=zt;
end
if abs(zt) > 3.10 || abs(zl) > 3.10 || abs(zc) > 3.10 
  kwx=max(kwx, 1);
end
if zt < 0
  sgt=sgtm;
elseif zt <= zd
  sgt=sgtp;
else
  sgt=sgtd+tgtd/zt;
end
vs=vs0+(sgt*zt)^2/(rt+zc^2)+(sgl*zl)^2/(rl+zc^2);
if kdv == 0
  yr=0;
  sgc=sqrt(sgt^2+sgl^2+vs);
elseif kdv == 1
  yr=sgt*zt;
  sgc=sqrt(sgl^2+vs);
elseif kdv == 2
  yr=sqrt(sgt^2+sgl^2)*zt;
  sgc=sqrt(vs);
else
  yr=sgt*zt+sgl*zl;
  sgc=sqrt(vs);
end
res=aref-vmd-yr-sgc*zc;
if res < 0
  res=res*(29-res)/(29-10*res);
end

kwx_out = kwx;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=adiff(d)

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
%global dlsa dx ael ak1 ak2 aed emd aes ems dls dla tha
global mdp hg wn dh gme zgnd he dl
global dlsa dla tha
persistent wd1 xd1 afo qk aht xht 

third=1/3;
if d == 0
  q=hg(1)*hg(2);
  qk=he(1)*he(2)-q;
  if mdp < 0 
    q=q+10;
  end
  wd1=sqrt(1+qk/q);
  xd1=dla+tha/gme;
  q=(1-0.8*exp(-dlsa/50e3))*dh;
  q=0.78*q*exp(-(q/16)^0.25);
  afo=min(15, 2.171*log(1+4.77e-4*hg(1)*hg(2)*wn*q));
  qk=1/abs(zgnd);
  aht=20;
  xht=0;
  for jj=1:2
    a=0.5*dl(jj)^2/he(jj);
    wa=(a*wn)^third;
    pk=qk/wa;
    q=(1.607-pk)*151*wa*dl(jj)/a;
    xht=xht+q;
    aht=aht+fht(q, pk);
  end
  res=0;
else % d == 0
  th=tha+d*gme;
  ds=d-dla;
  q=0.0795775*wn*ds*th^2;
  res=aknfe(q*dl(1)/(ds+dl(1)))+aknfe(q*dl(2)/(ds+dl(2)));
  a=ds/th;
  wa=(a*wn)^third;
  pk=qk/wa;
  q=(1.607-pk)*151*wa*th+xht;
  ar=0.05751*q-4.343*log(q)-aht;
  q=(wd1+xd1/d)*min(((1-0.8*exp(-d/50e3))*dh*wn), 6283.2);
  wd=25.1/(25.1+sqrt(q));
  res=ar*wd+(1-wd)*res+afo;
end % d == 0
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=ahd(td)

a = [133.4 104.6 71.8];
b = [0.332e-3 0.212e-3 0.157e-3];
c = [-4.343, -1.086, 2.171];

if td <= 10e3 
  ii=1;
elseif td <= 70e3
  ii=2;
else
  ii=3;
end
res = a(ii)+b(ii)*td+c(ii)*log(td);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=aknfe(v2)
if v2 < 5.76
  res = 6.02+9.11*sqrt(v2)-1.27*v2;
else
  res = 12.953+4.343*log(v2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=alos(d)

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
%global dlsa dx ael ak1 ak2 aed emd aes ems dls dla tha
global wn dh zgnd he
global dlsa aed emd
persistent wls

if d == 0
  wls=0.021/(0.021+wn*dh/max(10e3, dlsa));
  res=0;
else
  q=(1-0.8*exp(-d/50e3))*dh;
  s=0.78*q*exp(-(q/16)^0.25);
  q=he(1)+he(2);
  sps=q/sqrt(d^2+q^2);
  r=(sps-zgnd)/(sps+zgnd)*exp(-min(10, wn*s*sps));
  q=abs(r)^2;
  if q < .25 || q < sps
    r=r*sqrt(sps/q);
  end
  res=emd*d+aed;
  q=wn*he(1)*he(2)*2/d;
  if q > 1.57
    q=3.14-2.4649/q;
  end
  res=(-4.343*log( abs((cos(q)-1j*sin(q))+r)^2 )-res)*wls+res;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=ascat(d)

%global kwx aref mdp dist hg wn dh ens gme zgnd he dl the
%global dlsa dx ael ak1 ak2 aed emd aes ems dls dla tha
global wn ens gme he dl the tha
persistent ad rr etq h0s


if d == 0 
  ad=dl(1)-dl(2);
  rr=he(2)/he(1);
  if ad < 0 
    ad = -ad;
    rr=1/rr;
  end
  etq=(5.67e-6*ens-2.32e-3)*ens+0.031;
  h0s=-15;
  res=0;
else  % d == 0 
  if h0s > 15
    h0=h0s;
  else
    th=the(1)+the(2)+d*gme;
    r2=2.*wn*th;
    r1=r2*he(1);
    r2=r2*he(2);
    if r1 < .2 && r2 < .2
      res=1001;
      return;
    end
    ss=(d-ad)/(d+ad);
    q=rr/ss;
    ss=max(0.1, ss);
    q=min(max(0.1, q), 10);
    z0=(d-ad)*(d+ad)*th*0.25/d;
    et=(etq*exp(-min(1.7, z0/8.0e3)^6)+1)*z0/1.7556e3;
    ett=max(et, 1);
    h0=(h0f(r1, ett)+h0f(r2, ett))*0.5;
    h0=h0+min(h0, (1.38-log(ett))*log(ss)*log(q)*0.49);
    h0=dim(h0, 0);
    if et < 1
      h0 = et*h0+(1-et)*4.343*log(((1+1.4142/r1)*(1+1.4142/r2))^2*...
                                  (r1+r2)/(r1+r2+2.8284));
    end
    if h0 > 15 && h0s >= 0
      h0=h0s;
    end
  end
  h0s=h0;
  th=tha+d*gme;
  res=ahd(th*d)+4.343*log(47.7*wn*th^4)-0.1*(ens-301)*...
      exp(-th*d/40e3)+h0;
end % d == 0 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=curv(c1, c2, x1, x2, x3, de)
res = (c1+c2/(1+((de-x2)/x3)^2))*((de/x1)^2)/(1+((de/x1)^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=dim(a, b)
res=0;
if a > b
  res = a-b;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function res=dlthx(pfl, x1, x2)
%
% s=zeros(247, 1);
%
% np=pfl(1);
% xa=x1/pfl(2);
% xb=x2/pfl(2);
% res=0;
% if xb-xa < 2
%   return;
% end
% ka=fix(0.1*(xb-xa+8));
% ka=min(max(4, ka), 25);
% n=10*ka-5;
% kb=n-ka+1;
% sn=n-1;
% s(1)=sn;
% s(2)=1;
% xb=(xb-xa)/sn;
% k=xa+1;
% xa=xa-k;
% for jj=1:n
%   while xa > 0 && k < np
%     xa=xa-1.;
%     k=k+1;
%   end
%   s(jj+2)=pfl(k+3)+(pfl(k+3)-pfl(k+2))*xa;
%   xa=xa+xb;
% end
% [xa, xb]=zlsq1(s, 0, sn);
% xb=(xb-xa)/sn;
% for jj=1:n
%   s(jj+2)=s(jj+2)-xa;
%   xa=xa+xb;
% end
% [ss1, res1]=qtile(n, s(3:end), ka);
% [ss2, res2]=qtile(n, ss1, kb);
% res=res1-res2;
% res=res/(1.-0.8*exp(-(x2-x1)/50e3));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=fht(x, pk)

if x < 200
  w = -log(pk);
  if pk < 1e-5 || x*w^3 > 5495
    res = -117;
    if x > 1
      res = 17.372*log(x)+res;
    end
  else
    res = 2.5e-5*x^2/pk-8.686*w-15;
  end
else
  res = 0.05751*x-4.343*log(x);
  if x < 2000 
    w=0.0134*x*exp(-0.005*x);
    res=(1-w)*res+w*(17.372*log(x)-117);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=h0f(r, et)
a = [25 80 177 395 705];
b = [24 45 68 80 105];
it = fix(et);
if it <= 0
  it=1;
  q=0;
elseif it >= 5
  it=5;
  q=0;
else
  q=et-it;
end
x=(1/r)^2;
res=4.343*log((a(it)*x+b(it))*x+1);
if q ~= 0
  res=(1-q)*res+q*4.343*log((a(it+1)*x+b(it+1))*x+1);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [a, res]=qtile(nn, aa, ir)
% a=aa;
% m=1;
% n=nn;
% k=min(max(1, ir), n);
%
% q=a(k);
% i0=m;
% j1=n;
% while 1
%   for ii=i0:n
%     if a(ii) < q
%       break;
%     end
%   end
%   for jj=j1:-1:m
%     if a(jj) > q
%       break;
%     end
%   end
%   if ii < jj
%     r=a(ii);
%     a(ii)=a(jj);
%     a(jj)=r;
%     i0=ii+1;
%     j1=jj-1;
%   elseif ii < k
%     a(k)=a(ii);
%     a(ii)=q;
%     m=ii+1;
%     q=a(k);
%     i0=m;
%     j1=n;
%   elseif jj > k
%     a(k)=a(jj);
%     a(jj)=q;
%     n=jj-1;
%     q=a(k);
%     i0=m;
%     j1=n;
%   else
%     res = q;
%     return;
%   end
% end % while

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [z0, zn]=zlsq1(z, x1, x2)
%
% xn = z(1);
% xa = fix(dim(x1/z(2), 0));
% xb = xn-fix(dim(xn, x2/z(2)));
% if xb <= xa
%   xa = dim(xa, 1);
%   xb = xn - dim(xn, xb+1);
% end
% ja=fix(xa);
% jb=fix(xb);
% n=jb-ja;
% xa=xb-xa;
% x=-0.5*xa;
% xb=xb+x;
% a=0.5*(z(ja+3)+z(jb+3));
% b=0.5*(z(ja+3)-z(jb+3))*x;
% for ii=2:n
%   ja=ja+1;
%   x=x+1;
%   a=a+z(ja+3);
%   b=b+z(ja+3)*x;
% end
% a=a/xa;
% b=b*12/((xa*xa+2)*xa);
% z0=a-b*xb;
% zn=a+b*(xn-xb);




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

