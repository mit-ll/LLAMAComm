function samples = ReadInt16Block(fid, nSamp, nChan)

% Function 'ReadInt16Block.m':
% Reads int16 data from a file and returns complex-valued samples
%
% USAGE: data = requestInterf(bandObj, nSamp, nChan)
%
% Input argument:
%  bandObj    (band object) Input band object
%  nSamp      (integer) Number of complex-valued samples to obtain
%  nChan      (integer) Number of channels (default is 1)
%
% Output argumetn:
%  samples    (nChan x N complex) Complex-valued samples
%

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

if nargin < 3
    nChan = 1;
end

% Read int16 samples
samples = fread(fid, [2*nChan nSamp], 'int16');

% Check that we got enough samples back
if numel(samples)~=2*nChan*nSamp
  error('File is empty!  Get larger file!');
end

% Convert to complex samples
samples = complex(samples(1:2:(2*nChan-1), :), samples(2:2:(2*nChan), :)); % nChan x nSamp



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


