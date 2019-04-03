function [hTime,linkInfo] = SampleHtensor(linkobj,startSamps,sampRate)

% Function @link/SampleHtensor.m:
% Get the impulse response of the channel tensor as a function of time.
%
% USAGE: [hTime, linkInfo] = SampleHtensor(linkobj,startSamps,sampRate)
%
% Input arguments:
%  linkobj      (link obj) Link object
%  startSamps   (double array) sample times
%  sampRate     (double) Sample rate
%
%
% Output arguments:
%  hTime        (nR x nT x nLag x length(startSamps) double) Sampled channel
%  linkInfo     (string) Link information (from:to)
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


% Extract some link parameters for viewing
linkInfo.linkName = sprintf('\n   ''%s:%s'' -> ''%s:%s:%.2f Mhz''',...
            linkobj.fromID{1},linkobj.fromID{2},...
            linkobj.toID{1},linkobj.toID{2},linkobj.toID{3}/1e6);
linkInfo.channel    = linkobj.channel;
linkInfo.pathLoss   = linkobj.pathLoss;
linkInfo.propParams = linkobj.propParams;

% Call the SampleHtensor.m function in /simulator/channel
hTime = SampleHtensor(linkobj.channel,linkobj.propParams,...
                      startSamps,sampRate);

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


