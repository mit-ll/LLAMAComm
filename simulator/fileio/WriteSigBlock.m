function [count, fPtr] = WriteSigBlock(fid, sig, startIdx, precision, fc, fs)

% Function fileio/WriteSigBlock.m:
% Writes a block of signal data to disk, along with some header
% information.  Running this function puts the file pointer at the end
% of the file.
%
% USAGE: count = WriteSigBlock(fid, sig, startIdx, nSamps, nChannels, ...
%                precision, fc, fs)
%
% Input arguments:
%  fid        (fid) File Identifier (see fopen)
%  sig        (MxN) Complex samples.  M channels x N samples
%  startIdx   (int) Sample index for start of block (simulation samples,
%              not file samples)
%  precision  (string) 'float32' or 'float64'
%  fc         (double) Center frequency of modulated signal, Hz
%  fs         (double) Sample rate, Hz  (Should be constant)
%
%
% Output argument:
%  count      (int) Number of bytes written to file
%  fPtr       (int) Offset that points to start of block in file
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

% Recover number of samples and number of channels
nSamps = size(sig, 2);
nChannels = size(sig, 1);

% Convert precision to #
switch precision
  case 'float32'
    prec = 0;
    BpS = 4;          % Bytes/sample
  case 'float64'
    prec = 1;
    BpS = 8;          % Bytes/sample
  otherwise
    error('Unrecognized precision string ''%s''\n', precision);
end

% Calculate bytes required to store block
nBytesData = 2*nSamps*nChannels*BpS;
nBytesHeader = 44;
nBytesTot = nBytesData+nBytesHeader;

% Move file pointer to end of file (append data)
fseek(fid, 0, 'eof');
startPos = ftell(fid);

% Write header
fwrite(fid, nBytesTot, 'uint32');
fwrite(fid, startIdx, 'uint32');
fwrite(fid, nSamps, 'uint32');
fwrite(fid, nChannels, 'uint32');
fwrite(fid, prec, 'uint32');
fwrite(fid, BpS, 'uint32');
fwrite(fid, fc, 'float64');
fwrite(fid, fs, 'float64');

% Write samples
sigrow = sig(:).';
fwrite(fid, [real(sigrow); imag(sigrow)], precision);

% Write footer
fwrite(fid, nBytesTot, 'uint32');

% Calculate total size in bytes
stopPos = ftell(fid)-1;
count = stopPos-startPos+1;

% Return file pointer
fPtr = startPos;


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


