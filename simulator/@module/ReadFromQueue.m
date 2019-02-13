function [modobj, info] = ReadFromQueue(modobj)

% Function @module/ReadFromQueue.m:
% Takes first item off of genie queue.
%
% USAGE: modobj = ReadFromQueue(modobj, info)
%
% Input arguments:
%  modobj    (module obj) Module object
%
% Output arguments:
%  modobj    (module obj) Modified module object (item removed from queue)
%  info      (struct) Struct containing data to add to genie queue.
%             Returns {} if empty.
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

% Check that modobj is a designated genie module
if ~IsGenie(modobj)
    error('ReadFromQueue is only for use on genie modules');
end

% Take first item off of queue
if isempty(modobj.genieQueue)
    info = {};
elseif length(modobj.genieQueue)==1
    info = modobj.genieQueue{1};
    modobj.genieQueue = {};
else
    info = modobj.genieQueue{1};
    modobj.genieQueue = modobj.genieQueue(2:end);
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


