function [nodeobj,status] = FD_UserB_Controller(nodeobj)

% Function FD_UserB_Controller.m:
% Controller state machine for FD_UserB nodeobj.  This is set up to simulate
% a full-duplex link.  These controllers assume that the user nodes are 
% already synchronized.
%
% USAGE: [nodeobj,status] = FD_UserB_Controller(nodeobj)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object.  (The user node that called
%              contains a handle to this callback function.)
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of node object
%  status     (string) Either 'running' or 'done'
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

status = 'running';  % Default status

% Load user parameters
p = GetUserParams(nodeobj);

% Get current node state
currState = GetNodeState(nodeobj);

% State machine next-state and output "logic"
switch currState
    case 'start'
        % Listen for awhile
        nodeobj = SetModuleRequest(nodeobj,'fd1_rx','receive',p.blockLen);
        nodeobj = SetModuleRequest(nodeobj,'fd2_tx','wait',p.blockLen);
        nextState = 'listen_wait';
        
    case 'listen_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0 
            % Pause for awhile
            nodeobj = SetModuleRequest(nodeobj,'fd1_rx','wait',250);
            nodeobj = SetModuleRequest(nodeobj,'fd2_tx','wait',250);
            
            nextState = 'pause_wait';
        else
            % Requests pending, wait
            nextState = 'listen_wait';
        end

    case 'pause_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Start tx/rx
            nodeobj = SetModuleRequest(nodeobj,'fd1_rx','receive',p.blockLen);
            nodeobj = SetModuleRequest(nodeobj,'fd2_tx','transmit',p.blockLen);
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
                nodeobj = SetModuleRequest(nodeobj,'fd1_rx','done');
                nodeobj = SetModuleRequest(nodeobj,'fd2_tx','done');
            else
                % Tx/Rx again
                nodeobj = SetModuleRequest(nodeobj,'fd1_rx','receive',p.blockLen);
                nodeobj = SetModuleRequest(nodeobj,'fd2_tx','transmit',p.blockLen);
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



% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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


