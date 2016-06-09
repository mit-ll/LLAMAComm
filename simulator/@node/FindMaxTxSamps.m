function nSamps = FindMaxTxSamps(nodes)

% Function '@nodes/FindMaxTxSamps.m':  
%  Finds the longest transmit time (in samples).  This function is
%  used after a run has completed.
%
% USAGE:  nSamps = FindMaxTxSamps(nodes)
%
% Input arguments:
%  nodes       (node obj array) Array of node objects
%
% Output argument:
%  nSamps      (int) Maximum transmitted samples
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% max number of transmit samples
txSampsMax = 0;

for nodeLoop = 1:length(nodes)
    % Get the node parameters
    nodeobj = nodes(nodeLoop);
    
    % Loop over the modules
    for modLoop = 1:length(nodeobj.modules)
        % Get the module parameters
        modobj = nodeobj.modules(modLoop);
        
        % Make sure module is a transmit module
        if strcmp(GetType(modobj),'transmitter') ...
                  && ~IsGenie(nodeobj.modules(modLoop))
            
            % Get the number of samples transmitted
            modHist = GetHistory(modobj);
            endHist = modHist{end};
            txSampsCurr = endHist.start + endHist.blockLength - 1;
            
            % See if current length is greater than maximum so far
            if txSampsCurr > txSampsMax
                txSampsMax= txSampsCurr;
            end            
            
        end

    end % end modLoop
end % end nodeLoop

% Create output
nSamps = txSampsMax;

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


