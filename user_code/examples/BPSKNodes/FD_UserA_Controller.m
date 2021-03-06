function [nodeobj,status] = FD_UserA_Controller(nodeobj)

% Function FD_UserA_Controller.m:
% Controller state machine for FD_UserA nodeobj.  This is set up to simulate
% a full-duplex link.  These controllers assume that the user nodes are
% already synchronized.
%
% USAGE: [nodeobj,status] = FD_UserA_Controller(nodeobj)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object.  (The user node that called
%              contains a handle to this callback function.)
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of node object
%  status     (string) Either 'running' or 'done'
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

status = 'running';  % Default status

% Load user parameters
p = GetUserParams(nodeobj);

% Get current node state
currState = GetNodeState(nodeobj);

% State machine next-state and output "logic"
switch currState
    case 'start'
        % Listen for awhile
        nodeobj = SetModuleRequest(nodeobj,'fd2_rx','receive',p.blockLen);
        nodeobj = SetModuleRequest(nodeobj,'fd1_tx','wait',p.blockLen);
        nextState = 'listen_wait';

    case 'listen_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Pause for awhile
            nodeobj = SetModuleRequest(nodeobj,'fd2_rx','wait',250);
            nodeobj = SetModuleRequest(nodeobj,'fd1_tx','wait',250);

            nextState = 'pause_wait';
        else
            % Requests pending, wait
            nextState = 'listen_wait';
        end

    case 'pause_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Start tx/rx
            nodeobj = SetModuleRequest(nodeobj,'fd2_rx',...
                                       'receive',p.blockLen);
            nodeobj = SetModuleRequest(nodeobj,'fd1_tx',...
                                       'transmit',p.blockLen);
            nextState = 'txrx_wait';
        else
            % All requests not satisfied, wait
            nextState = 'pause_wait';
        end

    case 'txrx_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            if p.transmittedBlocks >= p.nBlocksToSim
                % Goto done
                nextState = 'done';
                nodeobj = SetModuleRequest(nodeobj,'fd2_rx','done');
                nodeobj = SetModuleRequest(nodeobj,'fd1_tx','done');
            else
                % Tx/Rx again
                nodeobj = SetModuleRequest(nodeobj,'fd2_rx',...
                                                'receive',p.blockLen);
                nodeobj = SetModuleRequest(nodeobj,'fd1_tx',...
                                                'transmit',p.blockLen);
                nextState = 'txrx_wait';
            end
        else
            % All requests not satisfied, wait
            nextState = 'txrx_wait';
        end

    case 'done'
        % Done!
        nextState = 'done';
        status = 'done';

    otherwise
        error('Unknown state: %s',currState);
end

% Set next state
nodeobj = SetNodeState(nodeobj,nextState);

% Store possibly modified user params
nodeobj = SetUserParams(nodeobj,p);



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


