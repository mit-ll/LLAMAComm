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


