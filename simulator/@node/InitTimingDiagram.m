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
figlist = findobj(get(0, 'children'), 'flat', 'type', 'figure');
% FIXME hack to try to solve handle vs figure number issues, read figure handle here instead of elsewhere APW 2015-05-07
fh = figure(timingDiagramFig);
if ismember(figlist, fh)
  % Clear existing figure
  clf(fh);
  ah = axes;
else
  % Open new figure
  clf(fh);
  ah = axes;
  
  % Set figure title and hide figure number
  set(fh, 'NumberTitle', 'off');
  set(fh, 'Name', 'LLamaComm: Timing Diagram');
  
  % Configure figure size/position
  screensize = get(0, 'screensize');
  pixW = screensize(3)-100;
  pixH = max(yposition*20+100, 400);
  pixY = screensize(4)-pixH-100;
  pixX = 50;
  
  set(fh, 'Position', [pixX pixY pixW pixH]);
end

% Make timing diagram un-closable
set(fh, 'CloseRequestFcn', 'TDCloseConfirm');

% Set y-axis params
set(ah, 'YDir', 'reverse');
set(ah, 'YTickMode', 'manual');
set(ah, 'YTickLabelMode', 'manual');
set(ah, 'YLimMode', 'manual');

% Set y-axis label
set(ah, 'YTick', YTick);
set(ah, 'YTickLabel', YTickLabel, 'fontSize', 12);

% Set y-axis
set(ah, 'YLim', [-1 yposition-1]);

% Set x-axis label
xlabel(ah, 'Samples');

% Preserve axes properties
hold(ah, 'on');

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


