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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


