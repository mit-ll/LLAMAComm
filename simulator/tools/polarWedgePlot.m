function out = polarWedgePlot(theta, rho, plotOpts, plotString)
%
%Usage:
%
%  polarWedgePlot(theta, rho)
%  polarWedgePlot(theta, rho, plotOpts)
%
%Description:
%
%  Similar to MATLAB's "polar" plotting command.
%
%

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

if nargin < 3
  plotOpts = getOpts([]);
elseif nargin ==3
  if ischar(plotOpts)
    plotOpts = getOpts(struct('plotString', plotOpts));
  else
    plotOpts = getOpts(plotOpts);
  end
else
  plotOpts.plotString = plotString;
  plotOpts = getOpts(plotOpts);
end

%
% Constants
%
twoPi = 2*pi;
radToDeg = 360/twoPi;

%
% Adjust polar wedge angles
%
if (plotOpts.thetaMax-plotOpts.thetaMin)>twoPi
  thetaMin = 0;
  thetaMax = twoPi;
else
  thetaMin = plotOpts.thetaMin;
  thetaMax = plotOpts.thetaMax;
end

%
% Check inputs
%
if ~isnumeric(theta) || ~isnumeric(rho)
  error('Input arguments must be numeric.');
end
if ~isequal(size(theta), size(rho))
  error('THETA and RHO must be the same size.');
end

%
% Let matlab deside where the tick marks should be:
%
rhoMax = max(rho(~isinf(rho) & ~isnan(rho)));
if isempty(plotOpts.rhoMin)
  if ~isempty(plotOpts.dynamicRange)
    rhoMin = rhoMax-abs(plotOpts.dynamicRange);
  else
    rhoMin = min(rho(~isinf(rho) & ~isnan(rho)));
    if rhoMin>=0
      rhoMin = 0;
    end
  end
else
  rhoMin = plotOpts.rhoMin;
end

if isempty(get(0, 'Children'))
  held = false;
else
  if isempty(findobj(gcf, 'Type', 'axes'))
    held = false;
  else
    ax = gca;
    held = ishold(ax);
  end
end

if ~held

  % Ape the axis decisons that "plot" makes
  axisMin = rhoMin;
  axisMax = rhoMax;
  p = plot([axisMin, axisMin, axisMax, axisMax], ...
           [axisMin, axisMax, axisMax, axisMin]);

  ax = get(p, 'Parent');
  xLim = get(ax, 'Xlim');
  rMax = xLim(2)-rhoMin;
  rTick = get(ax, 'Xtick');
  rTickLabel = get(ax, 'XtickLabel');
  rTickLabel = rTickLabel(rTick > rhoMin, :);
  rTickDelta = mean(diff(rTick(rTick >= rhoMin)));
  rTick = rTick(rTick > rhoMin)-rhoMin;

  delete(p);
  set(ax, ...
      'dataaspectratio', [1 1 1], ...
      'plotboxaspectratiomode', 'auto', ...
      'Visible', 'off')

  if abs(thetaMax-thetaMin) < twoPi
    phi = (linspace(thetaMin, thetaMax, plotOpts.radialGridNSteps)-plotOpts.orientationAngle)* ...
          plotOpts.angleDir;
    xHat = [0, cos(phi), 0];
    yHat = [0, sin(phi), 0];
  else
    phi = linspace(0, twoPi, plotOpts.radialGridNSteps);
    xHat = cos(phi);
    yHat = sin(phi);
  end
  angleGridLines = plotOpts.angleGridLines(plotOpts.angleGridLines <=  thetaMax);
  angleGridLines = angleGridLines(angleGridLines >= thetaMin);

  if ~isempty(plotOpts.radialLabelsAngle)
    radialLabelsAngle = plotOpts.radialLabelsAngle;
  else
    if numel(angleGridLines)>1
      meanAngleGrid = mean(angleGridLines);
      [~, loc] = min(abs(angleGridLines-meanAngleGrid));
      radialLabelsAngle = angleGridLines(loc(1))+ ...
          abs(0.5*mean(diff(angleGridLines)));
    else
      radialLabelsAngle = ((thetaMin+thetaMax)/2)+(abs(thetaMax-thetaMin)/12);
    end
  end


  %
  % Draw main circle patch
  %
  if isempty(plotOpts.patchColor)
    p = patch(xHat*rMax, yHat*rMax, [1, 1, 1], 'Parent', ax);
  else
    if ischar(plotOpts.patchColor)
      switch(plotOpts.patchColor)
        case 'axis'
          p = patch(xHat*rMax, yHat*rMax, get(ax, 'color'), 'Parent', ax);
        otherwise
          % color string (e.g. 'r'):
          p = patch(xHat*rMax, yHat*rMax, plotOpts.patchColor, 'Parent', ax);
      end
    else
      p = patch(xHat*rMax, yHat*rMax, plotOpts.patchColor, 'Parent', ax);
    end
  end
  set(p, 'Tag', 'background', ...
         'HandleVisibility', plotOpts.handleVisibility);
  hold(ax, 'on');

  %
  % Draw angle grid
  %
  if plotOpts.angleGridNSteps > 1
    % Draw angle grid lines
    for ii = 1:numel(angleGridLines)
      ang = (angleGridLines(ii)-plotOpts.orientationAngle)*plotOpts.angleDir;
      xx = linspace(0, rMax*cos(ang), plotOpts.angleGridNSteps);
      yy = linspace(0, rMax*sin(ang), plotOpts.angleGridNSteps);
      p = plot(ax, xx, yy, plotOpts.angleGridStyle);
      set(p, 'Tag', 'angleGridLine', ...
             'UserData', angleGridLines(ii)*radToDeg, ...
             'HandleVisibility', plotOpts.handleVisibility);

      rText = rMax+(rTickDelta*0.15);
      switch(lower(plotOpts.angleType))
        case 'rad'
          angleStr = num2str(angleGridLines(ii));

        case {'sin', 'sine'}
          angleStr = num2str(sin(angleGridLines(ii)));

        otherwise
          % e.g. "deg":
          if plotOpts.adornAngles
            % Also adds leading space keeps text labels centered:
            angleStr = [' ', num2str(angleGridLines(ii)*radToDeg), '^{o}'];
          else
            angleStr = num2str(angleGridLines(ii)*radToDeg);
          end
      end

      if plotOpts.angleTickLabels
        t = text(rText*cos(ang), rText*sin(ang), angleStr);
        switch(signFix(sin(ang)))
          case 1
            vertAlign = 'bottom';
          case 0
            vertAlign = 'middle';
          case -1
            vertAlign = 'top';
        end
        switch(signFix(cos(ang)))
          case 1
            horizAlign = 'left';
          case 0
            horizAlign = 'center';
          case -1
            horizAlign = 'right';
        end
        set(t, ...
            'Tag', 'angleGridLabel', ...
            'UserData', angleGridLines(ii), ...
            'VerticalAlignment', vertAlign, ...
            'HorizontalAlignment', horizAlign, ...
            'HandleVisibility', plotOpts.handleVisibility);

      end

    end
  end

  %
  % Draw radial grid
  %
  xRadHat = cos((radialLabelsAngle-plotOpts.orientationAngle)*plotOpts.angleDir);
  yRadHat = sin((radialLabelsAngle-plotOpts.orientationAngle)*plotOpts.angleDir);
  switch(sign(xRadHat))
    case 1
      rHAlign = 'left';
    case 0
      rHAlign = 'center';
    case -1
      rHAlign = 'right';
  end

  for ii  = 1:numel(rTick)
    xx = xHat*rTick(ii);
    yy = yHat*rTick(ii);
    p = plot(ax, xx, yy, plotOpts.radialGridStyle);
    set(p, 'HandleVisibility', plotOpts.handleVisibility, ...
           'Tag', 'radialGridLine', ...
           'UserData', rTick(ii)+rhoMin);

    rText = rTick(ii); %+(rTickDelta*0.15);
    labelStr = rTickLabel(ii, :);%#ok

    %
    % Radial Ticks:
    %
    if plotOpts.radialTickLabels
      if isempty(plotOpts.radialTickFormatString)
        t = text(xRadHat*rText, yRadHat*rText, [' ', num2str(rTick(ii)+rhoMin), ' '], ...
                 'HorizontalAlignment', rHAlign, 'VerticalAlignment', 'baseline', ...
                 'Parent', ax);
      else
        t = text(xRadHat*rText, yRadHat*rText, [' ', num2str(rTick(ii)+rhoMin, plotOpts.radialTickFormatString), ' '], ...
                 'HorizontalAlignment', rHAlign, 'VerticalAlignment', 'baseline', ...
                 'Parent', ax);
      end
      set(t, 'Tag', 'radialGridLabel', ...
             'UserData', rTick(ii)+rhoMin, ...
             'HandleVisibility', plotOpts.handleVisibility);
    end
  end

  %
  % Enforce wedge limits
  %
  rho(rho <=  rhoMin) = rhoMin;
  theta(...
      mod((theta-thetaMin)+(twoPi*ceil((thetaMin-min(theta))/twoPi)), twoPi)>= ...
      thetaMax-thetaMin) = NaN;

end


%
%
%
theta = (theta-plotOpts.orientationAngle)*plotOpts.angleDir;
rho2 = rho-rhoMin;
plt = plot(ax, rho2.*cos(theta), rho2.*sin(theta), plotOpts.plotString);

if ~held
  hold(ax, 'off');
end
if nargout > 0
  out = plt;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotOpts = getOpts(plotOpts)
%
% Constants
%
halfPi = pi/2;

if ~isstruct(plotOpts)
  if ischar(plotOpts)
    plotOpts = struct('plotString', plotOpts);
  else
    plotOpts = [];
  end
end
%defaults = struct(...
%    'adornAngles', 'true', ...
%    'angleDir', -1, ...
%    'angleGridLines', [], ...
%    'angleGridStyle', 'k:', ...
%    'angleGridNSteps', 20, ...
%    'angleTickLabels', true, ...
%    'angleType', 'deg', ...
%    'dynamicRange', [], ...
%    'handleVisibility', 'off', ...
%    'orientationAngle', halfPi, ...
%    'patchColor', [1,1,1], ...
%    'plotString', 'b', ...
%    'radialGridStyle', 'k:', ...
%    'radialGridNSteps', 20, ...
%    'radialTickFormatString', '', ...
%    'radialTickLabels', true, ...
%    'radialLabelsAngle', [], ...
%    'rhoMin', [], ...
%    'thetaMax', [], ...
%    'thetaMin', [], ...
%    'warnUnknownOption', true);
defaults = struct(...
    'adornAngles', 'false', ...
    'angleDir', 1, ...
    'angleGridLines', [], ...
    'angleGridStyle', 'k', ...
    'angleGridNSteps', 20, ...
    'angleTickLabels', true, ...
    'angleType', 'deg', ...
    'dynamicRange', [], ...
    'handleVisibility', 'off', ...
    'orientationAngle', 0, ...
    'patchColor', [1,1,1], ...
    'plotString', 'b', ...
    'radialGridStyle', 'k', ...
    'radialGridNSteps', 20, ...
    'radialTickFormatString', '', ...
    'radialTickLabels', false, ...
    'radialLabelsAngle', [], ...
    'rhoMin', 0, ...
    'thetaMax', [], ...
    'thetaMin', [], ...
    'warnUnknownOption', true);

% Preprocessing so some defaults are "smart"
if ~isfield(plotOpts, 'thetaMax')
  if ...
        isfield(plotOpts, 'thetaMin') && ...
        ~isempty(plotOpts.thetaMin) && ...
        (plotOpts.thetaMin < 0)
    % Symmetrize automatically
    defaults.thetaMax  =  -plotOpts.thetaMin;
  end
end
 if ~isfield(plotOpts, 'thetaMin')
   if ...
         isfield(plotOpts, 'thetaMax') && ...
         ~isempty(plotOpts.thetaMax) && ...
         (plotOpts.thetaMax > 0)
     % Symmetrize automatically
     defaults.thetaMin  =  -plotOpts.thetaMin;
   end
 end
if ~isfield(plotOpts,'warnUnknownOption') || plotOpts.warnUnknownOption
  % Check for mystery fields
  if isstruct(plotOpts)
    fldnames = fieldnames(plotOpts);
  else
    fldnames = {};
  end
  for fldIndx = 1:numel(fldnames)
    if ~isfield(defaults, fldnames{fldIndx})
      warning('Unknown option: %s', fldnames{fldIndx});
    end
  end
end

% Ensure fields exist and apply defaults
fldnames = fieldnames(defaults);
for fldIndx = 1:numel(fldnames)
  if ~isfield(plotOpts, fldnames{fldIndx}) || isempty(plotOpts.(fldnames{fldIndx}))
    plotOpts.(fldnames{fldIndx}) = defaults.(fldnames{fldIndx});
  end
end

% Postprocessing so some defaults are "smart"
if isempty(plotOpts.angleGridLines)
  switch(lower(plotOpts.angleType))
    case {'sin', 'sine'}
      plotOpts.angleGridLines = asin(-1:0.2:1);
    case {'rad', 'radians'}
      plotOpts.angleGridLines = (-4:0.5:4);
    otherwise
      degToRad = pi/180;
      plotOpts.angleGridLines = (-330:30:330)*degToRad;
  end
end
if isempty(plotOpts.thetaMin)
  plotOpts.thetaMin = -halfPi;
end
if isempty(plotOpts.thetaMax)
  plotOpts.thetaMax = halfPi;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = signFix(x)
%
% "Fixes" naive sign(cos(x)), sign(sin(x)) calculations in determining
% sectors.
%
thresh = eps;
if abs(x) < thresh
  y = 0;
else
  y = sign(x);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

