function [varargout] = matsize(varargin)
% function [varargout] = matsize(varargin)
% convert a collection of variables into equal sized matrices.
% Inputs may be scalars or matrices. All matrices must be
% the same size. Scalars are converted to equal sized matrices
% with all elements equal valued. The number of input and
% output arguments must be equal.
% Function returns matrices = NaN if input contains different sized
% non-scaler matrices.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout > nargin
  error('Number of outputs cannot exceed number of inputs');
end

scalarflag = cellfun('prodofsize', varargin)<=1;
varargout = varargin;
if all(scalarflag); 
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


