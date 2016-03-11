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
