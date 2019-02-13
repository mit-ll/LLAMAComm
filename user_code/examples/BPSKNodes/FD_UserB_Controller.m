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

% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
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



% Approved for public release: distribution unlimited.
% 
% This material is based upon work supported by the Defense Advanced Research 
% Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
% findings, conclusions or recommendations expressed in this material are those 
% of the author(s) and do not necessarily reflect the views of the Defense 
% Advanced Research Projects Agency.
% 
% © 2014 Massachusetts Institute of Technology.
% 
% The software/firmware is provided to you on an As-Is basis
% 
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
% DFARS 252.227-7014 as detailed above. Use of this work other than as 
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


