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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


