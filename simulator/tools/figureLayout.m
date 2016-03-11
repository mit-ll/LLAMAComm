function layout = figureLayout(layout,bringFrontFlag)
% Layout figures


if exist('layout','var') && ~isempty(layout)
    for I = 1:size(layout,1);
        
        % Check to see if you should bring the figures to the foreground
        if exist('bringFrontFlag','var') && ~isempty(bringFrontFlag)
            if bringFrontFlag
                figure(layout(I,1));
            else
                % Open or set current figure active
                touchFigure(layout(I,1));
            end
        else
            % Open or set current figure active
            touchFigure(layout(I,1));
        end
        
        % Set the figure position
        set(layout(I,1),'Position',layout(I,2:end));
    end
end 

h = get(0,'children');
layout = zeros(length(h),5);
for I = 1:length(h)
    layout(I,1) = h(I);
    layout(I,2:end) = get(h(I),'Position');
end


function h = touchFigure(fig)
%
%Usage:
%
%   touchFigure
%   touchFigure(H)
%
%Description:
%
% Works just like figure(H), except that the figure is 
% not raised if it already exists.
%

if nargin < 1
  fig = get(0, 'CurrentFigure');
  if isempty(fig)    
    fig = figure;
  end
else
  try
    if ishandle(fig)
      set(0,'CurrentFigure', fig)
    else 
      figure(fig);
    end
  catch ME
    rethrow(ME);
  end
end

if nargout > 0
  h=fig;
end
