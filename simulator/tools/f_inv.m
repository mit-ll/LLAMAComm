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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

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
  elseif y(I) == maxy
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

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


