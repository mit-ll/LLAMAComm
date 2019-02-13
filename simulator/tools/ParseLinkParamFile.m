function linkStruct = ParseLinkParamFile(linkStruct)

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

global DisplayLLAMACommWarnings

% read in link parameter file
data = readTextFile(linkStruct.propParams.linkParamFile);

% Check to see if the current link is within the param file.  If it is, 
% then retrieve the appropriate parameters and update the link object

for I = 1:size(data, 1)% Look through the user-specified link parameter file
  
  if isempty(data{I, 1})     % if there is a blank line
    continue
  end
  
  if ischar(data{I, 1})
    if regexp(data{I, 1}, '^\s*%')  % if there is a comment
      continue
    end
  end
  
  % Check to see of specified link is in the linkParamFile.
  % The link must match the from and to ID's as well as the
  % receiver center frequency
  fromID = [linkStruct.fromID{1}, ':', linkStruct.fromID{2}];
  toID = [linkStruct.toID{1}, ':', linkStruct.toID{2}];
  if strcmp(fromID, data{I, 1}) ...
        && strcmp(toID, data{I, 2}) ...
        && linkStruct.toID{3} == data{I, 3}
    
    % Replace specified properties
    for J = 1:(size(data, 2) - 3)/2
      
      % Get the indices
      ind1 = 3+2*(J-1) + 1;
      ind2 = 3+2*(J-1) + 2;
      if ~isempty(data{I, ind1})
        
        % Build the struct field referencing
        %locs = [0, regexp(data{I, ind1}, '\.'), length(data{I, ind1})+1];
        %str = [];
        %for K = 1:length(locs)-1
        %  str = [str, '.(''', data{I, ind1}(locs(K)+1:locs(K+1)-1), ''')'];
        %end
        match = regexp(data{I, ind1},'[^\.]*','match');
        str = sprintf('.(''%s'')', match{:});
            
        if ischar(data{I, ind2})
          try
            eval(['linkStruct', str, ' = evalin(''base'', data{I, ind2});']);
            if DisplayLLAMACommWarnings
              fprintf('\nWarning: %s->%s:%dMHz %s is now %s\n', ...
                      fromID, toID, data{I, 3}/1e6, data{I, ind1}, data{I, ind2});
              fprintf('           Evaluated in ''base'' workspace\n');
            end 
          catch ME; %#ok
                    % In case the user wants to modify based on current settings in linkStruct
            eval(['linkStruct', str, ' = evalin(''caller'', data{I, ind2});']);
            if DisplayLLAMACommWarnings
              fprintf('\nWarning: %s->%s:%dMHz %s is now %s\n', ...
                      fromID, toID, data{I, 3}/1e6, data{I, ind1}, data{I, ind2});
              fprintf('           Evaluated in ''caller'' workspace\n');
            end
          end
          
        else
          eval(['linkStruct', str, ' = data{I, ind2};']);
          if DisplayLLAMACommWarnings
            fprintf('\nWarning: %s->%s:%dMHz %s is now %d\n', ...
                    fromID, toID, data{I, 3}/1e6, data{I, ind1}, data{I, ind2});
          end
        end
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


