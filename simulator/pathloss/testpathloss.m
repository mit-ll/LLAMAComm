% % Add Paths
% addpath('../')  % Gain access to @node object methods
% addpath('./propmodels')
% addpath('../tools')

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

% Build environment struct
envParams.envType = 'rural'; % Scenario type: 'urban', 'suburban' or 'rural'
envParams.building.avgRoofHeight = 4; % (m) Average roof height in scenario
envParams.propParams.los_dist = 50; % (m) line-of-sight distance between nodes

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
    [medLdb(ii), stdLdb(ii)] = getPathloss(txnode,rxnode,envParams);
  end

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
  
  %   titlestr = [envParams.envType,', ',num2str(rxnode.fc/1e6),...
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
  %   dumpFig([envParams.envType,num2str(rxnode.fc/1e6),'MHz']);

elseif length(rxnodeheight)>1 % test pathloss at different Rx heights
  medLdb = zeros(size(rxnodeheight));      % median pathloss, dB
  stdLdb = zeros(size(rxnodeheight));      % pathloss standard deviation, dB
  for ii=1:length(rxnodeheight)
    rxnode.location(3) = rxnodeheight(ii);
    [medLdb(ii), stdLdb(ii)] = getPathloss(txnode,rxnode,envParams);
  end

  clf;
  plot(rxnodeheight,medLdb);
  xlabel('Rx Height (m)');
  ylabel('Median Pathloss (dB)');
  grid on;

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

