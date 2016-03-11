function [modobj, fPtr] = StoreSignal(sig, modobj, nodename)

% Function @module/StoreSignal.m:
% Stores analog signal information to disk for later retrieval.
%
% USAGE: modobj = StoreSignal(sig, modobj, nodename)
%
% Input arguments:
%  sig      (MxN complex) M channels x N data points
%  modobj   (module obj) Module object responsible for signal
%  nodename (string) Name of the node containing the module.  The
%            name is used for building a unique filename
%
% Output argument:
%  modobj   (module obj) Module object with modified save file info
%  fPtr     (int) Offset that points to start of block in file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global saveDir;
global savePrecision;

% Create binary file for read/write if needed
if isempty(modobj.fid)
    filename = sprintf('%s-%s.sig', nodename, modobj.name);
    [fid, msg] = fopen(fullfile(saveDir, filename), 'w+', 'ieee-le');
    
    if fid==-1
        fprintf('@module/StoreSignal: Having trouble creating a file\n');
        fprintf('named "%s" for writing.\n', fullfile(saveDir, filename));
        error(msg);
    else
        modobj.filename = fullfile(saveDir, filename);
        modobj.fid = fid;
    end
end

% Save data
[count, fPtr] = WriteSigBlock(modobj.fid, sig, modobj.blockStart, ...
    savePrecision, modobj.fc, modobj.fs); %#ok - count unused




% Copyright (c) 2006-2012, Massachusetts Institute of Technology All rights
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


