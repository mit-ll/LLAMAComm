function MakeNodeMap(nodes, mapFig)

% Function @node/MakeNodeMap.m:
% Plots a map of the nodes positions in 3-D
%
% USAGE: MakeNodeMap(nodes, mapFig)
%
% Input argument:
%  nodes    (1xN node obj) Array of node objects
%  mapFig   (int, or figure handle) Figure number for plotting map.
%
% Output argument:
%  -none-
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

activateCallback = 1;       % flag to make the node names active

axesFont = 10;              % Font size for axes fonts
nodeLabelFont = 8;          % Font size for node labels
zStretchFactor = .2;        % Decrease to stretch Z-axis

% Stack up locations
loc = zeros(length(nodes), 3);
for nodeLoop = 1:length(nodes)
  curNode = nodes(nodeLoop);
  loc(nodeLoop, :) = curNode.location;
end

% Calculate axis lines
dist = sqrt(sum(loc(:, 1:2).^2, 2));
maxdist = max(dist)*1.05;

% Open figure 
if ~exist('mapFig', 'var')
  hFig = figure; 
else
  if ishandle(mapFig)
    figAlreadyOpen = 1;
    clf(mapFig);
  else
    figAlreadyOpen = 0;
  end
  hFig = figure(mapFig); 
end

%
ax = axes('Parent', hFig);
line([-maxdist, maxdist], [0, 0], ...
     'Color', [0 0 0], ...
     'LineWidth', 1, ...
     'Parent', ax);
hold(ax, 'on');
line([0, 0], [-maxdist, maxdist], ...
     'Color', [0 0 0], ...
     'LineWidth', 1, ...
     'Parent', ax);

% % Insert a ground plane
% patch([-1 1 1 -1]*maxdist, [1 1 -1 -1]*maxdist, [0 0 0 0], ...
%    'FaceColor', [0 .5 0], 'FaceAlpha', .5);

% Make a plot of node locations
h = stem3(loc(:, 1).', loc(:, 2).', loc(:, 3).', ...
          'Marker', 'o', 'MarkerSize', 5, ...
          'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', [1 1 1], ...
          'LineWidth', 2, ...
          'Color', [1 1 1], ...
          'Clipping', 'off', ...
          'Parent', ax); %#ok - h unused

% Place labels on plot
for nodeLoop = 1:length(nodes)
  h = text(loc(nodeLoop, 1), ...
           loc(nodeLoop, 2), ...
           loc(nodeLoop, 3)+15*zStretchFactor, ...
           nodes(nodeLoop).name, 'Interpreter', 'none', ...
           'FontSize', nodeLabelFont, 'FontWeight', 'demi', ...
           'Color', [0 0 0], ...
           'Parent', ax);
  
  % Set callback for when the user clicks the text
  if activateCallback
    % call the default callback
    NMCallback = @DefaultNMCallback;

    % Embed callback and node into the text
    set(h, 'ButtonDownFcn', ...
           {NMCallback, nodes(nodeLoop)});
  end
  
  
end

% Format plot
set(hFig, 'Name', 'Node Locations');
set(ax, 'PlotBoxAspectRatio', [1 1 zStretchFactor]);
set(ax, 'DataAspectRatio', [1 1 zStretchFactor]);
box(ax, 'off');
grid(ax, 'off');

if figAlreadyOpen
  % do nothing
else
  % change the figure size
  screensize = get(0, 'screensize');
  pixW = min(screensize(3), 800);
  pixH = min(.75*pixW, 600);
  pixY = screensize(4)-pixH-75;
  pixX = 25;
  set(hFig, 'Position', [pixX pixY pixW pixH]);
end

xlabel(ax, 'X Coordinates (m)', 'FontSize', axesFont);
ylabel(ax, 'Y Coordinates (m)', 'FontSize', axesFont);
%zlabel(ax, 'Z (m)', 'FontSize', axesFont);

set(ax, 'ZTick', []);

xlim(ax, [-maxdist maxdist]);
ylim(ax, [-maxdist maxdist]);
zlim(ax, [-1 0]);

% Change axes to green to look like grass
set(ax, 'Color', [0.3 0.6 0.3]);

% Set default view position
azAngle = 25;
elAngle = 40;
view(ax, azAngle, elAngle);


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
