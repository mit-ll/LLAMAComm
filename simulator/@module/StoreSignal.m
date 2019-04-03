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

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


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




% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


