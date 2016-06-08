% Script StartExample.m:
% The start script sets up the MATLAB path, calls user functions to set up
% the simulation universe, and starts the simulation.  When the simulation
% is complete, user-defined functions can be called to analyze the
% results.
%
% This script runs the example described in the documentation:
%    Easy rural environment
%    2 Half-duplex nodes transmitting BPSK in the FM band
%    2 Full-duplex nodes transmitting BPSK in GlobalStar/ISM
%    1 Complex white gaussian noise interferer in the ISM band
%    1 complex colored gaussian noise interferer in the FM band
%    2 LL Mimo nodes (forward link with genie reverse link)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add required directories containing simulator functions 
% to the MATLAB search path
SetupPaths;

% Paths to user-defined functions
addpath ./examples
addpath ./examples/BPSKNodes
addpath ./examples/MIMONodes
addpath ./examples/InterferenceNodes

% Clear old variables
%clear all;

% Initialize global variables
InitGlobals;

% Start timer to measure simulation time
tic

% Build example environment
env = Ex_BuildEnvironment;

% Populate simulation universe with nodes
nodes = HD_BuildNodes;
nodes = [nodes FD_BuildNodes];
nodes = [nodes Ex_BuildInterference];
nodes = [nodes LLMimo_BuildNodes('short','rural')];

% Make a map of the nodes
MakeNodeMap(nodes,1);

% Start simulation
[nodes,env,success] = Main(nodes,env);

% Analyze results
if success
    HD_BER = HD_CalculateBER(nodes);
    FD_BER = FD_CalculateBER(nodes);
    LL_BER = LLMimo_CalcBER(nodes);
end

% Stop timer
toc

% Save workspace variables and timing diagram figure
save(fullfile(saveDir,'Workspace'));
if timingDiagramFig
    saveas(timingDiagramFig,fullfile(saveDir,'TimingDiagram'),'fig');
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


