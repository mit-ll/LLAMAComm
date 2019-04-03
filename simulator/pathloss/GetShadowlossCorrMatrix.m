function [Krho, linkNames] = GetShadowlossCorrMatrix(nodeArray,linkMatrix)

% Function 'pathloss/GetShadowlossCorrMatrix.m':
%
% USAGE:  Krho = GetShadowlossCorrMatrix(nodeArray,linkMatrix)
%
% Input arguments:
%  nodeArray (struct array) structure with the following fields
%   .type      (string) 'transmitter', 'receiver', or 'transceiver'
%   .name      (string) Node name returned by GetNodeName(nodeobj)
%   .location  (1 x 3 double) (m) 3-D location of node
%  linkMatrix  (N x N double) Symmetric Boolean matrix indicating
%                             links between nodes.  N is the number
%                             of nodes.
%
% Output arguments:
%  Krho        (M x M double) Shadowloss correlation matrix. M is the
%                             number of links.
%  linkNames   (1 X M cell)   Cell array of link names.  Each cell is
%                             an array of names of the two linked nodes,
%                             e.g., linkNames{1} = {'nodeA','nodeB'};

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

% If ther are no links, then quit gracefully with an error message
if ~sum(sum(linkMatrix))
  error('  LLAMAComm is quitting because there are no links to simulate')
end

nNodes = length(nodeArray);

% convert to double preciaion in case linkMatrix is a logical array
linkMatrix = double(linkMatrix);

% Put zeros along the linkMatrix diagonal (Assume no self links)
linkMatrix = linkMatrix - diag(diag(linkMatrix));

% Determine the number of links,
% modify linkMatrix so non-zero entry is link index into correlation
% matrix
nLinks = 0;
for ii=1:nNodes
  for jj=ii+1:nNodes
    if linkMatrix(ii,jj)>0
      nLinks = nLinks+1;
      linkMatrix(ii,jj) = nLinks;
      linkMatrix(jj,ii) = nLinks;
    end
  end
end


% find link correlations
Krho = eye(nLinks);
linkNames = cell(1, nLinks);
for ii=1:nLinks
  [nodei1, nodei2] = ind2sub(size(linkMatrix), ...
                             find(linkMatrix==ii,1,'first'));
  linkNames{ii} = {nodeArray(nodei1).name, nodeArray(nodei2).name};

  % There may be problems if the nodes share the same x and y coordinates
  if nodeArray(nodei1).location(1:2) == nodeArray(nodei2).location(1:2)
    warning(['llamacomn:pathloss:',mfilename,':ColocatedNodes'], ...
            [nodeArray(nodei1).name,' and ',nodeArray(nodei2).name,...
             ' share the same x and y coordinates!!  This may cause problems!!'])
  end

  for jj = ii+1:nLinks
    [nodej1, nodej2] = ind2sub(size(linkMatrix), ...
                               find(linkMatrix==jj,1, 'first'));
    Krho(ii,jj) = shadowCorrUncommon([ nodeArray(nodei1).location; ...
                        nodeArray(nodei2).location ], ...
                                     [ nodeArray(nodej1).location; ...
                        nodeArray(nodej2).location ]);
    Krho(jj,ii) = Krho(ii,jj);
  end
end

% if required, diagonal load Krho to make positive definite
RR = Krho;
lambda = eig(RR);
delta = 0.0;
while min(lambda)<=0
  delta = delta+0.05;
  RR = ( RR + delta*eye(nLinks) )./(1+delta);
  lambda = eig(RR);
end
Krho = RR;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rho = shadowCorrUncommon(nodes1,nodes2)
% given node locations for two radio links with no common node
% return the correlation coefficient for log-normal shadowing loss
% in dB-domain.
% inputs: nodes1 = 2-row matrix, each row is x,y or x,y,z location of
%                  link 1 nodes
%         nodes2 = 2-row matrix, each row is x,y or x,y,z location of
%                  link 1 nodes
% output: rho    = shadowing cross-correlation

% verify input arguments
if nargin<2
  error('Too few arguments, function shadowCorrUncommon');
end
if (size(nodes1,1)<2 || size(nodes2,1)<2)
  error('Input arguments too short, function shadowCorrUncommon');
end
if (size(nodes1,2)<2 || size(nodes2,2)<2)
  error('Input arguments too short, function shadowCorrUncommon');
end

% check for common node in two links, treat as special case
if all(nodes1(1,1:2)==nodes2(1,1:2))
  rho = shadowCorrFromLoc(nodes1(1,:),nodes1(2,:),nodes2(2,:));
  return;
elseif all(nodes1(1,1:2)==nodes2(2,1:2))
  rho = shadowCorrFromLoc(nodes1(1,:),nodes1(2,:),nodes2(1,:));
  return;
elseif all(nodes1(2,1:2)==nodes2(1,1:2))
  rho = shadowCorrFromLoc(nodes1(2,:),nodes1(1,:),nodes2(2,:));
  return;
elseif all(nodes1(2,1:2)==nodes2(2,1:2))
  rho = shadowCorrFromLoc(nodes1(2,:),nodes1(1,:),nodes2(1,:));
  return;
end

% general case: no common node => average possible connecting links
rho = (  shadowCorrFromLoc(nodes1(1,:),nodes1(2,:),nodes2(1,:))* ...
         shadowCorrFromLoc(nodes2(1,:),nodes2(2,:),nodes1(1,:))  ...
         + shadowCorrFromLoc(nodes1(2,:),nodes1(1,:),nodes2(2,:))* ...
         shadowCorrFromLoc(nodes2(2,:),nodes2(1,:),nodes1(2,:))  ...
         + shadowCorrFromLoc(nodes1(1,:),nodes1(2,:),nodes2(2,:))* ...
         shadowCorrFromLoc(nodes2(2,:),nodes2(1,:),nodes1(1,:))  ...
         + shadowCorrFromLoc(nodes1(2,:),nodes1(1,:),nodes2(1,:))* ...
         shadowCorrFromLoc(nodes2(1,:),nodes2(2,:),nodes1(2,:))  ...
         )/4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rho = shadowCorrFromLoc(commonNode,endNode1,endNode2)
% function rho = shadowCorrFromLoc(commonNode,endNode1,endNode2)
% given node locations for two different radio links with one
% common node
% return the correlation coefficient
% for log-normal shadowing loss in dB-domain.
% inputs:  commonNode = 2-vector x, y,  or 3-vector x, y, z location
%                       of common node in link
% inputs: endNode1 = 2-vector x, y,  or 3-vector x, y, z location
%                     of node at end of one link
%         endNode2 = 2-vector x, y,  or 3-vector x, y, z location
%                     of node at end of other link
% output: rho      = shadowing cross-correlation

if nargin<3
  error('Too few arguments, function shadowCorrFromLoc');
end
if length(commonNode)<2 || length(endNode1)<2 || length(endNode2)<2
  error('Input arguments too short, function shadowCorrFromLoc');
end

% get bearing angles from common to end nodes, in degrees
theta1 = getbearing(commonNode,endNode1);
theta2 = getbearing(commonNode,endNode2);


% get angle difference, on [0,180]
deltheta = mod(theta1-theta2,360);
deltheta(deltheta>180) = deltheta(deltheta>180)-360;
deltheta = abs(deltheta);

% get correlation
rho = 0.7479 - 0.0039*deltheta;
rho(deltheta>90) = 0.3933;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psi = getbearing(loc1,loc2)
% function psi = bearing(loc1,loc2);
% Given two locations return bearing angle from first location, looking
% towards second. Bearing angle is measured CCL from east, in degrees

if all(loc1(1:2)==loc2(1:2))
  psi = nan;
  return;
end

psi = 180/pi * atan2(loc2(2)-loc1(2),loc2(1)-loc1(1));
psi = mod(psi,360);


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


