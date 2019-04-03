function [varargout] = matsize(varargin)
% function [varargout] = matsize(varargin)
% convert a collection of variables into equal sized matrices.
% Inputs may be scalars or matrices. All matrices must be
% the same size. Scalars are converted to equal sized matrices
% with all elements equal valued. The number of input and
% output arguments must be equal.
% Function returns matrices = NaN if input contains different sized
% non-scaler matrices.

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

if nargout > nargin
  error('Number of outputs cannot exceed number of inputs');
end

scalarflag = cellfun('prodofsize', varargin)<=1;
varargout = varargin;
if all(scalarflag)
  % if all inputs are scalar, there's nothing to do
  return;
end

% return matrices unchanged
notScalarFlag = ~scalarflag;
matsze  = size(varargin{find(notScalarFlag, 1, 'first')});  % matrix size

if ~all(cellfun(@(x) isequal(size(x), matsze), varargin(notScalarFlag)))
  for jj = 1:length(varargin)
    varargout{jj} = NaN;
  end
  return;
end

% turn scalars into matrices
blank = ones(matsze);
varargout{scalarflag} = varargin{scalarflag}*blank;


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


