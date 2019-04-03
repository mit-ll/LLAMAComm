function s = FieldCopy(s, f)

% Function 'FieldCopy.m':
% Copies the values from fields in a partial structure, f, to
% corresponding fields in structure s.  If a field specified in f
% does not exist in s, an error is generated.  This is to disallow
% the creation of additional fields in s.
%
% USAGE:  s = FieldCopy(s, f)
%
% Input arguments:
%    s        (struct) Existing structure
%    f        (struct) Partial structure with values filled in%
%
% Output arguments:
%    s        (struct) Modified copy of input s where field values
%              have been replaced by fields in f.
%
% See also: StructMerge

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


% Get fieldnames to be set
fname = fieldnames(f);

% Loop through all fields in f
for k = 1:numel(fname)

    % If field name already exists in s, go ahead and copy the
    % new value from f in.
    if isfield(s, fname{k})
        s.(fname{k}) = f.(fname{k});
    else
        error('Field ''%s'' does not exist in s', fname{k});
    end

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


