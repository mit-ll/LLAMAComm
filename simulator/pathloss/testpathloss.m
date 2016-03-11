% % Add Paths
% addpath('../')  % Gain access to @node object methods
% addpath('./propmodels')
% addpath('../tools')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build environment struct
envParams.scenarioType = 'rural'; % Scenario type: 'urban', 'suburban' or 'rural'
envParams.building.roofHeight = 4; % (m) Average roof height in scenario
envParams.los_dist = 50; % (m) line-of-sight distance between nodes

% Build transmitter node struct
txnode.antType = 'dipole_halfWavelength';
txnode.polarize = 'v'; % Choose from 'v' or 'h'
txnode.ant_az = 0;
txnode.ant_el = 0;
%txnode.building.extwallmat = 'none'; % 'none' or 'concrete'
%txnode.building.intdist = 0; % (m) distance from interior to outside wall
txnode.building.extwallmat = 'concrete'; % 'none' or 'concrete'
txnode.building.intdist = 3; % (m) distance from interior to outside wall
txnode.building.intwalls = 0; % number of intervening intererior walls
txnode.building.extbldgangle = 60; % (degrees) See diagram below for explanation
txnode.antLocation = [0 0 0]; % (m,m,m) Ant location relative to the node location
txnode.location = [1000 0 1]; % (m,m,m) Location of ants
txnode.fc = 620e6; % (Hz) Center frequency of band

% Build receiver node struct
rxnode.antType = 'dipole_halfWavelength';
rxnode.polarize = 'v'; % 'v' or 'h'
rxnode.ant_az = 0;
rxnode.ant_el = 0;
rxnode.building.extwallmat = 'none'; % 'none' or 'concrete'
rxnode.building.intdist = 0; % (m) distance from interior to outside wall
rxnode.building.intwalls = 0; % number of intervening intererior walls
rxnode.building.extbldgangle = 0; % (degrees) See diagram below for explanation
rxnode.antLocation = [0 0 0]; % (m,m,m) Ant location relative to the node location
rxnode.location = [0 0 3000]; % (m,m,m) Location of ants
rxnode.fc = 620e6; % (Hz) Center frequency of band


txnodelocation = logspace(1,6,100);
rxnodeheight = 3000;

if length(txnodelocation)>1 % Test pathloss at different ranges
  medLdb = zeros(size(txnodelocation));      % median pathloss, dB
  stdLdb = zeros(size(txnodelocation));      % pathloss standard deviation, dB
  for ii=1:length(txnodelocation)
    txnode.location(1) = txnodelocation(ii);
    [ medLdb(ii) stdLdb(ii) ] = getPathloss(txnode,rxnode,envParams);
  end;

  clf;
  semilogx(txnodelocation,medLdb);
  xlabel('Range (m)');
  ylabel('Pathloss (dB)');
  
  %   K = 1.38e-23; % Boltzmann's constant
  %   T = 300; % (Kelvin) Receiver temperature
  %   P = 1; % (W)
  %   No = K*T; % (W/Hz) Noise energy
  %   B = 2e6; % (Hz) Bandwidth
  %   NfdB = 10; % (dB) Noise figure
  
  %   SNRdB = 10*log10(P) - medLdb - 10*log10(No*B) - NfdB;
  
  %   titlestr = [envParams.scenarioType,', ',num2str(rxnode.fc/1e6),...
  %               ' MHz, BW = ',num2str(B/1e6),' MHz, P = ',...
  %               num2str(P),' W'];
  
  %   plotParams
  %   semilogx(txnodelocation,SNRdB);
  %   hold on
  %   semilogx(txnodelocation,SNRdB + stdLdb,'r--')
  %   semilogx(txnodelocation,SNRdB - stdLdb,'r--')
  %   hold off
  %   title(titlestr)
  %   xlabel(['Range (m), ',' Rx height ',...
  %           num2str(rxnode.location(3)),...
  %           ' m, Tx height ',num2str(txnode.location(3)),' m',...
  %           ', noise fig ',num2str(NfdB),' dB.']);
  %   ylabel('Median SNR (dB)');
  %   grid on;
  %   dumpFig([envParams.scenarioType,num2str(rxnode.fc/1e6),'MHz']);

elseif length(rxnodeheight)>1 % test pathloss at different Rx heights
  medLdb = zeros(size(rxnodeheight));      % median pathloss, dB
  stdLdb = zeros(size(rxnodeheight));      % pathloss standard deviation, dB
  for ii=1:length(rxnodeheight)
    rxnode.location(3) = rxnodeheight(ii);
    [ medLdb(ii) stdLdb(ii) ] = getPathloss(txnode,rxnode,envParams);
  end;

  clf;
  plot(rxnodeheight,medLdb);
  xlabel('Rx Height (m)');
  ylabel('Median Pathloss (dB)');
  grid on;

end;


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


