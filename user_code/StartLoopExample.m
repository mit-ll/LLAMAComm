% Script StartLoopExample.m:
% The start script sets up the MATLAB path, calls user functions to set up
% the simulation universe, and starts the simulation.  The default below
% is to have the same shadow loss for for each simulation run, but to have
% different small-scale channel realizations from run to run.  When the
% simulation is complete, user-defined functions can be called to analyze
% the results.
%
% This script runs the example described in the documentation:
%    Easy rural environment
%    2 Half-duplex nodes transmitting BPSK in the FM band
%    2 Full-duplex nodes transmitting BPSK in GlobalStar/ISM
%    1 Complex white gaussian noise interferer in the ISM band
%    1 complex colored gaussian noise interferer in the FM band
%    2 LL Mimo nodes (forward link with genie reverse link)
%

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

nThrows = 2;  % Number of simulation throws

for throwLoop = 1:nThrows

    % Populate simulation universe with nodes
    nodes = HD_BuildNodes;
    nodes = [nodes FD_BuildNodes];
    nodes = [nodes Ex_BuildInterference];
    nodes = [nodes LLMimo_BuildNodes('short','rural')];

    % Make a map of the nodes
    MakeNodeMap(nodes,1);

    % Start simulation
    [nodes,env,success] = Main(nodes,env);

    % Analyze results after each simulation run
    if success
        HD_BER{throwLoop} = HD_CalculateBER(nodes);
        FD_BER{throwLoop} = FD_CalculateBER(nodes);
        LL_BER{throwLoop} = LLMimo_CalcBER(nodes);
    end

    % Save workspace variables and timing diagram figure
    save(fullfile(saveDir,'Workspace'));
    if timingDiagramFig
        saveas(timingDiagramFig,fullfile(saveDir,'TimingDiagram'),'fig');
    end

    % Stop timer
    toc

    % Remove the 'links' from the environment object so new channel
    % realizations will be created during the next simulation run.
    env = environment(rmfield(struct(env),'links'));

    % Remove the 'shadow' field from the environment object so the
    % link shadow losses will be re-calculated during the next simulation
    % run.
    %env = environment(rmfield(struct(env),'shadow'));


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


