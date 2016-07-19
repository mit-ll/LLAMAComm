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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
switch(lower(class(figList)))  
  case 'matlab.ui.figure'
    % In newer Matlabs, figList returned above is an array of figure handles
    figList = [figList.Number];
  
  case 'matlab.graphicsplaceholder'
    % Being a different class when empty is kind of stupid
    figList = [];
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


