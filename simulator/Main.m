function [nodes,env,result] = Main(nodes,env)

% Function sim/Main.m:
% Top-level simulation function.
%
% USAGE: f = Main(nodes)
%
% Input arguments:
%  nodes    (node obj array) Array of all node objects in the simulation
%            universe.
%  env      (environment object) Environment object.  Holds environmental
%            parameters and link objects.
%
% Output arguments:
%  nodes    (node obj array) Modified copy of node objects (containing
%            results from the simulation)
%  env      (environment object) Modified copy of environment containing
%            all used links.
%  result   (int) Simulation result.  1 if successful, 0 otherwise
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

global saveRootDir;
global saveDir;
global timingDiagramFig;
global DisplayPrintStatements;
global DisplayLLAMACommWarnings;
global addGaussianNoiseFlag;
global saveDirIsAvailable

% if saveDirIsAvailable is empty, Main needs to create a new saveDir
if ( isempty(saveDirIsAvailable) || (saveDirIsAvailable == false) )
  % Create save directory for storing simulation data
  timestamp = datestr(now,30);
  saveDir = fullfile(saveRootDir,timestamp);

  [success, message] = mkdir(saveDir);
  if ~success
      fprintf('Cannot make directory %s.',saveDir);
      error(message);
  end
end

% Initialize timing diagram figure
if timingDiagramFig
    InitTimingDiagram(nodes);
end

if ~DisplayPrintStatements
    fprintf(['\nReminder: Simulation status is not being printed.\n'...
             '          See InitGlobals.m to change this setting.\n\n'])
end

if ~DisplayLLAMACommWarnings
    fprintf(['\nReminder: LLAMAComm warnings are not being printed.\n'...
             '          See InitGlobals.m to change this setting.\n\n'])
end

% Setup the correlated shadowloss vector
e = struct(env);
if isempty(e.shadow)
    [env] = SetupShadowloss(env,nodes);
else
    if DisplayLLAMACommWarnings
        fprintf(['\nWarning: The environment property ''shadow'' already exists.',...
                 '\n         The already existing shadow losses will be used.\n']);
    end
end

% Give a warning if links are present
if DisplayLLAMACommWarnings
    k = e.links;
    if ~isempty(k)
        fprintf(['\nWarning: The environment property ''links'' already exists.',...
                 '\n         The following already existing links will be used:\n']);
        fprintf(   '         Link #        From (node:module) -> To (node:module:fc)\n\n');
        for kLoop=1:length(k)
            [fromID,toID] = GetLinkToFrom(k(kLoop));
            fromStr = sprintf('%s:%s',fromID{1},fromID{2});
            toStr = sprintf('%s:%s:%.3f MHz',toID{1},toID{2},toID{3}/1e6);
            fprintf('          % 3d.  %25s -> %-25s\n',kLoop,fromStr,toStr);
        end
        fprintf('\n')
    end
end

% Give a warning if Additive Gaussian Noise is not being generated
if DisplayLLAMACommWarnings
    if addGaussianNoiseFlag == 0
        fprintf(['\nWarning: Additive Gaussian Noise is not being generated.\n',...
                 '           Please see InitGlobals.m to change this setting.\n']);
    end
end

% Simulation loop
while(1)

    if ~true % 1 if want to display node state information
        for n = 1:length(nodes)
            p = GetUserParams(nodes(n));
            disp(' ')
            if strcmpi(p.name(1),'b') % Base
                disp(['(In Main.m) ',p.name,': State = ''',GetNodeState(nodes(n)),''', Slot = ',num2str(p.rx.slotCounter),', Pulse = ',num2str(p.rx.pulseCounter),', Chip = ',num2str(p.rx.chipCounter),', Processing Sample = ',num2str(p.rx.processingSampleCounter),', Sample = ',num2str(p.rx.sampleCounter)])
            else % Mobile or Interferer
                disp(['(In Main.m) ',p.name,': State = ''',GetNodeState(nodes(n)),''', Slot = ',num2str(p.tx.slotCounter),', Pulse = ',num2str(p.tx.pulseCounter),', Chip = ',num2str(p.tx.chipCounter),', Processing Sample = DNE, Sample = ',num2str(p.tx.sampleCounter)])
            end
            if n == length(nodes)
                disp(' ')
            end
        end
    end

    % Run node controller code
    [nodes,constat] = RunNodeControllers(nodes);

    % Run airtime arbitrator
    [nodes,env,arbstat] = RunArbitrator(nodes,env);

    % Check for stuck condition
    if strcmp(arbstat,'stalled')
        disp('Simulation stalled.');
        result = 0;
        break;
    end

    % Check for finish
    if strcmp(constat,'done')
        disp('Simulation finished successfully.');
        result = 1;
        break;
    end

end

% Close all open files
fclose('all');

% Delete now-invalid FIDs from modules
nodes = ClearModFIDs(nodes);





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


