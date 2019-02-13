function [nodeobj,status] = LLMimo_DN_Controller(nodeobj)

% Function user.LL/LLMimo_DN_Controller.m:
% Controller state machine for LL Mimo example disadvantaged node.
% It is transmit only.  The reverse link (from AN to DN) is simulated
% using the genie channel.
%
% USAGE: [nodeobj,status] = LLMimo_DN_Controller(nodeobj)
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
        % Set up info source
        p.infoSourceFID = InitInfoSource(p.infoSourceFilename);

        % Set up file for saving transmitted bits
        [p.txBitsFID,p.txBitsFilename] = InitBitFile('LLMimo_Tx');
        
        % Read first chunk of info
        bitsRemaining = InfoBitsRemaining(p.infoSourceFID);
        if p.infoLen > bitsRemaining
            error('Not enough bits remain in the info source file.');
        end
        p.infoBits = ReadInfoBits(p.infoSourceFID,p.infoLen);
        
        % Set up to transmit first block
        nodeobj = SetModuleRequest(nodeobj,'LLmimo_tx','transmit',p.blockLen);
        nextState = 'transmit_st';
        
    case 'transmit_st'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Increment transmittedBlocks counter
            p.transmittedBlocks = p.transmittedBlocks+1;
            
            if p.transmittedBlocks>=p.nBlocksToSim
                % Done with simulation
                nodeobj = SetModuleRequest(nodeobj,'LLmimo_tx','done');
                nextState = 'done';
            else
                % Transmission done, receive feedback info from genie channel
                nodeobj = SetGenieRxRequest(nodeobj,'genie_rx');
                nextState = 'genierx_st';
            end
        else
            % All requests not satisfied, wait
            nextState = 'transmit_st'; 
        end

    case 'genierx_st'
        requests = CheckRequestFlags(nodeobj);
        if requests==0
            % Got feedback, copy received info into user params
            [nodeobj,p.getFromRx] = ReadGenieInfo(nodeobj,'genie_rx');

            % Read next chunk of info
            bitsRemaining = InfoBitsRemaining(p.infoSourceFID);
            if p.infoLen > bitsRemaining
                error('Not enough bits remain in the info source file. (2)');
            end
            p.infoBits = ReadInfoBits(p.infoSourceFID,p.infoLen);
            
            % Transmit next block
            nodeobj = SetModuleRequest(nodeobj,'LLmimo_tx','transmit',p.blockLen);
            nextState = 'transmit_st';
        else
            nextState = 'genierx_st';
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


