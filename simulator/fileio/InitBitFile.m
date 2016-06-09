function [fid,fullfilename] = InitBitFile(filename)

% Function fileio/InitSaveBits.m:
% Opens a file for writing/reading binary data.  Each bit is stored in a
% separate byte.  This is inefficient, but more convenient for
% reading/writing an arbitrary number of bits.
%
% Reading from an file opened using InitBitFile is allowed, but if
% you later want to read from the file only, use OpenBitFile
%
% The save file will be created in the globally defined save directory
% be default. Manually specifying a save directory as part of the filename
% will override this, but is not recommended.
%
% By convention, files created by this set of functions should have 
% the extension .bit.  If no extension is provided in the filename, 
% .bit will be added.
%
% USAGE: [fid,fullfilename] = InitBitFile(filename)
%
% Input argument:
%  filename     (string) Filename of file to be written to
%
% Output argument:
%  fid          (fild id) See fopen for details.
%  fullfilename (string) Full path and filename of save file opened
%
% Example of preferred usage:  
%
%   [p.txBitsFID,p.txBitsFilename] = InitBitFile('txbits');
%
%  This will create a file named 'txbits.bit' in save/[timestamp]/
%  where [timestamp] is a directory name based on the time the simulation
%  was started.
%
%  Fullfilename can be saved to the user parameters to make it easy
%  to later open the file for reading.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global saveDir;

% Create filename
[pathstr,name,ext] = fileparts(filename);
if isempty(pathstr)
   pathstr = saveDir;
end
if isempty(ext)
    ext = '.bit';
end
fullfilename = fullfile(pathstr,[name ext]);

% Open file for binary writing    
[fid,msg] = fopen(fullfilename,'w+','ieee-le');

% Check for error
if fid==-1
    fprintf('InitBitFile: Having trouble creating a file\n');
    fprintf('named "%s" for writing.\n',fullfilename);
    error(msg);
end


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


