%% compareSaveFiles: this function compares the sig files in two directories
% This function expects .sig files in float32 precision format

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2012 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function resultsEqual = compareSaveFiles(source1Path,source2Path,verbose)

if ~exist('verbose', 'var')
    verbose = 0;
end

% get list of sig files in both directories
listing1 = dir(fullfile(source1Path,'*.sig'));
listing2 = dir(fullfile(source2Path,'*.sig'));

if(isempty(listing1) && isempty(listing2))
   warn('Neither path contains a *.sig file, returning false and exiting');
   resultsEqual = false;
   return;
   
% check for existence of .sig files in source1Path   
elseif(isempty(listing1))
   warn(['Path: ',source1Path,' does not contain a *.sig file,',...
         'returning false and exiting']);
   resultsEqual = false;
   return;
   
% check for existence of .sig files in source2Path      
elseif(isempty(listing2))
   warn(['Path: ',source2Path,' does not contain a *.sig file,',...
         'returning false and exiting']);
   resultsEqual = false;
   return;
end

% check for equal numbers of .sig files in both directories      
if(length(listing1) ~= length(listing2))
    if(verbose>0)
        fprintf('resultsEqual = false. The number of output files in each directory are not equal\n');
    end
    resultsEqual = false;
    return;
else
    if(verbose>0)
        fprintf('Equal number of .sig files in both directories\n');
    end
end

% check for equivalent filenames in each directory    
if( ~isempty( setdiff( {listing1.name}, {listing2.name}) )  )
    if(verbose>0)
        fprintf('resultsEqual = false. The file names in the two directories do not match\n');
    end
    resultsEqual = false;
    return;
    
else
    if(verbose>0)
        fprintf('File names are same between both directories\n');
    end
    %match up the file information for the files in source1Path to source2Path
    list2Inds = zeros(length(listing1),1);
    
    for k=1:length(listing1)
        list2Inds(k)=find(strcmp(listing1(k).name,{listing2.name}));
    end
    
    %compare file sizes for corresponding file names
    fileSizeDiffs = ([listing1.bytes]==[listing2(list2Inds).bytes]);
    fileDiffInds = find(~fileSizeDiffs);
    
    if ~isempty(fileDiffInds)
        fprintf('resultsEqual = false. The file sizes for the following files are different between the two directories:\n');
        resultsEqual = false;
        
        for k=1:length(fileDiffInds)
           fprintf('%s\n',listing1(fileDiffInds(k)).name);
        end
        
        return;
    end    
    
    fileContentsEqual = false(length(listing1),1);
    
    % check for consistency between each file
    for k=1:length(listing1)
        if(verbose>0)
            fprintf('Verifying file %s, %i of %i is valid:',listing1(k).name,k,length(listing1));
        end
        
        fid1 = fopen(fullfile(source1Path,listing1(k).name),'r');
        fid2 = fopen(fullfile(source2Path,listing2(list2Inds(k)).name),'r');
        
        file1 = fread(fid1,inf,'float32');
        file2 = fread(fid2,inf,'float32');
        
        elementsAreEqual = (file1 == file2);
        
        if(elementsAreEqual)
            fprintf('true\n');
            fileContentsEqual(k) = true;
        else
            fprintf('false\n');
            fileContentsEqual(k) = false;
        end
    end
    
    if(fileContentsEqual)
        resultsEqual = true;
    else
        resultsEqual = false;
    end
    
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


