function InitTimingDiagram(nodes)

% Function @module/InitTimingDiagram.m:
% Initializes timing diagram by creating figure and axis labels.
%
% USAGE: InitTimingDiagram(nodes)
%
% Input argument:
%  nodes    (node obj array) Array of all nodes in the simulation
%
% Output arguments:
%  -none-
%
% See also: @module/UpdateTimingDiagram.m

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


global timingDiagramFig;

% Gather some info
maxM = 0;
totLabels = 0;
for n = 1:length(nodes)
  modLen = length(nodes(n).modules);
  totLabels = totLabels + modLen;
  maxM = max(maxM, modLen);
end

% Set up spacing for y-axis
yposition = 0;
YTick = zeros(1, totLabels);
YTickLabel = cell(totLabels, 1);
yaxisdb = cell(length(nodes), maxM);
indx = 0;
for n = 1:length(nodes)
  for m = 1:length(nodes(n).modules)
    % Get labels
    nodename = nodes(n).name;
    modname = GetModuleName(nodes(n).modules(m));

    % Set tick labels
    indx = indx + 1;
    YTick(indx) = yposition;
    if m==1
      label = sprintf('%s:%s', nodename, modname);
    else
      label = modname;
    end
    YTickLabel{indx} = label;

    % Store into a mini-database for later
    temp.ypos = yposition;
    temp.nodename = nodename;
    temp.modname = modname;
    yaxisdb{n, m} = temp;

    yposition = yposition + 1;
  end

  % Make gap between nodes
  yposition = yposition + 1;
end

% Check if figure already exists, if it does, don't move or resize
figList = get(0, 'Children');
if isempty(figList)
  figList = [];
elseif ~isnumeric(figList)
  if all(isprop(figList, 'Number'))
    figList = [figList.Number];
  else
    error('figure list is of unexpected type: %s', class(figList));
  end
end

if ismember(figList, timingDiagramFig)
  % Clear existing figure
  clf(timingDiagramFig);
  ah = axes('Parent', timingDiagramFig);
else

  % Configure figure size/position
  screensize = get(0, 'screensize');
  pixW = screensize(3)-100;
  pixH = max(yposition*20+100, 400);
  pixY = screensize(4)-pixH-100;
  pixX = 50;

  % Open new figure
  figure(timingDiagramFig);
  ah = axes('Parent', timingDiagramFig);

  % Set figure title and hide figure number
  set(timingDiagramFig, ...
      'NumberTitle', 'off', ...
      'Name', 'LLamaComm: Timing Diagram', ...
      'Position', [pixX pixY pixW pixH]);
end

% Make timing diagram un-closable
set(timingDiagramFig, 'CloseRequestFcn', 'TDCloseConfirm');

% Set y-axis params
set(ah, ...
    'YDir', 'reverse', ...
    'YTickMode', 'manual', ...
    'YTickLabelMode', 'manual', ...
    'YLimMode', 'manual', ...
    'YTick', YTick, ...
    'YTickLabel', YTickLabel, ...
    'FontSize', 12, ...
    'YLim', [-1 yposition-1], ...
    'NextPlot', 'add');
if ~isnumeric(ah)
  % Newer matlab graphics engine will mangle labels
  set(ah, 'TickLabelInterpreter', 'none');
end

% Set x-axis label
xlabel(ah, 'Samples');

% Set colormap
cmap = colormap('jet');

% Store mini-database in figure
user.ah = ah;
user.yaxisdb = yaxisdb;
user.cmap = cmap;
user.execorder = 0;  % Initialize execution order counter
set(timingDiagramFig, 'UserData', user);

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


