function SetupPaths
% Script SetupPaths.m:
% This script adds the required directories to the MATLAB search path.
% User paths should NOT be added here.  User paths should be added
% in the simulation start script (e.g. StartExample.m)

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

% Get name of parent directory
llamacommDir = fileparts(fileparts(which(mfilename)));

addpath(fullfile(llamacommDir, 'simulator'));
addpath(fullfile(llamacommDir, 'simulator', 'channel'));
addpath(fullfile(llamacommDir, 'simulator', 'pathloss'));
addpath(fullfile(llamacommDir, 'simulator', 'pathloss', 'antennas'));
addpath(fullfile(llamacommDir, 'simulator', 'pathloss', 'propmodels'));
addpath(fullfile(llamacommDir, 'simulator', 'fileio'));
addpath(fullfile(llamacommDir, 'simulator', 'td'));
addpath(fullfile(llamacommDir, 'simulator', 'nm'));
addpath(fullfile(llamacommDir, 'simulator', 'tools'));


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


