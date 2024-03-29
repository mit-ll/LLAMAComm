function delaySpread = GetDelaySpread(nodTx, ...
                                      modTx, ...
                                      nodRx, ...
                                      modRx, ...
                                      env, ...
                                      pathLoss); %#ok - unused args

% Function '@node/GetDelaySpread.m':
% Computes the delay spread given the node and environment parameters.
%
% USAGE:  delaySpread = GetdelaySpread(nodeTx, modTx, nodeRx, modRx, env)
%
% Input arguments:
%  nodTx            (node obj) Node transmitting
%  modTx            (module obj) Module transmitting
%  nodRx            (node obj) Node receiving
%  modRx            (module obj) Module receiving
%  env              (environment obj) Environment object
%  pathLoss         (struct) Output of @node/GetPathlossStruct.m
%
% Output argument:
%  delaySpread      (double) (s) Delay spread in the link
%
% This function uses the model proposed in [1].
%
% [1] L.J. Greenstein, V. Erceg, Y.S. Yeh, and M.V. Clark, "A New
%     Path-Gain/Delay-Spread Propagation Model for Digital Cellular
%     Channels, " IEEE Trans. Vehicular Technology, Vol. 46, No. 2,
%     May 1997.

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

envParams = struct(env);
nodTx     = struct(nodTx);
nodRx     = struct(nodRx);
%modTx     = struct(modTx);
%modRx     = struct(modRx);


% Cases:

% URBAN
    % Both indoors
        % Line of sight

        % non line of sight

    % One indoors
        % hhn below average roof height

        % hhn in transition region

        % hhn above transition region and below model limit

        % hhn above average roof height and above model limit

    % Both outdoors
        % hhn below average roof height
            % Line of sight

            % non line of sight

        % hhn in transition region
            % Line of sight

            % non line of sight

        % hhn above transition region and below model limit
            % Line of sight

            % non line of sight

        % hhn above average roof height and above model limit
            % Line of sight

            % non line of sight

        % hhn in transition region
            % Line of sight

            % non line of sight

        % hhn above transition region and below model limit
            % Line of sight

            % non line of sight
% SUBURBAN


% RURAL


% BELOW IS THE OUTDOOR GROUND-TO-GROUND PROPAGATION MODEL GIVEN IN [1]

% Get the standard deviation of the log-normal shadowloss
stdx_dB = pathLoss.shadowStd;

% Get the standard deviation of the log-normal delay spread
stdy_dB = 4;  % (dB) recommended from 2 to 6

% Generate the correlation matrix between the shadowloss and the delay
% spread. Note that as the pathloss increases, the delay spread increases.
D = diag([stdy_dB stdx_dB]);
R = D*[1 0.75; 0.75, 1.0]*D;

% Get the link shadowloss (dB)
x_dB = pathLoss.shadowCorrLoss;

% Generate the log-normal part of the delay spread by appropriately
% augmenting the Gaussian vector
if stdx_dB == 0
    z_dB = randn*stdy_dB;
else
    z_dB = augmentRandNVec(x_dB, R);
end
y_dB = z_dB(1);
y = 10^(y_dB/10);

% find the distance between the nodes (km)
d = norm(nodTx.location - nodRx.location)/1000;

% Get the median rms delay spread at 1 km link separation
switch envParams.envType
  case 'rural'
    T1 = 0.1e-6;  % (s)
  case 'suburban'
    T1 = 0.3e-6;  % (s)
  case 'urban'
    if d < 1000  % urban microcell
      T1 = 0.4e-6;
    else
      T1 = 1.0e-6;
    end
  case 'airborne'
    T1 = 0; %@ToDo: This is a placeholder
  otherwise
    error('Unrecognized environment type: %s', envParams.envType);
end

% Get the distance exponent (suggested as 0.5 in [1])
epsilon = 0.5;

% Calculate the delay spread (see equation (10) in [1])
delaySpread = T1*d^epsilon*y;

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


