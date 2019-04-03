function display(env)

% ENVIRONMENT class display function

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
  if isempty(env.building)
    fprintf('            building: []\n');
  else
    fprintf('            building.\n');
    fprintf('         avgRoofHeight: %s m\n', num2str(env.building.avgRoofHeight));
  end
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


