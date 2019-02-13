function bits = ReadInfoBits(fid,nBits)

% Function ReadInfoBits.m:
% Returns specified number of bits from the info source file
% as a binary vector.
%
% USAGE: bits = ReadInfoBits(fid,nBits)
%
% Input arguments:
%  fid      (file ID) Valid file ID for binary file open for reading
%  nBits    (integer) Number of bits requested. Multiple of 8
%             only, please!
%
% Output arguments:
%  bits     (1xnBits) Binary vector
%
% See also: InfoBitsRemaining.m, InitInfoSource.m

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


% Check nBits
nBits = floor(nBits);
if mod(nBits,8)~=0
    error('nBits needs to be a multiple of 8');
end

% Read data from file
nBytes = floor(nBits/8);
bytes = fread(fid,nBytes,'uint8');

% Convert bytes to binary vector
bits = zeros(1,nBits);
for k=1:nBytes
    bits((k-1)*8+1:k*8) = byte2binv(bytes(k));
end


%------------------------------------------------------
function binv = byte2binv(byte)

binv = zeros(1,8);
binv(1) = bitget(byte,1);
binv(2) = bitget(byte,2);
binv(3) = bitget(byte,3);
binv(4) = bitget(byte,4);
binv(5) = bitget(byte,5);
binv(6) = bitget(byte,6);
binv(7) = bitget(byte,7);
binv(8) = bitget(byte,8);











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


