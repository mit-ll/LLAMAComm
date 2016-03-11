% This script (to be run at the top-level) initializes a small
% handful of parameters that will be used simulation-wide

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear globals;

% Declare global variables
global simulationSampleRate;
global chanType;
global includePropagationDelay;
global includeFractionalDelay;
global randomDelaySpread;
global saveDir;                 % Initialized in sim/Main.m
global saveRootDir;
global savePrecision;
global timingDiagramFig;
global timingDiagramForceRefresh;
global timingDiagramShowExecOrder;
global addGaussianNoiseFlag;
global DisplayLLAMACommWarnings;

% Initialize global variables
%------------------------------------------------------------------------
% SimulationSampleRate

% Determines the sample rate (in Hz) used to represent baseband signals.
simulationSampleRate = 12.5e6;     

%------------------------------------------------------------------------
% Determines the channel propagation model used to build links in LLAMAComm
chanType = 'stfcs';  % 'wssus', 'stfcs', 'los_awgn', or 'env_awgn'

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
% LLAMAComm warnings are printed to the command window if this flag is set.
DisplayLLAMACommWarnings = 1;


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


