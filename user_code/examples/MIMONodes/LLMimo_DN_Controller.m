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


