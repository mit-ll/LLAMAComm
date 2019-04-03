function k = link(a)

% LINK class constructor

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

if nargin == 0
    k = emptyLink;
    k = class(k,'link');
elseif isa(a,'link')
    k = a;
elseif isstruct(a)
    k = emptyLink;

    % Channel information
    k.channel = a.channel;
    k.pathLoss = a.pathLoss;
    k.chanTail = a.chanTail;
    k.propParams = a.propParams;

    % Inband filter information
    k.filterTaps = a.filterTaps;

    % Anti-alias filter
    k.antialiasTaps = a.antialiasTaps;

    % Link ID's
    k.fromID = a.fromID;
    k.toID = a.toID;

    k = class(k,'link');
else
    error('Bad input argument to LINK constructor.');
end


function k = emptyLink()

% Channel information
k.channel = [];
k.pathLoss = [];
k.chanTail = [];
k.propParams = [];

% Inband filter information
k.filterTaps = [];
k.filterTail = [];
k.freqOverlapMethod = [];

% Anti-alias filter
k.antialiasTaps = [];

% Filter and Channel tails are valid to this sample number
k.validTo = [];

% Link ID's
k.fromID = {};  % {nodeName, moduleName}
k.toID = {};    % {nodeName, moduleName, fc}

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


