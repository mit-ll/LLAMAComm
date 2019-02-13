function [hTime,linkInfo] = GetChannelResponse(env,linkNum,time,sampRate)

% Function env/GetChannelResponse.m:
% Get the impulse response of the channel as a function of time.
%
% USAGE: [hTime, linkInfo] = GetChannelResponse(env,linkNum,startSamps,sampRate)
%
% Input arguments:
%  env          (class environment) environment object
%  linkNum      (int) Index into link array
%  time         (double array) (sec) Channel impulse response start times
%  sampRate     (double) (Hz) Simulation sample rate
%
% Output arguments:
%  hTime        (nR x nT x nLag x length(startSamps) Impulse response
%  linkInfo     (struct) Structure containing link properties
%
% Example:
%
%  >> sampRate = 12.5e6; % (Hz) Simulation sample rate
%  >> linkNum = 1; % Choose one of the links to examine
%  >> % Sample the channel every millisecond for .1 seconds
%  >> time = (0:.001:.1); % (sec)
%  >> hTime = GetChannelResponse(env,linkNum,time,sampRate);
%  >> % Plot the 1st tap of the channel between the 1st Tx and the 1st Rx
%  >> plot(time, squeeze(abs(hTime(1,1,1,:))))

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

startSamps = round(time*sampRate);
[hTime,linkInfo] = GetChannelResponse(env.links(linkNum),startSamps);

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


