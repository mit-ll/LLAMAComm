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


