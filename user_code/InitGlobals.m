% This script (to be run at the top-level) initializes a small
% handful of parameters that will be used simulation-wide

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


clear global;

% Declare global variables
global simulationSampleRate;
global chanType;
global includePropagationDelay;
global includeFractionalDelay;
global randomDelaySpread;
global saveDir;                 %#ok Initialized in sim/Main.m
global saveRootDir;
global savePrecision;
global timingDiagramFig;
global timingDiagramForceRefresh;
global timingDiagramShowExecOrder;
global addGaussianNoiseFlag;
global DisplayLLAMACommWarnings;
global heightLimitDiffuseScattering;

% Initialize global variables
%------------------------------------------------------------------------
% SimulationSampleRate

% Determines the sample rate (in Hz) used to represent baseband signals.
simulationSampleRate = 12.5e6;

%------------------------------------------------------------------------
% Determines the channel propagation model used to build links in LLAMAComm
chanType = 'stfcs';  % 'wssus', 'stfcs', 'los_awgn', 'wideband_awgn',
                     % or 'env_awgn'

%------------------------------------------------------------------------
% Include propagation delay

% Set flag to include propagation delay between modules
includePropagationDelay = 0;

% Set flag to include fractional-sample propagation delays by applying
% a non-causal length-63 fractional-delay filter to the signals.
% Otherwise, the propagation delay is rounded to the nearest sample.
includeFractionalDelay = 0;

%------------------------------------------------------------------------
% Random delay spread.
%
% Setting this variable to 1 makes the delay spread for each link a
% log-normal random variable paramaterized by the link distance and
% correlated with the link shadowloss.  (See /@node/GetDelaySpread.m
% for more details.)
%
% If this variable is set to 0, then the delay spread for all links in the
% simulation will be equal to the environment property env.delaySpread.
randomDelaySpread = 0;

%------------------------------------------------------------------------
% Save file parameters

% These parameters deal with where and how simulation data is saved.
saveRootDir = './save';
savePrecision = 'float32';      % Single-precision floating point

%------------------------------------------------------------------------
% Timing Diagram figure control

% timingDiagramFig:
% Figure number for the timing diagram.
% Set to 0 to turn off
timingDiagramFig = 100000;

% timingDiagramForceRefresh:  {1 or 0}
% Forces the timing diagram to be redrawn after each block.  This
% allows you to see the blocks displayed as they are calculated, but
% slows down the simulation significantly.
timingDiagramForceRefresh = 1;

% timingDiagramShowExecOrder; (true or false)
% Controls whether or not the execution order is displayed on the blocks
% in the timing diagram
timingDiagramShowExecOrder = true;

%------------------------------------------------------------------------
% This flag turns the additive Gaussian noise on/off---used for debugging
addGaussianNoiseFlag = 1;

%------------------------------------------------------------------------
% This variable sets the height limit below which diffuse scattering is
% assumed (and a Doppler spread applied to the channel) and above which
% static specular scattering is assumed (and a Doppler shift is applied to
% the channel)
heightLimitDiffuseScattering = 50;

%------------------------------------------------------------------------
% LLAMAComm warnings are printed to the command window if this flag is set.
DisplayLLAMACommWarnings = 1;


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


