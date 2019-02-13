function [nodeobj,status] = HD_UserB_Controller(nodeobj)

% Function HD_UserB_Controller.m:
% Controller state machine for example Half-Duplex radio.  
% These controllers assume that the user nodes are already synchronized.  
% The UserA and UserB controllers are identical except that UserA starts 
% by sending a block and UserB starts by receiving a block.  
% The controller switches to the done state after receiving/sending a set 
% number of blocks.
%
% USAGE: [nodeobj,status] = HD_UserB_Controller(nodeobj)
%
% Input arguments:
%  nodeobj    (node obj) Parent node object.  
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
        % Set up module for transmission of 1 block
        nodeobj = SetModuleRequest(nodeobj,'hd_tx','wait',p.blockLen);
        nodeobj = SetModuleRequest(nodeobj,'hd_rx','receive',p.blockLen);
        nextState = 'receive_wait';
        
    case 'transmit_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            if p.transmittedBlocks >= p.nBlocksToSim
                % Goto done
                nodeobj = SetModuleRequest(nodeobj,'hd_tx','done');
                nodeobj = SetModuleRequest(nodeobj,'hd_rx','done');
                nextState = 'done';
            else
                % Transmission done, receive
                nodeobj = SetModuleRequest(nodeobj,'hd_tx','wait',p.blockLen);
                nodeobj = SetModuleRequest(nodeobj,'hd_rx','receive',p.blockLen);
                nextState = 'receive_wait';
            end
        else
            % All requests not satisfied, wait
            nextState = 'transmit_wait';
        end

    case 'receive_wait'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Receive done, go back to transmit
            nodeobj = SetModuleRequest(nodeobj,'hd_tx','transmit',p.blockLen);
            nodeobj = SetModuleRequest(nodeobj,'hd_rx','wait',p.blockLen);
            nextState = 'transmit_wait';
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


