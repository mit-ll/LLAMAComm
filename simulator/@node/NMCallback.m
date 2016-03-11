function NMCallback(n)

% Function @node/NMCallback.m:
% This function will plot the antenna locations of the modules.
%
% USAGE: called by llamacomm/simulator/nm/DefaultNMCallback.m
%
% Input arguments:
%  n   (node object)
%
% Output arguments:
%  -none-
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print the static node information to the command line
fprintf(1, '\n');
fprintf(1, '      node name: %s\n', n.name);
fprintf(1, '       location: %s\n', mat2str(n.location));
fprintf(1, '       velocity: %s\n', mat2str(n.velocity));
if isempty(n.controllerFcn)
  fprintf(1, '  controllerFcn: []\n');
else
  finfo = functions(n.controllerFcn);
  fprintf(1, '  controllerFcn: @%s\n', finfo.function);
end
%fprintf(1, '          state: ''%s''\n', n.state);
fprintf(1, '        modules:');
for r = 1:size(n.modules, 1)
  if r > 1
    fprintf(1, '\n                  ');
  end
  for c = 1:size(n.modules, 2)
    fprintf(1, ' ''%s''', GetModuleName(n.modules(r, c)));
  end
end
fprintf(1, '\n\n');
%fprintf(1, ' User Parameters:\n');
%disp(n.user);
%fprintf(1, '\n\n');

% Get indices of non-genie modules
numMods = length(n.modules);
nonGenieMods = false(1, numMods);
for modLoop = 1:numMods
  nonGenieMods(modLoop) = ~IsGenie(n.modules(modLoop));
end
nonGenieMods = find(nonGenieMods);
numNonGenieMods = length(nonGenieMods);

% Plot the antenna parameters
fig = figure;
for modLoop = 1:numNonGenieMods
  
  curMod = n.modules(nonGenieMods(modLoop));
  
  % Create the subplot index
  if numNonGenieMods <= 2
    ax = subplot(1, numNonGenieMods, modLoop, ...
                 'Parent', fig);
  elseif numNonGenieMods <= 4
    ax = subplot(2, 2, modLoop, ...
                 'Parent', fig);
  else % Make 3 columns with as many rows as needed
    ax = subplot(ceil(numNonGenieMods/3), 3, modLoop, ...
                 'Parent', fig);
  end
  
  name = [n.name, ':', GetModuleName(curMod)];
  ant = GetAntennaParams(curMod);
  plotAnts(n.location, ant.antPosition, name, ant, ax);
  drawnow
end


%-----------------------------------------------------------------------
function plotAnts(nodloc, loc, name, ant, ax)

fig = get(ax, 'Parent');

ant_az = ant.antAzimuth;
ant_el = ant.antElevation;

% If necessary, replicate the azimuth and elevation look angles
if size(ant_az, 1) == 1 && size(loc, 1) > 1
  % repeat the antenna elevation
  ant_az = repmat(ant_az, 1, size(loc, 1));
end
if size(ant_el, 1) == 1 && size(loc, 1) > 1
  % repeat the antenna elevation
  ant_el = repmat(ant_el, 1, size(loc, 1));
end

% make a 3-D plot with the x-y coordinates of the node as the origin

%activateCallback = 1;       % flag to make the node names active

axesFont = 10;              % Font size for axes fonts
antLabelFont = 12;          % Font size for node labels
zStretchFactor = .5;        % Decrease to stretch Z-axis

% Calculate axis lines
if size(loc, 1) == 1
  % Only one antenna
  maxdist = max(norm(loc(1:2)), max(nodloc(3), 1));
else
  % more than one antenna
  dist = max(max(sqrt(sum(loc(:, 1:2).^2, 2))), nodloc(3));
  maxdist = max(dist)*1.05;
end


% Plot node location
stem3(0, 0, nodloc(3), 'Marker', 'o', 'MarkerSize', 5, ...
      'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 0 1], ...
      'LineWidth', 2, ...
      'Color', [1 0 1], ...
      'Parent', ax);
hold(ax, 'on');

% Make a plot of antenna locations
h = plot3(loc(:, 1).', loc(:, 2).', loc(:, 3).' + nodloc(3), 'kv', ...
          'MarkerSize', 10, ...
          'Parent', ax); %#ok - h unused

% Insert a ground plane
patch([-1 1 1 -1]*maxdist, [1 1 -1 -1]*maxdist, [0 0 0 0], ...
      'FaceColor', [.3 .6 .3], ...
      'FaceAlpha', 1, ...
      'Parent', ax);
line([-maxdist, maxdist], [0, 0], ...
     'Color', [0 0 0], ...
     'LineWidth', 1, ...
     'Parent', ax);
line([0, 0], [-maxdist, maxdist], ...
     'Color', [0 0 0], ...
     'LineWidth', 1, ...
     'Parent', ax);


% Place labels and look-angle arrows on plot
for antLoop = 1:size(loc, 1)
  h= text(loc(antLoop, 1), ...
          loc(antLoop, 2)+1, ...
          loc(antLoop, 3)+nodloc(3), ...
          num2str(antLoop), 'Interpreter', 'none', ...
          'FontSize', antLabelFont, 'FontWeight', 'demi', ...
          'Color', [0 0 0], ...
          'Parent', ax); %#ok - h unused
  
  % Find unit-vector look direction in xyz coords
  lookDir = [cos(ant_el(antLoop))*cos(ant_az(antLoop)), ...
             cos(ant_el(antLoop))*sin(ant_az(antLoop)), ...
             sin(ant_el(antLoop))];
  % Scale the look direction vector
  A = max(nodloc(3), 1);
  lookDirA = A*lookDir;
  hq = quiver3(loc(antLoop, 1), loc(antLoop, 2), loc(antLoop, 3)+nodloc(3), ...
               lookDirA(1), lookDirA(2), lookDirA(3), 'Color', [0 0 1], ...
               'MarkerSize', 20, ...
               'Parent', ax); %#ok - hq unused
  
  
end

% Format plot
%set(gcf, 'Name', ['Antenna Locations: ', name]);
title(ax, ['Antenna Locations: ', name], 'Interpreter', 'none')
set(ax, 'PlotBoxAspectRatio', [1 1 zStretchFactor]);
set(ax, 'DataAspectRatio', [1 1 zStretchFactor]);
box(ax, 'off');
grid(ax, 'off');

screensize = get(0, 'screensize');
pixW = min(screensize(3), 800);
pixH = min(.75*pixW, 600);
pixY = screensize(4)-pixH-125;
pixX = 300;
set(fig, 'Position', [pixX pixY pixW pixH]);

xlabel(ax, 'X Coordinates (m)', 'FontSize', axesFont);
ylabel(ax, 'Y Coordinates (m)', 'FontSize', axesFont);
zlabel(ax, 'Z (m)', 'FontSize', axesFont);

%set(ax, 'ZTick', []);

xlim(ax, [-maxdist maxdist]);
ylim(ax, [-maxdist maxdist]);
zlim(ax, [min(nodloc(3), -1), max(nodloc(3), 1)]);
%zlim(ax, [-10 0]);

% Set default view position
azAngle = 25;
elAngle = 40;
view(ax, azAngle, elAngle);


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


