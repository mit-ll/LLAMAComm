function pathLoss = GetPathlossStruct(nodeTx,modTx,nodeRx,modRx,envParams)

% Function '@node/GetPathlossStruct.m':  
% Builds pathLoss struct which contains relevant parameters relating 
% to pathloss of the link.  This code interfaces LLamaComm with the
% pathloss code written by Bruce McGuffin for Cogcom.
%
% USAGE:  pathLoss = GetPathlossStruct(nodeTx,modTx,nodeRx,modRx,envParams)
%
% Input arguments:
%  nodeTx       (node obj) Node transmitting
%  modTx        (module obj) Module transmitting
%  nodeRx       (node obj) Node receiving
%  modRx        (module obj) Module receiving
%  envParams    (struct) Structure containing environment parameters
%
% Output argument:
%  pathLoss     (struct) Structure containing pathloss parameters
%

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

DEBUGGING = false;  % make antenna plots

% Build transmitter node struct to interface with getPathloss(...)
txantenna = GetAntennaParams(modTx);
txnode.name = nodeTx.name;
txnode.antType = txantenna.antType;
txnode.antPosition = txantenna.antPosition;
txnode.polarize = txantenna.antPolarization;
txnode.ant_az = txantenna.antAzimuth;
txnode.ant_el = txantenna.antElevation;
txnode.building.extwallmat = txantenna.exteriorWallMaterial;
txnode.building.intdist = txantenna.distToExteriorWall;
txnode.building.intwalls = txantenna.numInteriorWalls;
txnode.building.extbldgangle = txantenna.exteriorBldgAngle;
txnode.antLocation = txantenna.antPosition; 
txnode.location = nodeTx.location;
txnode.fc = GetFc(modTx);

% Build receiver node struct to interface with getPathloss(...)
rxantenna = GetAntennaParams(modRx);
rxnode.name = nodeRx.name;
rxnode.antType = rxantenna.antType;
rxnode.polarize = rxantenna.antPolarization;
rxnode.ant_az = rxantenna.antAzimuth;
rxnode.ant_el = rxantenna.antElevation;
rxnode.building.extwallmat = rxantenna.exteriorWallMaterial;
rxnode.building.intdist = rxantenna.distToExteriorWall;
rxnode.building.intwalls = rxantenna.numInteriorWalls;
rxnode.building.extbldgangle = rxantenna.exteriorBldgAngle;
rxnode.antLocation = rxantenna.antPosition; 
rxnode.location = nodeRx.location;
rxnode.fc = GetFc(modRx);

% Calculate pathloss from transmit node to receive node
[rangeLoss,shadowStd,externalNoise] = getPathloss(txnode,rxnode,envParams);

% Find the shadow link index
linkIndex = FindShadowLinkIndex(envParams.shadow.linkNames,...
                                GetNodeName(nodeTx),GetNodeName(nodeRx));

%% Calculate the weighted shadowloss:
%
% Y = Lambda*Z'
%
% where Lambda is a diagonal matrix of shadowloss standard deviations and
% Z' is the unweighted correlated shadowloss realization.
% Recall that Z' has been setup previously in Main.m by calling 
% @environment/SetupShadowloss.m.  Z' is defined as follows:
%
% Z' = sqrtm(Krho)*Z, 
%
% where Z is a realization from a vector-valued i.i.d. standard normal
% distribution and Krho is the shadowloss correlation matrix obtained
% by calling pathloss/GetShadowlossCorrMatrix.m.
shadowCorrLoss = envParams.shadow.corrLoss(linkIndex);
shadowLoss = shadowCorrLoss*shadowStd;

% % Calculate antenna gain
%[antGainTx, antGainRx, thetatx, phitx, thetarx, phirx] = ...
% getantgain(txnode,rxnode);
[antGainTx, antGainRx] = getantgain(txnode,rxnode);

% Total antenna gain
antGain = antGainTx + antGainRx;

% Get total path attenuation (dB)
totalPathLoss = rangeLoss + shadowLoss - antGain;

% Get the Rician K-factor
[ Kdb, medKdb ] = getRiceK(txnode,rxnode,totalPathLoss);

% Calculate separation between nodes (for display purposes only)
distBetweenNodes = norm(nodeTx.location - nodeRx.location);

% Build the output struct
pathLoss.shadowLinkIndex = linkIndex;
pathLoss.rangeLoss = rangeLoss;
pathLoss.shadowCorrLoss = shadowCorrLoss;
pathLoss.shadowStd = shadowStd;
pathLoss.shadowLoss = shadowLoss;
pathLoss.externalNoise = externalNoise;
pathLoss.noiseFigure = GetNoiseFigure(modRx);
pathLoss.antGainTx = antGainTx;
pathLoss.antGainRx = antGainRx;
pathLoss.totalPathLoss = totalPathLoss;
pathLoss.riceKdB = Kdb;
pathLoss.riceMedKdB = medKdb;
pathLoss.distBetweenNodes = distBetweenNodes;

if DEBUGGING
  1; %#ok if unreachable
  figure; 
  PlotAnts(txnode,rxnode,thetatx,phitx,thetarx,phirx);
  % Make figure name the name of the link
  set(gcf,'Name',[txnode.name,':',GetModuleName(modTx),...
                  '->',...
                  rxnode.name,':',GetModuleName(modRx),...
                  ':',num2str(GetFc(modRx)/1e6),'MHz']);
end

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


