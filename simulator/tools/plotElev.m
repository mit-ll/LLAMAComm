function hpol = plotElev(varargin)
%POLAR  Polar coordinate plot.
%   POLAR(THETA, RHO) makes a plot using polar coordinates of
%   the angle THETA, in radians, versus the radius RHO.
%   POLAR(THETA, RHO, S) uses the linestyle specified in string S.
%   See PLOT for a description of legal linestyles.
%
%   POLAR(AX, ...) plots into AX instead of GCA.
%
%   H = POLAR(...) returns a handle to the plotted object in H.
%
%   Example:
%      t = 0:.01:2*pi;
%      polar(t, sin(2*t).*cos(2*t), '--r')
%
%   See also PLOT, LOGLOG, SEMILOGX, SEMILOGY.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 749 $  $Date: 2012-07-27 19:19:13 -0400 (Fri, 27 Jul 2012) $

% Parse possible Axes input
[cax, args, nargs] = axescheck(varargin{:});
if exist('narginchk', 'builtin')
  narginchk(1, 3);
else
  error(nargchk(1, 3, nargs)); %#ok - for old MATLAB versions
end

if nargs < 1 || nargs > 3
  error('Requires 2 or 3 data arguments.')
elseif nargs == 2 
  theta = args{1};
  rho = args{2};
  if ischar(rho)
    line_style = rho;
    rho = theta;
    [mr, nr] = size(rho);
    if mr == 1
      theta = 1:nr;
    else
      th = (1:mr)';
      theta = th(:, ones(1, nr));
    end
  else
    line_style = 'auto';
  end
elseif nargs == 1
  theta = args{1};
  line_style = 'auto';
  rho = theta;
  [mr, nr] = size(rho);
  if mr == 1
    theta = 1:nr;
  else
    th = (1:mr)';
    theta = th(:, ones(1, nr));
  end
else % nargs == 3
  [theta, rho, line_style] = deal(args{1:3});
end
if ischar(theta) || ischar(rho)
  error('Input arguments must be numeric.');
end
if ~isequal(size(theta), size(rho))
  error('THETA and RHO must be the same size.');
end

% get hold state
cax = newplot(cax);

next = lower(get(cax, 'NextPlot'));
hold_state = ishold(cax);

% get x-axis text color so grid is in same color
tc = get(cax, 'xcolor');
ls = get(cax, 'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
         'DefaultTextFontName',   get(cax, 'FontName'), ...
         'DefaultTextFontSize',   get(cax, 'FontSize'), ...
         'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
         'DefaultTextUnits', 'data')

% only do grids if hold is off
if ~hold_state

  % make a radial grid
  hold(cax, 'on');
  maxrho = max(abs(rho(:)));
  hhh=line([-maxrho -maxrho maxrho maxrho], [-maxrho maxrho maxrho -maxrho], 'parent', cax);
  set(cax, 'dataaspectratio', [1 1 1], 'plotboxaspectratiomode', 'auto')
  v = [get(cax, 'xlim') get(cax, 'ylim')];
  ticks = sum(get(cax, 'ytick')>=0);
  delete(hhh);
  % check radial limits and ticks
  rmin = 0; rmax = v(4); rticks = max(ticks-1, 2);
  if rticks > 5   % see if we can reduce the number
    if rem(rticks, 2) == 0
      rticks = rticks/2;
    elseif rem(rticks, 3) == 0
      rticks = rticks/3;
    end
  end

  % define a circle
  th = 0:pi/50:2*pi;
  xunit = cos(th);
  yunit = sin(th);
  % now really force points on x/y axes to lie on them exactly
  inds = 1:(length(th)-1)/4:length(th);
  xunit(inds(2:2:4)) = zeros(2, 1);
  yunit(inds(1:2:5)) = zeros(3, 1);
  % plot background if necessary
  if ~ischar(get(cax, 'color')), 
    patch('xdata', xunit*rmax, 'ydata', yunit*rmax, ...
          'edgecolor', tc, 'facecolor', get(cax, 'color'), ...
          'handlevisibility', 'off', 'parent', cax);
  end

  % draw radial circles
  % c82 = cos(82*pi/180);
  % s82 = sin(82*pi/180);
  rinc = (rmax-rmin)/rticks;
  for i=(rmin+rinc):rinc:rmax
    hhh = line(xunit*i, yunit*i, 'linestyle', ls, 'color', tc, 'linewidth', 1, ...
               'handlevisibility', 'off', 'parent', cax);
  end
  set(hhh, 'linestyle', '-') % Make outer circle solid

  % plot spokes
  th = pi/2 - (0:6)*2*pi/12;
  cst = cos(th); snt = sin(th);
  cs = [zeros(size(th)); cst];
  sn = [zeros(size(th)); snt];
  line(rmax*cs, rmax*sn, 'linestyle', ls, 'color', tc, 'linewidth', 1, ...
       'handlevisibility', 'off', 'parent', cax)

  % annotate spokes in degrees
  rt = 1.1*rmax;
  for i = 0:length(th)-1
    text(rt*cst(i+1), rt*snt(i+1), int2str(90-i*30), ...
         'horizontalalignment', 'center', ...
         'handlevisibility', 'off', 'parent', cax);
  end

  % set view to 2-D
  view(cax, 2);
  % set axis limits
  axis(cax, rmax*[0 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
         'DefaultTextFontName',   fName , ...
         'DefaultTextFontSize',   fSize, ...
         'DefaultTextFontWeight', fWeight, ...
         'DefaultTextUnits', fUnits );

% transform data to Cartesian coordinates.
xx = rho.*cos(theta);
yy = rho.*sin(theta);

% plot data on top of grid
if strcmp(line_style, 'auto')
  q = plot(xx, yy, 'parent', cax);
else
  q = plot(xx, yy, line_style, 'parent', cax);
end

if nargout == 1
  hpol = q;
end

if ~hold_state
  set(cax, 'dataaspectratio', [1 1 1]), axis(cax, 'off'); set(cax, 'NextPlot', next);
end
set(get(cax, 'xlabel'), 'visible', 'on')
set(get(cax, 'ylabel'), 'visible', 'on')




% Copyright (c) 2006-2012, Massachusetts Institute of Technology All rights
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


