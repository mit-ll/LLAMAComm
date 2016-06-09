function ber = LLMimo_CalcBER(nodes)

% Function user.LL/LLMimo_CalcBER.m:
% Calculates the Bit-Error Rate for the LLMimo example
%
% USAGE:  ber = LLMimo_CalcBER(nodes)
%
% Input arguments:
%  nodes     (node obj array, 1xN) Node objects
%
% Output arguments:
%  ber       (1x1) BER for DN->AN link
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Extract user parameters
pAN = GetUserParams(FindNode(nodes,'AN'));
pDN = GetUserParams(FindNode(nodes,'DN'));

% Open saved files for reading
ANfid = OpenBitFile(pAN.rxBitsFilename);
DNfid = OpenBitFile(pDN.txBitsFilename);

% Loop through blocks
ANfPtr = 0;
DNfPtr = 0;
errCount = 0;
bitCount = 0;
while(1)

    [ANbits,ANfPtr] = ReadBitBlock(ANfid,ANfPtr);
    [DNbits,DNfPtr] = ReadBitBlock(DNfid,DNfPtr);
    
    if isempty(ANbits) && isempty(DNbits)
        % Done with files
        break;
        
    elseif ~isempty(ANbits) && ~isempty(DNbits)
        % Compare data
        errs = find(xor(ANbits,DNbits));
        
        % Count errors and bits
        errCount = errCount+length(errs);
        bitCount = bitCount+size(ANbits,2);
        
    else
        error('Bit files have unequal length!');
    end
end
    
% Calculate BER
ber = errCount/bitCount;

% Print results to screen
fprintf('LL MIMO example, DN->AN BER: %f\n',ber);

% Close opened files
fclose(ANfid);
fclose(DNfid);









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


