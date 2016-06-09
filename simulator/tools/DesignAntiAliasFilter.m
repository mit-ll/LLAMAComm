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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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


