function [nodeobj,status] = LLMimo_AN_Controller(nodeobj)

% Function user.LL/LLMimo_AN_Controller.m:
% Controller state machine for LL Mimo example advantaged node.
% This node is receive only.  The link from AN to DN is simulated
% using the genie channel.
%
% USAGE: [nodeobj,status] = LLMimo_AN_Controller(nodeobj)
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
        % Set up file for saving received bits
        [p.rxBitsFID,p.rxBitsFilename] = InitBitFile('LLMimo_Rx');

        % Set up to receive first block
        nodeobj = SetModuleRequest(nodeobj,'LLmimo_rx','receive',p.blockLen);
        nextState = 'receive_st';
        
    case 'receive_st'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Increment receivedBlocks counter
            p.receivedBlocks = p.receivedBlocks+1;
            
            if p.receivedBlocks>=p.nBlocksToSim
                % Done with simulation
                nodeobj = SetModuleRequest(nodeobj,'LLmimo_rx','done');
                nextState = 'done';
            else
                % Put send data into module's genie queue
                nodeobj = WriteGenieInfo(nodeobj,'genie_tx',p.passToTx);

                % Request send through genie channel to DN's genie receive
                nodeobj = SetGenieTxRequest(nodeobj,'genie_tx','DN','genie_rx');

                nextState = 'genietx_st';
            end
        else
            % All requests not satisfied, wait
            nextState = 'receive_st';
        end

    case 'genietx_st'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Sent feedback, receive next block
            nodeobj = SetModuleRequest(nodeobj,'LLmimo_rx','receive',p.blockLen);
            nextState = 'receive_st';
        else
            % Feedback not sent yet, wait.
            nextState = 'genietx_st';
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


