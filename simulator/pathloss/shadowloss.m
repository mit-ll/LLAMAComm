function Ls = shadowloss(an,dn,env)
% given a full set of nodes, return a set of correlated shadow
% loss values (dB) with the desired statistics (standard deviation
% and cross-correlation). 
% output vector is 
% [ an->dn shadow loss; 
%   is->an shadow loss; 
%   is->dn shadow loss ];

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

% get correlation matrix and standard deviation vector
[RR, ss] = getshadowcorr(an,dn,env);

% fill in missing correlation matrix entries
NN = size(RR,1);
Ni = (NN-1)/2;   % number of interferers
R1 = RR;
for mm=2:Ni+1
  for nn=Ni+2:2*Ni+1
    if RR(mm,nn)==0
      R1(mm,nn) = mean([ RR(mm,1)*RR(1,nn),RR(mm,mm+Ni)*RR(mm+Ni,nn),RR(mm,nn-Ni)*RR(nn-Ni,mm)]);
      R1(nn,mm) = R1(mm,nn);
    end
  end
end

% if required, diagonal load correlation matrix
R2 = R1;
[QQ,D2] = eig(R2);
delta = 0.0;
while min(diag(D2))<=0
  delta = delta+0.05;
  R2 = ( R1 + delta*eye(NN) )./(1+delta);
  [QQ,D2] = eig(R2);
end

% find matrix to transform independent rv's to correlated rv's
QQ = QQ*sqrtm(D2); % matrix transforms uncorrelated rv's to correlated

% generate correlated rv's, and set standard deviation
Ls = diag(ss)*QQ*randn(size(ss));

% implement prefferential siting, if called for
if env.sitingEnable == 1
  count=0;
  while Ls(1)>-ss(1)
    count = count+1;
    Ls = diag(ss)*QQ*randn(size(ss));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ RR, ss ] = getshadowcorr(an,dn,env)
% given a full set of nodes, return a matrix RR of the shadowing
% correlation coefficients for different node pairs.
% RR(i,j) = E{((r(i)-mu(i))(r(j)-mu(j))}/( sigma_i sigma_j )
% where node index order is (1) DN->AN link
%                           (2) IS->AN link
%                           (3) IS->DN link
% e.g. R(1,2) is correlation of DN->AN shadowing with IS(1)->AN shadowing
% Also returns a vector of standard deviations in same order

Ni = length(env.is); % number of interference sources
Nl = 2*Ni+1;         % total number of links

% vector of shadow loss standard deviations, Nlx1 
ss = zeros(Nl,1);  

% matrix of shadow loss correlation coefficients 
RR = eye(Nl);

% find correlation between an->dn link and others
ss(1) = env.d2a.stdLdb;
for jj=1:Ni  % correlate an->dn with is->an at an
  psi_a2d = bearing(an.location,dn.location); 
  psi_a2i = bearing(an.location,env.is(jj).location);
  RR(1,jj+1) = shadowcorr(psi_a2d,psi_a2i);
  RR(jj+1,1) = RR(1,jj+1);
end
for jj=1:Ni % correlate an->dn with is->dn at dn
  psi_d2a = bearing(dn.location,an.location); 
  psi_d2i = bearing(dn.location,env.is(jj).location);
  RR(1,jj+Ni+1) = shadowcorr(psi_d2a,psi_d2i);
  RR(jj+Ni+1,1) = RR(1,jj+Ni+1);
end

% find correlations between different is->an links
for ii=1:Ni
  ss(ii+1) = env.i2a.stdLdb(ii);
  psi_a2i = bearing(an.location,env.is(ii).location);
  for jj=ii+1:Ni
    psi_a2j = bearing(an.location,env.is(jj).location);
    RR(ii+1,jj+1) = shadowcorr(psi_a2i,psi_a2j);
    RR(jj+1,ii+1) = RR(ii+1,jj+1);
  end
end

% find correlations between different is->dn links
for ii=1:Ni
  ss(ii+Ni+1) = env.i2d.stdLdb(ii);
  psi_d2i = bearing(dn.location,env.is(ii).location);
  for jj=ii+1:Ni
    psi_d2j = bearing(dn.location,env.is(jj).location);
    RR(ii+Ni+1,jj+Ni+1) = shadowcorr(psi_d2i,psi_d2j);
    RR(jj+Ni+1,ii+Ni+1) = RR(ii+Ni+1,jj+Ni+1);
  end
end

% find correlations between is->an and is->dn links
for ii=1:Ni
  psi_i2a = bearing(env.is(ii).location,an.location);
  psi_i2d = bearing(env.is(ii).location,dn.location);
  RR(ii+1,ii+Ni+1) = shadowcorr(psi_i2a,psi_i2d);
  RR(ii+Ni+1,ii+1) = RR(ii+1,ii+Ni+1);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function psi = bearing(loc1,loc2)
% function psi = bearing(loc1,loc2);
% Given two locations return bearing angle from first location, looking
% towards second. Bearing angle is measured CCL from east, in degrees

if all(loc1(1:2)==loc2(1:2))
  psi = nan;
  return;
end

psi = atan2(loc2(2)-loc1(2),loc2(1)-loc1(1));
psi = mod(psi,2*pi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rho = shadowcorr(theta1,theta2)
% function rho = shadowcorr(theta1,theta2)
% given bearing angles of two different signals from a common
% transmitter or receiver, return the correlation coefficient
% for log-normal shadowing loss in dB-domain.
% inputs:  theta1 = first angle of bearing, radians
%          theta2 = second angle of bearing, radians
% output:  rho    = shadowing cross-correlation vector

ok = checkmatscalar(theta1,theta2);
if ~ok
  error('All non-scalar arguments must be same size, function shadowcorr');
end

% get angle difference, on [0,180]
r2d = 180/pi;
deltheta = mod(r2d*(theta1-theta2),360);
deltheta(deltheta>180) = deltheta(deltheta>180)-360;
deltheta = abs(deltheta);

% get correlation
rho = 0.7479 - 0.0039*deltheta;
rho(deltheta>90) = 0.3933;


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


