function UpdateTimingDiagram(modobj, nodeobj, nodeidx, modidx, forceRefresh)

% Function @module/UpdateTimingDiagram.m:
% Updates timing diagram by drawing additional blocks onto the figure
% after it has been calculated.  Should be called from RunArbitrator.m
% AFTER RequestDone has been run.  (This function adds the last
% entry in the history to the plot.)  The figure number is defined
% in InitGlobals.m
%
% USAGE: UpdateTimingDiagram(modobj, nodeidx, modidx)
%
% Input arguments:
%  modobj    (module obj) Module object
%  nodeobj   (node obj) Parent Node object
%  nodeidx   (int) Node index (used to find index into y-axis database)
%  modidx    (int) Module index (used to find index into y-axis database)
%
% Output arguments:
%  -none-
%
% See also @node/InitTimingDiagram.m

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


global timingDiagramFig;
global timingDiagramForceRefresh;
global timingDiagramShowExecOrder;


% Argument handling
if nargin==1
  % Special syntax - flush graphics buffer
  if timingDiagramForceRefresh
    drawnow;
  end
  return;
end
if nargin < 4
  forceRefresh = timingDiagramForceRefresh;
end

% Some parameters controlling how figure looks
activateCallback = true;
drawTickEnable = true;
rectThickness = .3;
tickThickness = .4;
if ~true % Original frequency range
  minFreq = 50e6;
  maxFreq = 2500e6;
else % Link 16 frequency range
  minFreq = 969e6;
  maxFreq = 1206e6;
end
lineWidth = 1;
lineColor = [0 0 0];
execOrderYOffset = .05; 
execOrderFontSize = 8; 
if isempty(timingDiagramShowExecOrder)
  showExecOrder = true;
else
  showExecOrder = timingDiagramShowExecOrder;
end


% Make timing diagram figure active
% Force plot update if requested
if forceRefresh
  fh = touchFigure(timingDiagramFig);
else
  fh = timingDiagramFig;
end

tdax = get(fh, 'CurrentAxes');
if isempty(tdax)
  tdax = gca;
end

% Retrieve stored info from figure object
userdata = get(fh, 'UserData');
yaxisdb = userdata.yaxisdb{nodeidx, modidx};

% Increment counter for tracking execution order
execorder = userdata.execorder+1;

% Extract last history entry from module
block = modobj.history{end};

% Recall CURRENT (when this function is run) user parameters
userParams = GetUserParams(nodeobj);

% Draw a rectangle if it's a transmit/receive block.  
% Draw a line if it's a wait block
switch block.job
  case {'receive', 'transmit'}
    if isfield(userParams, 'faceColor')
      if isfield(userParams.faceColor, modobj.name)
        faceColor = userParams.faceColor.(modobj.name); % Set the block color
        
      else
        fprintf(['\nWarning: Cannot update the timing diagram block color for %s:%s\n'...
                 '         because the module name ''%s'' is not a field of userParams.faceColor!\n\n'],...
                GetNodeName(nodeobj),modobj.name,modobj.name);
        faceColor = [];
      end
    else
      faceColor = [];
    end
    
    if isempty(faceColor)
      % Map block center frequency to a color on the colormap
      % freqRange = maxFreq-minFreq;
      colorIdx = floor((block.fc-minFreq)/(maxFreq-minFreq)*(size(userdata.cmap, 1)-1))+1;
      colorIdx = min(colorIdx, size(userdata.cmap, 1));
      colorIdx = max(colorIdx, 1);
      faceColor = userdata.cmap(colorIdx, :);
    end
    
    % Draw rectangle
    x = block.start;
    y = yaxisdb.ypos-.5*rectThickness;
    w = block.blockLength-1;
    h = rectThickness;

    % Set callback for when the user clicks the rectangle
    if activateCallback
      % Use user-defined callback if provided, otherwise
      % call the default callback
      if isempty(modobj.TDCallbackFcn)
        TDCallback = @DefaultTDCallback;
      else
        TDCallback = modobj.TDCallbackFcn;
      end
      


      if nargin(TDCallback)==9
        % Embed callback into rectangle
        rectangle('Parent', tdax, ...
                  'Position', [x y w h], ...                   
                  'FaceColor', faceColor, ...
                  'LineWidth', lineWidth, ...
                  'EdgeColor', lineColor, ...      
                  'ButtonDownFcn', ...
                  {TDCallback, ...
                   modobj.filename, block.fPtr, ...
                   timingDiagramFig+execorder, ...
                   yaxisdb.nodename, ...
                   yaxisdb.modname, ...
                   block.fc, block.fs}); 
        
      elseif nargin(TDCallback)==10
        % Recall CURRENT (when this function is run) user parameters
        userParams = GetUserParams(nodeobj);

        % Embed callback into rectangle
        rectangle('Parent', tdax, ...
                  'Position', [x y w h], ...                   
                  'FaceColor', faceColor, ...
                  'LineWidth', lineWidth, ...
                  'EdgeColor', lineColor, ...      
                  'ButtonDownFcn', ...
                  {TDCallback, ...
                   modobj.filename, block.fPtr, ...
                   timingDiagramFig+execorder, ...
                   yaxisdb.nodename, ...
                   yaxisdb.modname, ...
                   block.fc, block.fs, userParams}); 

      else
        error('Unable to handle timing diagram with %d arguments', nargin(TDCallback));
      end
    else
      1; %#ok if this line is unreachable
      rectangle('Parent', tdax, ...
                'Position', [x y w h], ...                   
                'FaceColor', faceColor, ...
                'LineWidth', lineWidth, ...
                'EdgeColor', lineColor); 
    end
    
    % Draw tick mark between blocks
    if drawTickEnable
      line([x-.5 x-.5], ...
           yaxisdb.ypos+[-.5 .5]*tickThickness, ...
           'Parent', tdax, ...
           'LineWidth', lineWidth, ...
           'Color', lineColor); 
    end
    

  case 'wait'
    % Draw black line
    x = block.start;
    y = yaxisdb.ypos;
    w = block.blockLength-1;
    line([x x+w], [y y], ...
         'Parent', tdax, ...
         'LineWidth', lineWidth, ...
         'Color', lineColor); 
    
  otherwise
    error(['Unrecognized block type ' block.job '.']);
end

% Draw execution order above where rectangle would be
if showExecOrder
  x = block.start;
  y = yaxisdb.ypos-.5*rectThickness;
  text(x, y-execOrderYOffset, 0, ...
       sprintf('%d', execorder), ...
       'Parent', tdax, ...
       'VerticalAlignment', 'Bottom', ...
       'FontSize', execOrderFontSize); 
end

% Save execorder variable
userdata.execorder = execorder;
set(fh, 'UserData', userdata);

% Force plot update if requested
if forceRefresh
  drawnow;
end



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


