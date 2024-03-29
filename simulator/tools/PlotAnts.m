function PlotAnts(txnode,rxnode,thetatxdiff,phitxdiff,thetarxdiff,phirxdiff)
% Make a 4x4 plot showing antenna look directions

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

r2d = 180/pi;  % for converting from radians to degrees

%% TX

% vector from tx to rx
vectx = rxnode.location - txnode.location;
% Convert from xyz to (azimuth CCL from east, elevation above ground plane)
thetatx = atan2(vectx(2),vectx(1));
phitx = atan2(vectx(3),norm([vectx(1),vectx(2)]));

%% RX

%vector from rx to tx
vecrx = txnode.location - rxnode.location;
% Convert from xyz to (azimuth CCL from east, elevation above ground plane)
thetarx = atan2(vecrx(2),vecrx(1));
phirx = atan2(vecrx(3),norm([vecrx(1),vecrx(2)]));


% Make an azimuth plot showing txnode centered
if length(txnode.ant_az) > 1
    warning('plotAnts:firstAntennaOnly', 'Plotting only the first antenna')
end
subplot(221)
% Plot transmitter look direction
arrowPlot(txnode.ant_az(1),1.2,'b-')
hold on
% Plot direction to receiver
arrowPlot(thetatx,1,'r-')
hold off
titlestr = sprintf(['Azimuth: ',txnode.name,'->',rxnode.name,...
    '\nDiff: ',num2str(thetatxdiff*r2d),' deg']);
title(titlestr, 'Interpreter','none')
xlabel(['blue: look angle, red: direction to ',rxnode.name],...
         'Interpreter','none')


% Make an azimuth plot showing rxnode centered
if length(rxnode.ant_az) > 1
    warning('plotAnts:firstAntennaOnly', 'Plotting only the first antenna')
end
subplot(222)
% Plot receiver look direction
arrowPlot(rxnode.ant_az(1),1.2,'b-')
hold on
% Plot direction to transmitter
arrowPlot(thetarx,1,'r-')
hold off
titlestr = sprintf(['Azimuth: ',rxnode.name,'->',txnode.name,...
    '\nDiff: ',num2str(thetarxdiff*r2d),' deg']);
title(titlestr, 'Interpreter','none')
xlabel(['blue: look angle, red: direction to ',txnode.name],...
        'Interpreter','none')


% Make an elevation plot showing txnode centered
if length(txnode.ant_el) > 1
    warning('plotAnts:firstAntennaOnly', 'Plotting only the first antenna')
end
subplot(223)
% Plot transmitter look direction
arrowPlot2(txnode.ant_el(1),1.2,'b-')
hold on
% Plot direction to receiver
arrowPlot2(phitx,1,'r-')
hold off
titlestr = sprintf(['Elevation: ',txnode.name,'->',rxnode.name,...
    '\nDiff: ',num2str(phitxdiff*r2d),' deg']);
title(titlestr,'Interpreter','none')
xlabel(['blue: look angle, red: direction to ',rxnode.name],...
         'Interpreter','none')

% Make an elevation plot showing rxnode centered
if length(rxnode.ant_el) > 1
    warning('plotAnts:firstAntennaOnly', 'Plotting only the first antenna')
end
subplot(224)
% Plot transmitter look direction
arrowPlot2(rxnode.ant_el(1),1.2,'b-')
hold on
% Plot direction to receiver
arrowPlot2(phirx,1,'r-')
hold off
titlestr = sprintf(['Elevation: ',rxnode.name,'->',txnode.name,...
    '\nDiff: ',num2str(phirxdiff*r2d),' deg']);
title(titlestr,'Interpreter','none')
xlabel(['blue: look angle, red: direction to ',rxnode.name],...
         'Interpreter','none')

%------------------------------------------------------------------
function arrowPlot(theta,len,plotParams)
% Use polar.m to make the plot

    if ~exist('plotParams', 'var')
        plotParams = 'b';
    end


    % make head of arrow
    alen = len/8;   % Length of one side of arrowhead
    phi = pi/8;     % Angle from tip of arrow from from the staff
    loc = [len-alen*cos(phi), len, len-alen*cos(phi);...
           alen*sin(phi)    , 0  , -alen*sin(phi)];

    % Rotate by theta degrees
    rotMatrix = [cos(theta), -sin(theta);...
                 sin(theta), cos(theta)];
    locRot = rotMatrix*loc;

    % make staff of arrow
    polar([theta theta],[0 len],plotParams)
    % Plot the arrowhead
    hold on
    plot(locRot(1,:),locRot(2,:),plotParams)
    hold off

%------------------------------------------------------------------
function arrowPlot2(theta,len,plotParams)
% Use polarWedgePlot(in /llamacomm/simulator/tools/) to make the plot

    if ~exist('plotParams', 'var')
        plotParams = 'b';
    end


    % make head of arrow
    alen = len/8;   % Length of one side of arrowhead
    phi = pi/8;     % Angle from tip of arrow from from the staff
    loc = [len-alen*cos(phi), len, len-alen*cos(phi);...
           alen*sin(phi)    , 0  , -alen*sin(phi)];

    % Rotate by theta degrees
    rotMatrix = [cos(theta), -sin(theta);...
                 sin(theta), cos(theta)];
    locRot = rotMatrix*loc;

    % make staff of arrow
    polarWedgePlot([theta theta],[0 len],plotParams);
    % Plot the arrowhead
    hold on
    plot(locRot(1,:),locRot(2,:),plotParams)
    hold off

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


