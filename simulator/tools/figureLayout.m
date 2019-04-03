function layout = figureLayout(layout,bringFrontFlag)

% Layout figures

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


if exist('layout','var') && ~isempty(layout)
    for I = 1:size(layout,1)

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
