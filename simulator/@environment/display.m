function display(env)

% ENVIRONMENT class display function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(inputname(1))
  fprintf('\n%s = \n\n', inputname(1));
end

if length(env) ~= 1
  fprintf(' %dx%d ENVIRONMENT matrix.\n', size(env));
  fprintf('\n');
else
  fprintf('            envType: %s\n', env.envType);
  fprintf('          propParams.\n');
  fprintf('           delaySpread: %s s\n', num2str(env.propParams.delaySpread));
  fprintf('        velocitySpread: %s m/s\n', num2str(env.propParams.velocitySpread));
  fprintf('                 alpha: %s\n', num2str(env.propParams.alpha));
  fprintf('     longestCoherBlock: %s s\n', num2str(env.propParams.longestCoherBlock));
  fprintf('  stfcsChannelOversamp: %s\n', num2str(env.propParams.stfcsChannelOversamp));
  fprintf('wssusChannelTapSpacing: %s samples\n', num2str(env.propParams.wssusChannelTapSpacing));
  fprintf('              los_dist: %s m\n', num2str(env.propParams.los_dist));
  fprintf('            building.\n');
  fprintf('         avgRoofHeight: %s m\n', num2str(env.building.avgRoofHeight));
  if isempty(env.shadow)
    fprintf('\n           shadow: []\n');
  else
    fprintf('\n           shadow.\n');
    disp(env.shadow);
  end

  fprintf('Link #        From (node:module) -> To (node:module:fc)\n\n');
  for k=1:length(env.links)
    [fromID, toID] = GetLinkToFrom(env.links(k));
    fromStr = sprintf('%s:%s', fromID{1}, fromID{2});
    toStr = sprintf('%s:%s:%.3f MHz', toID{1}, toID{2}, toID{3}/1e6);
    fprintf(' % 3d.  %25s -> %-25s\n', k, fromStr, toStr);
  end
  fprintf('\n');
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


