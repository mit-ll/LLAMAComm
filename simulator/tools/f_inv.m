function x = f_inv(y, xvec, yvec)
% F_INV   Approximates the function inverse x = f^{-1}(y)
%
% x = f_inv(y, xvec, yvec)
% 
% Inputs:
%  y        (double array)  y-values where the inverse should be computed
%  xvec     (double array)  sampled x domain
%  yvec     (double array)  y range samples: yvec = f(xvec)
%
% Output:
%  x        (double array if f(x) = y is one-to-one, otherwise cell array)
%
% This function is great when f(x) = y is defined, but x = f^{-1}(y) is 
% difficult or impossible to derive.  It also comes in handy when only
% the samples 'yvec' and 'xvec' are available and the inverse 
% x = f^{-1)(y) needs to be computed.
%
% The samples 'xvec' and 'yvec' are related through the function lookup
% table f(xvec) = yvec.  The output 'x' is computed through a linear 
% interpolation. The input 'y' must be within the range defined by 
% min(yvec) <= y <= max(yvec); otherwise, a  warning will be displayed 
% and 'x' will be set to 'NaN'. 
%
% For every point in the array 'y', if the function f(x) = y is 
% one-to-one over the sampled domain 'xvec', then the output 'x' will 
% be a  double array of the same length as the input 'y'; otherwise, 
% 'x' will be a cell array of the same length as 'y', where the 
% nth cell contains all the x-values corresponding to the nth entry 
% of the input array 'y'.
%
% Example 1.  f(x) = x^2 = y, domain = [0, 10]
%
%  xvec = [0:.01:10];       % sampled x domain
%  yvec = xvec.^2;          % y-values as a function of the domain samples
%  y = 17;                  % point in the range
%  x = f_inv(y, xvec, yvec)   % note that sqrt(17) = 4.1231
%
%  x = 
% 
%      4.1231
%
% Example 2.  f(x) = x^2 = y, domain = [-10, 10]
%
%  xvec = [-10:.01:10];     % sampled x domain
%  yvec = xvec.^2;          % y-values as a function of the domain samples
%  y = 17;                  % point in the range
%  x = f_inv(y, xvec, yvec)
%
%  x = 
% 
%      [1x2 double]
%
%  x{1}
%
%  ans = 
%
%        -4.1231     4.1231
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = cell(size(y));
[miny, minyind] = min(yvec); %#ok minyind unused
[maxy, maxyind] = max(yvec);

one_to_one = 1;

for I = 1:length(y)

  % throw an error if the y value is outside of the range
  if y(I) < miny || y(I) > maxy
    disp(['   WARNING: y(', num2str(I), ') = ', num2str(y(I)), ...
          ' is not in the set [', num2str(miny), ' ... ', ...
          num2str(maxy), '].  Returning NaN'])
    out{I} = NaN;
    % Check if the y value is equal to the maximum yvec value
  elseif y(I) == maxy;
    out{I} = xvec(maxyind);
  else
    % Find the level change locations
    ind = find(diff(y(I) < yvec));
    
    if length(ind) > 1
      % The function is not one to one
      one_to_one = 0;
    end
    
    out{I} = zeros(1, length(ind));
    for J = 1:length(ind)
      if y(I) == yvec(ind(J))
        % if the y value equals the lower value, the output its abcissa
        out{I}(J) = xvec(ind(J));
      else
        % else make a linear interpolation between the nearest points
        a   = xvec(ind(J));
        b   = xvec(ind(J)+1);
        fa  = yvec(ind(J));
        fb  = yvec(ind(J)+1);
        % calculate the output
        out{I}(J) = (b - a)/(fb - fa) * (y(I) - fa) + a;
      end
    end % END for J
  end % END if y(I) < miny | y(I) > maxy
end % END for I

% Parse output
if one_to_one
  % Change from cell to array if the function is one-to-one
  x = cell2mat(out);
else
  x = out;
end

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


