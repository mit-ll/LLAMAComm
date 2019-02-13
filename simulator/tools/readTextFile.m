function out = readTextFile(filename)
%
%Usage:
%
%  out = readTextFile(filename)
% 
%  Reads a comma delimited text file into a cell array and does some 
% numeric conversions when applicable
% 
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

% Internal parameters
compact=~true;

fp = fopen(filename, 'r');
if fp==-1
  error('File not found');
end
tt = textscan(fp, '%s', 'Delimiter', char([10,11,13]), 'WhiteSpace','');
fclose(fp);
if ~isempty(tt)
  tt = tt{1};
end


% Main loop
out = {};
outputRowIndx = 0;
for inputRowIndx=1:numel(tt)
  if isempty(tt{inputRowIndx})
    if ~compact
      outputRowIndx = outputRowIndx + 1;
    end
  else
    outputRowIndx = outputRowIndx + 1;
    qq = textscan(tt{inputRowIndx},'%s','Delimiter',',');
    if ~isempty(qq)
      qq = qq{1};
    end
    for outputColumn = 1:numel(qq)
      convert= str2num(qq{outputColumn}); %#ok - str2num has desired behavior
      if isempty(convert)
        out{outputRowIndx, outputColumn} = qq{outputColumn}; %#ok - grows in loop
      else
        out{outputRowIndx, outputColumn} = convert; %#ok - grows in loop
      end
    end
  end
end

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

