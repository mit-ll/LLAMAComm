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


