function out = currentLineNum()
%
%Usage:
%
%   currentLineNum
%
%Description:
%
%  Returns the current linenumber within the current M-file, if possible.
%Otherwise, returns empty
%
%Author: G.S. Fawcett
%Original date: 10/Apr/2008
%Last modified: 20/Apr/2016
%

debugInfo = dbstack;
if numel(debugInfo)>1
  out = debugInfo(2).line;
else
  out = [];
end
