function [gtx, grx, thetatx, phitx, thetarx, phirx] = getantgain(txnode, rxnode)
% function [ gtx grx ] = getantgain(txnode, rxnode);
% Given two nodes, 1 Tx and 1 Rx, return antenna
% gains at Tx and Rx for comm. link between nodes

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

% % Check input parameters
% if ~(strcmp(txnode.type, 'user') || strcmp(txnode.type, 'interf'))
%     error('txnode has no transmitter');
% end
% if ~(strcmp(rxnode.type, 'user') || strcmp(rxnode.type, 'hidden'))
%     error('rxnode has no receiver');
% end

fcmhz = rxnode.fc/1e6;

if isempty(txnode.antType)
  warning(['llamacom:pathloss:',mfilename, ':NoTxAntFunctionSpecified'], ...
          'Tx antenna function not specified, omnidirectional assumed, function getantgain');
end
if isempty(rxnode.antType)
  warning(['llamacom:pathloss:',mfilename, ':NoRxAntFunctionSpecified'], ...
          'Rx antenna function not specified, omnidirectional assumed, function getantgain');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find angle relative to the look angle for tx and rx


%% TX


% vector from tx to rx nodes
vectx = rxnode.location - txnode.location;
[az,el,~] = cart2sph(vectx(1),vectx(2),vectx(3));
[thetatx,phitx] = compute_differentialAngle(az,el,txnode.ant_az,txnode.ant_el);

% % Convert from xyz to (azimuth CCL from east, elevation above ground plane)
% thetatx = atan2(vectx(2), vectx(1)) - txnode.ant_az;
% phitx = atan2(vectx(3), norm([vectx(1), vectx(2)])) - txnode.ant_el;
% % wrap the elevation to between [-pi/2, pi/2]
% if phitx < -pi/2
%   phitx = -pi/2 + abs(phitx + pi/2);
% elseif phitx > pi/2
%   phitx = pi/2 - abs(phitx - pi/2);
% end
% % wrap the azimuth to between (-pi, pi]
% thetatx = mod(thetatx + pi, 2*pi) - pi;
% % wrap -pi to pi
% if thetatx == -pi
%   thetatx = pi;
% end

%% RX

vecrx = txnode.location - rxnode.location;
[az,el,~] = cart2sph(vecrx(1),vecrx(2),vecrx(3));
[thetarx,phirx] = compute_differentialAngle(az,el,rxnode.ant_az,rxnode.ant_el);

% %vector from rx to tx nodes
% vecrx = txnode.location - rxnode.location;
% % Convert from xyz to (azimuth CCL from east, elevation above ground plane)
% thetarx = atan2(vecrx(2), vecrx(1)) - rxnode.ant_az;
% phirx = atan2(vecrx(3), norm([vecrx(1), vecrx(2)])) - rxnode.ant_el;
% % wrap the elevation to between [-pi/2, pi/2]
% if phirx < -pi/2
%   phirx = -pi/2 + abs(phirx + pi/2);
% elseif phirx > pi/2
%   phirx = pi/2 - abs(phirx - pi/2);
% end
% % wrap the azimuth to between (-pi, pi]
% thetarx = mod(thetarx + pi, 2*pi) - pi;
% % wrap -pi to pi
% if thetarx == -pi
%   thetarx = pi;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ok, finally, get antenna gain

r2d = 180/pi; % convert radians to degrees

if isempty(txnode.antType{1})
  antfunc = 'omni';
else
  antfunc = txnode.antType{1}; % name of antenna response function
end

gtx = eval([antfunc '(' num2str(r2d*thetatx) ', ' ...
           num2str(r2d*phitx) ', ' ...
           num2str(fcmhz) ')' ]);
if isempty(rxnode.antType{1})
  antfunc = 'omni';
else
  antfunc = rxnode.antType{1}; % name of antenna response function
end

grx = eval([antfunc '(' num2str(r2d*thetarx) ', ' ...
            num2str(r2d*phirx) ', ' ...
            num2str(fcmhz) ')' ]);



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


