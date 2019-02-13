function DesignAntiAliasFilter()

% Function DesignAntiAliasFilter.m:
% Designs and saves the antialias filter.  This function does not
% need to be run as part of LLAMAComm.  The filter taps are already
% part of the LLAMAComm distribution.
%
% USAGE: DesignAntiAliasFilter()
%
% Input args:
%  -none-
%
% Output arguments:
%  -none-   The filter taps are saved as 'antiAliasFilterTaps.mat'
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

antialiasMethod = 'pm'; % Anti-alias method: 'pm', 'kaiser', or 'none'
fs = 2;             % Sampling rate
fn = fs/2;          % Nyquist frequency
                    % Design an anti-alias filter
switch antialiasMethod
  case 'pm'
    % Parks-McClellan method
    C = firpmord([-1/40, 1/40]*fn+fn*19/20, [1 0], [.01, .005], fs, 'cell');
    B = firpm(C{:}); %#ok - B saved below
  case 'kaiser'
    % Kaiser method
    C = kaiserord([-1/40, 1/40]*fn+fn*19/20, [1 0], [.01 .005], fs, 'cell');
    B = fir1(C{:}); %#ok - B saved below
  case 'none'
    B = [1 0 0]; %#ok - B saved below
end

save antiAliasFilterTaps -v6


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


