function nSamps = FindMaxTxSamps(nodes)

% Function '@nodes/FindMaxTxSamps.m':
%  Finds the longest transmit time (in samples).  This function is
%  used after a run has completed.
%
% USAGE:  nSamps = FindMaxTxSamps(nodes)
%
% Input arguments:
%  nodes       (node obj array) Array of node objects
%
% Output argument:
%  nSamps      (int) Maximum transmitted samples
%

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

% max number of transmit samples
txSampsMax = 0;

for nodeLoop = 1:length(nodes)
    % Get the node parameters
    nodeobj = nodes(nodeLoop);

    % Loop over the modules
    for modLoop = 1:length(nodeobj.modules)
        % Get the module parameters
        modobj = nodeobj.modules(modLoop);

        % Make sure module is a transmit module
        if strcmp(GetType(modobj),'transmitter') ...
                  && ~IsGenie(nodeobj.modules(modLoop))

            % Get the number of samples transmitted
            modHist = GetHistory(modobj);
            endHist = modHist{end};
            txSampsCurr = endHist.start + endHist.blockLength - 1;

            % See if current length is greater than maximum so far
            if txSampsCurr > txSampsMax
                txSampsMax= txSampsCurr;
            end

        end

    end % end modLoop
end % end nodeLoop

% Create output
nSamps = txSampsMax;

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


