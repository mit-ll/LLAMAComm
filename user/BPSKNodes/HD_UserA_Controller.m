function [nodeobj,status] = HD_UserA_Controller(nodeobj)

% Function HD_UserA_Controller.m:
% Controller state machine for example Half-Duplex radio.  
% These controllers assume that the user nodes are already synchronized.  
% The UserA and UserB controllers are identical except that UserA starts 
% by sending a block and UserB starts by receiving a block.  
% The controller switches to the done state after receiving/sending a set 
% number of blocks.
%
% USAGE: [nodeobj,status] = HD_UserA_Controller(nodeobj)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object.  
%
% Output arguments:
%  nodeobj    (node obj) Modified copy of node object
%  status     (string) Either 'running' or 'done'
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
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
        % Set up module for transmission of 1 block
        nodeobj = SetModuleRequest(nodeobj,'hd_tx','transmit',p.blockLen);
        nodeobj = SetModuleRequest(nodeobj,'hd_rx','wait',p.blockLen);
        nextState = 'transmit_wait';
        
    case 'transmit_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Transmission done, receive
            nodeobj = SetModuleRequest(nodeobj,'hd_tx','wait',p.blockLen);
            nodeobj = SetModuleRequest(nodeobj,'hd_rx','receive',p.blockLen);
            nextState = 'receive_wait';
        else
            % All requests not satisfied, wait
            nextState = 'transmit_wait';
        end

    case 'receive_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0 
            if  p.receivedBlocks>=p.nBlocksToSim
                % Goto done
                nodeobj = SetModuleRequest(nodeobj,'hd_tx','done');
                nodeobj = SetModuleRequest(nodeobj,'hd_rx','done');
                nextState = 'done';
            else
                % Receive done, go back to transmit
                nodeobj = SetModuleRequest(nodeobj,'hd_tx','transmit',p.blockLen);
                nodeobj = SetModuleRequest(nodeobj,'hd_rx','wait',p.blockLen);
                nextState = 'transmit_wait';
            end
        else
            % Requests pending, wait
            nextState = 'receive_wait';
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

