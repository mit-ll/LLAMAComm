function out = getWorkspaceExcept(varargin)
%
%Usage:
%
%  WS = getWorkspaceExcept
%  WS = getWorkspaceExcept(var1, var2, ...)
%  WS = getWorkspaceExcept(cellArrayOfVarNames)
%
%Description:
%
% Gathers a copies of variables in the current workspace and stores them in a 
% structure, provided they do not occur in the provided list of exceptions.
%
%
%Author: G.S. Fawcett
%Original date: 20/Apr/2016
%Last modified: 20/Apr/2016
%
if nargin == 1 && iscell(varargin{1})
  exceptions = varargin{1};
else
  exceptions = varargin;
end

wh = evalin('caller', 'who');

out = [];
if ~isempty(wh)
  for ii = 1:numel(wh);
    if ~any(strcmp(wh{ii}, exceptions))
      out.(wh{ii}) = evalin('caller', wh{ii});
    end
  end
end

