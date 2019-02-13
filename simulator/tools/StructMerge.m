function s = StructMerge(s,f)

% Function 'StructMerge.m':
% Copies fieds from one structure into another existing structure.
% If a field already exists, this function copies over the existing
% value with the new value and displays a warning.
%
% USAGE:  s = StructMerge(s,f)
%
% Input arguments:
%    s        (struct) Existing structure
%    f        (struct) Structure new fields
%
% Output arguments:
%    s        (struct) Merged structure
%              
% See also: FieldCopy

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


if isempty(s)
    s = f;
    
elseif isempty(f)
    return;
    
elseif isstruct(s) && isstruct(f)

    % Get fieldnames to be set
    fname = fieldnames(f);

    % Loop through all fields in f
    for k=1:length(fname)

        % If field name already exists in s, go ahead and copy the
        % new value from f in, but display a warning
        if isfield(s,fname{k})
            s.(fname{k}) = f.(fname{k});
            fprintf(1,'Warning: Overwriting existing parameter %s\n',fname{k});
        else
            s.(fname{k}) = f.(fname{k});
        end

    end
else
    error('Input arguments must be structs or empty');
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


