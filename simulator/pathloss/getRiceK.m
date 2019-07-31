function [ Kdb, medKdb ] = getRiceK(txnode, rxnode, Ldb)
% function [ Kdb, medKdb ] = getRiceK(txnode, rxnode, Ldb);
% Get random Rice K-factor for link between two nodes,
% K-factor is defined as ratio of specular (or dominant path) signal
% power to difuse (e.g., Rayleigh path) signal power.
% Also returns median value of KdB
%
% Input arguments:
%  txnode    (node object) Transmitter node
%  rxnode    (node object) Receiver node
%  Ldb       (environment object) average pathloss (median+shadowing) on link
%
% Output arguments:
%  Kdb      (scalar) Rice K-factor (db)
%  medKdb   (scalar) pseudo-Median value of K-factor for link (dB)
%
% Reference:
%
% P. Soma, D. S. Baum, V. Erceg, R. Krishnamoorthy, A. J. Paulraj,
% "Analyis and Modeling of Multiple-Input Multiple-Output (MIMO)
% Radio Channel Based on Outdoor Measurements Conducted at 2.5 GHZ
% for Fixed BWA Applications, " IEEE Intl. Conf. Communications, Vol. 1,
% 28 April - 2 May, 2002, pp 272-276.
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

% % Check input parameters
% if ~(strcmp(txnode.type, 'user') || strcmp(txnode.type, 'interf'))
%     error('txnode has no transmitter');
% end
% if ~(strcmp(rxnode.type, 'user') || strcmp(rxnode.type, 'hidden'))
%     error('rxnode has no receiver');
% end

% Extract building parameters from tx and rx nodes
txbuilding = txnode.building;
rxbuilding = rxnode.building;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract parameters used by propagation models

% range
dm  = sqrt( (rxnode.location(1) - txnode.location(1))^2 + ...
            (rxnode.location(2) - txnode.location(2))^2 + ...
            (rxnode.location(3) - txnode.location(3))^2 ); % range, m

% frequency
fmhz = rxnode.fc/1e6; % center frequency, mHz

% in-building range
if ~strcmp(txbuilding.extwallmat, 'none')  % tx is indoors
  ddtx = txbuilding.intdist;       % shortest in-building path length
else
  ddtx = 0;
end
if ~strcmp(rxbuilding.extwallmat, 'none')   % rx is indoors
  if isempty(rxbuilding.intdist) % same position as Tx at Rx site
    ddrx = rxbuilding.intdist;     % shortest in-building path length
  else % Rx-site Rx is not colocated with it's Tx
    ddrx = rxbuilding.intdist;     % shortest in-building path length
  end
else
  ddrx = 0;
end

% if Tx or Rx antennas are not all identical, K factor can be different
% for each antenna pair, make an NxM matrix of K's, N = # Tx antennas
% M = # Rx antennas. Figure out if this is the case:
if length(txnode.antType)== 1; txno = 1;
else
  txsame = zeros(length(txnode.antType));
  txsame(1) = 1;
  for ii=2:length(txsame)
    txsame = strcmp(txnode.antType{1}, ...
                    txnode.antType{ii});
  end
  if all(txsame)
    txno = 1;
  else
    txno = length(txsame);
  end
end
if length(rxnode.antType)== 1; rxno = 1;
else
  rxsame = zeros(length(rxnode.antType));
  rxsame(1) = 1;
  for ii=2:length(rxsame)
    rxsame = strcmp(rxnode.antType{1}, ...
                    rxnode.antType{ii});
  end
  if all(rxsame)
    rxno = 1;
  else
    rxno = length(rxsame);
  end
end

% antenna beamwidth -- search assumes az=0, el=0 is on antenna
% main lobe. If it's not, bad things will happen
Dtxdb = zeros(1, txno);
BWtx = zeros(1, txno);
for ii=1:txno
  azelmax = fminsearch(...
      @gainfunction, ...
      [0 0], ...
      [], ...
      fmhz, ...
      txnode.antType{ii}); %#ok - azelmax used below in 'eval'

  % azelmax used below in the 'eval'
  [temp, Dtxdb(ii)] = ...
      eval([ txnode.antType{ii} '(azelmax(1), azelmax(2), fmhz);']); %#ok - temp unused
  BWtx(ii) = 180/pi * 2*acos( 1 - 2/undb10(Dtxdb(ii)) ); % beamwidth, degrees
end
Drxdb = zeros(1, rxno);
BWrx = zeros(1, rxno);
for ii=1:rxno
  azelmax = fminsearch(...
      @gainfunction, ...
      [0 0], ...
      [], ...
      fmhz, ...
      rxnode.antType{ii}); %#ok - azelmax used below in 'eval'
  [temp, Drxdb(ii) ] = ...
      eval([ rxnode.antType{ii} '(azelmax(1), azelmax(2), fmhz);']); %#ok - temp unused
  BWrx(ii) = 180/pi * 2*acos( 1 - 2/undb10(Dtxdb(ii)) ); % beamwidth, degrees
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find K statistics for different locations

% pathloss related K-factor
medKlossdb = 16.3 - 0.239*(Ldb-los(dm, fmhz));

% K is a function of bandwidth, NxM matrix of K's, N = # Tx antennas
% M = # Rx antennas
BWtx = repmat(BWtx', 1, rxno);
BWrx = repmat(BWrx, txno, 1);
medKlossdb = medKlossdb - 6.2*bels( (BWtx.*BWrx)/1890 );
stdKlossdb = 8;
Klossdb    = medKlossdb + stdKlossdb*randn(1);

% indoor Tx K-factor component - currently assumes all Tx antennas are
% indoors, or all are outdoors
if ddtx > 0
  medKtxdb = 11.7 - .00379*fmhz;
  stdKtxdb = 4;
  Ktxdb    = medKtxdb + stdKtxdb*randn(1);
else
  Ktxdb    = inf;
end

% indoor Rx K-factor component - currently assumes all Rx antennas are
% indoors, or all are outdoors
if ddrx > 0
  medKrxdb = 11.7 - .00379*fmhz;
  stdKrxdb = 4;
  Krxdb    = medKrxdb + stdKrxdb*randn(1);
else
  Krxdb    = inf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine K-factors for overall value

Kloss = undb10(Klossdb);
medKloss = undb10(medKlossdb);
alphaloss = Kloss./(Kloss+1);
medalphaloss = medKloss./(medKloss+1); % this is the median of alphaloss

if isinf(Ktxdb)
  alphatx = 1;
  medalphatx = 1;
else
  Ktx        = undb10(Ktxdb);
  medKtx     = undb10(medKtxdb);
  alphatx    = Ktx/(Ktx+1);
  medalphatx = medKtx/(medKtx+1); % this is the median of alphatx
end

if isinf(Krxdb)
  alpharx = 1;
  medalpharx = 1;
else
  Krx        = undb10(Krxdb);
  medKrx     = undb10(medKrxdb);
  alpharx    = Krx/(Krx+1);
  medalpharx = medKrx/(medKrx+1); % this is the median of alpharx
end

alpha = alphatx*alphaloss*alpharx;
medalpha = medalphatx*medalphaloss*medalpharx; % this is probably not the
                                               % median of alpha, it is the product of the medians of the compenent terms

% convert alpha to K-factors
Kdb(alpha<1) = db10(alpha./(1-alpha));
Kdb(alpha==0) = 30;
medKdb(medalpha<1) = db10(medalpha./(1-medalpha));
medKdb(medalpha==1) = 30;

% Subtract 3 dB from the K-factor (We subtract to compensate for the
% space-time alpha factor already included in Dan's channel generator).
Kdb = Kdb - 3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minD = gainfunction(azel, fmhz, antenna); %#ok - azel, fmhz unused
% function allows search for antenna coordinates with
% maximum directivity
% inputs:   azel = 2-vector, [ azimuth elevation ], both degrees
%           fmhz = frequency, MHz
%           antenna = (string) name of antenna function
% output:   minD = inverse of antenna directivity at provided coordinates

[temp, DD] = eval([ antenna '(azel(1), azel(2), fmhz)']); %#ok - temp unused
minD = -DD;


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


