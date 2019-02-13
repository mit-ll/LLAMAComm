function [nodes, env, status] = RunArbitrator(nodes, env)

% Function sim/RunArbitrator.m: 
% Processes requests to transmit and receive (and wait) for all modules 
% for each node.
%
% USAGE: [nodes, status] = RunArbitrator(nodes)
%
% Input arguments:
%  nodes    (1xN node array) Array of all node objects in simulation
%  env      (environment obj) Environment object (contains evironmental
%            parameters and link objects)
%
% Output arguments:
%  nodes    (1xN node array) Modified copies of all node objects
%  env      (environment obj) Modified copy of environment object
%  status   (string) Arbitrator status.  Possible values are:
%             'idle'    - No module requesting action
%             'running' - At least one request was satisfied
%             'stalled' - Modules requesting, but cannot be satisifed.
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

global timingDiagramFig;

persistent allowTxSkipping
if isempty(allowTxSkipping)
  allowTxSkipping = true;
end

% Flag controlling display of debugging information
debug = false;

% Default status (in case there are no requests)
status = 'idle';

% Initialize some bookkeeping quantities
rxStartSamp = Inf;
rxEndSamp = -Inf;
numRxJobs = 0;
numRxJobsComplete = 0;
numTxJobs = 0;
numWaiting = 0;
numCriticalJobs = 0;
numTDUpdates = 0;

% Process wait and receieve jobs for all modules in all nodes
for nodeidx = 1:length(nodes)
  nodeIsCritical = double(IsCritical(nodes(nodeidx)));
  for modidx = 1:length(nodes(nodeidx).modules)
    
    % Process modules with outstanding requests
    req = GetRequest(nodes(nodeidx).modules(modidx));
    if req.requestFlag
      
      % Outstanding request found, change status to 'stalled'
      % until at least one request is satisfied.
      if strcmp(status, 'idle')
        status = 'stalled';
      end
      
     
      switch req.job       
        case 'transmit'
          numCriticalJobs = numCriticalJobs + nodeIsCritical;
          % Handled below
        
        case 'wait'
          numWaiting = numWaiting + 1;
          numCriticalJobs = numCriticalJobs + nodeIsCritical;
          if debug
            1; %#ok if this line is unreachable
            nodeName = GetNodeName(nodes(nodeidx));
            fprintf(1, '%d  %d   %-15s   %d  %-15s  %-8d %-8d\n', ...
                    nodeidx, modidx, ...
                    nodeName, req.requestFlag, ...
                    req.job, ...
                    req.blockStart, ...
                    req.blockStart+req.blockLength-1); 
          end
            

          % No processing needed for wait, mark as complete
          nodes(nodeidx).modules(modidx) = ...
              RequestDone(nodes(nodeidx).modules(modidx));

          if timingDiagramFig
            UpdateTimingDiagram(nodes(nodeidx).modules(modidx), ...
                                nodes(nodeidx), nodeidx, modidx, false);
            numTDUpdates = numTDUpdates + 1;
          end
          status = 'running';
          
        case 'receive'
          numCriticalJobs = numCriticalJobs + nodeIsCritical;
          if debug
            1; %#ok if this line is unreachable
            nodeName = GetNodeName(nodes(nodeidx));
            fprintf(1, '%d  %d   %-15s   %d  %-15s  %-8d %-8d\n', ...
                    nodeidx, modidx, ...
                    nodeName, req.requestFlag, ...
                    req.job, ...
                    req.blockStart, ...
                    req.blockStart+req.blockLength-1); 
          end

          % Make sure the module is a receiver
          modType = GetType(nodes(nodeidx).modules(modidx));
          if ~strcmp('receiver', modType)
            error(['\n%s:%s was initialized as a '...
                   '''%s'' module, \nbut was sent a '...
                   '''receive'' job.  Either change'...
                   ' the module type\nto ''receiver''', ...
                   ' or have the controller request', ...
                   ' a different job.'], ...
                  GetNodeName(nodes(nodeidx)), ...
                  GetModuleName(nodes(nodeidx).modules(modidx)), ...
                  modType);            
          end                    

          numRxJobs = numRxJobs + 1;
          if ~isempty(req.blockStart)
            rxStartSamp = min(rxStartSamp, req.blockStart);
          end
          reqBlockEnd = req.blockStart + req.blockLength-1;
          if ~isempty(reqBlockEnd)
            rxEndSamp = max(rxEndSamp, reqBlockEnd);
          end

          if IsGenie(nodes(nodeidx).modules(modidx))
            % Handle special genie receive

            % Check if there is anything in the receive queue
            queueSize = ...
                CheckGenieQueue(nodes(nodeidx).modules(modidx));
            
            % Mark as done if receive queue not empty
            if queueSize~=0
              nodes(nodeidx).modules(modidx) = ...
                  GenieReceiveDone(nodes(nodeidx).modules(modidx));

              status = 'running';
            end
            
          else                        
            % Ordinary receive request
            
            % Query all other modules to check if signal that would
            % be present in this receive block is available
            [complete, relevant] = ...
                QueryModulesFTXDWE(nodes, nodeidx, modidx);

            % If all receive data is available
            if complete
              numRxJobsComplete = numRxJobsComplete + 1;
              % Combine relevant signals to create "analog"
              % received signal
              [nodes, env, sig] = CombineRxSignals(nodes, env, ...
                                                 nodeidx, modidx, relevant);
              
              % Store received signal
              [nodes(nodeidx).modules(modidx), fPtr] = ...
                  StoreSignal(sig, nodes(nodeidx).modules(modidx), ...
                              nodes(nodeidx).name);

              % Call user-specified receive callback function
              callback = GetCallback(nodes(nodeidx).modules(modidx));
              modname = GetModuleName(nodes(nodeidx).modules(modidx));
              nodes(nodeidx)= callback(nodes(nodeidx), modname, sig);

              % Signal that RX request is done
              nodes(nodeidx).modules(modidx) = ...
                  RequestDone(nodes(nodeidx).modules(modidx), fPtr);

              if timingDiagramFig
                UpdateTimingDiagram(nodes(nodeidx).modules(modidx), ...
                                    nodes(nodeidx), nodeidx, modidx, false);
                numTDUpdates = numTDUpdates + 1;
              end

              status = 'running';
            end

          end
          
        otherwise
          error('Don''t know how to handle job ''%s''', req.job);
      end
    end
  end
end

% Process transmit jobs for all modules in all nodes
for nodeidx = 1:length(nodes)
  for modidx = 1:length(nodes(nodeidx).modules)

    % Process modules with outstanding requests
    req = GetRequest(nodes(nodeidx).modules(modidx));
    if req.requestFlag
      
      % Outstanding request found, change status to 'stalled'
      % until at least one request is satisfied.
      if strcmp(status, 'idle')
        status = 'stalled';
      end
           
      switch req.job                
        case 'transmit'
          if debug
            1; %#ok if this line is unreachable
            nodeName = GetNodeName(nodes(nodeidx));
            fprintf(1, '%d  %d   %-15s   %d  %-15s  %-8d %-8d\n', ...
                    nodeidx, modidx, ...
                    nodeName, req.requestFlag, ...
                    req.job, ...
                    req.blockStart, ...
                    req.blockStart+req.blockLength-1); 
          end

          
          % Make sure the module is a transmitter
          modType = GetType(nodes(nodeidx).modules(modidx));
          if ~strcmp('transmitter', modType)
            error(['\n%s:%s was initialized as a '...
                   '''%s'' module, \nbut was sent a '...
                   '''transmit'' job.  Either change'...
                   ' the module type\nto ''transmitter''', ...
                   ' or have the controller request', ...
                   ' a different job.'], ...
                  GetNodeName(nodes(nodeidx)), ...
                  GetModuleName(nodes(nodeidx).modules(modidx)), ...
                  modType);
          end 

          numTxJobs = numTxJobs + 1;
          if IsGenie(nodes(nodeidx).modules(modidx))
            % Handle special genie transmit

            % Find indices of "to" module
            modobj = nodes(nodeidx).modules(modidx);
            [toNodeName, toModName] = GetToAddr(modobj);

            if ischar(toNodeName) && ischar(toModName)
              [toNode, toNodeIdx] = FindNode(nodes, toNodeName);
              [toMod, toModIdx] = FindModule(toNode.modules, toModName); %#ok tMod unused

              % Move data from tx genie mod to rx genie mod, also
              % sets request flags accordingly
              [nodes(nodeidx).modules(modidx), ...
               nodes(toNodeIdx).modules(toModIdx)] = ...
                  GenieTransmit(nodes(nodeidx).modules(modidx), ...
                                nodes(toNodeIdx).modules(toModIdx));
            elseif iscell(toNodeName) && iscell(toModName)

              % Multicast genie
              nTarg = numel(toNodeName);
              
              for mmIdx = 1:nTarg
                [toNode, toNodeIdx] = FindNode(nodes, toNodeName{mmIdx});
                [toMod, toModIdx] = FindModule(toNode.modules, toModName{mmIdx}); %#ok tMod unused
                
                % Move data from tx genie mod to rx genie mod, also
                % sets request flags accordingly
                [nodes(nodeidx).modules(modidx), ...
                 nodes(toNodeIdx).modules(toModIdx)] = ...
                    GenieTransmit(nodes(nodeidx).modules(modidx), ...
                                  nodes(toNodeIdx).modules(toModIdx)); 
              end
              
            else
              error('Unable to handle (%s, %s) class genie transmit', class(toNodeName), class(toModName));
            end
            
          else
            % Ordinary transmit request
            
            if allowTxSkipping && (numRxJobs > 0) && (req.blockStart > rxEndSamp) 
              % Postpone this request
              if debug 
                1; %#ok if this line is unreachable
                fprintf(1, 'Skipped. [ %d  %d ] not in [ %d  %d ]\n', ...
                        req.blockStart, req.blockStart+req.blockLength-1, rxStartSamp, rxEndSamp);
              end
              if strcmp(status, 'idle')
                status = 'running';
              end          
              continue;            
            end
            
            % Call user-specified transmit callback function
            callback = GetCallback(nodes(nodeidx).modules(modidx));
            modname = GetModuleName(nodes(nodeidx).modules(modidx));
            [nodes(nodeidx), sig] = callback(nodes(nodeidx), modname, ...
                                            req.blockLength);
            
            % Error Checking
            nTx = GetNumModAnts(nodes(nodeidx), modname);
            if length(size(sig))>2
              error('ERROR in %s-%s calling: %s.m ...\n    Output signal dimension = %i is greater than two!', ...
                    GetNodeName(nodes(nodeidx)), modname, ...
                    func2str(callback), length(size(sig)));
            end
            if size(sig, 1)~= nTx || size(sig, 2)~= req.blockLength
              error('ERROR in %s-%s calling: %s.m ...\n    Size of output signal = [%i, %i] does not match [nAnts, blockLen] = [%i, %i]', ...
                    GetNodeName(nodes(nodeidx)), modname, ...
                    func2str(callback), size(sig, 1), ...
                    size(sig, 2), nTx, req.blockLength);
            end

            % Store transmitted signal
            [nodes(nodeidx).modules(modidx), fPtr] = ...
                StoreSignal(sig, nodes(nodeidx).modules(modidx), ...
                            nodes(nodeidx).name);

            % Signal that TX request is done
            nodes(nodeidx).modules(modidx) = ...
                RequestDone(nodes(nodeidx).modules(modidx), fPtr);


            if timingDiagramFig
              UpdateTimingDiagram(nodes(nodeidx).modules(modidx), ...
                                  nodes(nodeidx), nodeidx, modidx, false);
              numTDUpdates = numTDUpdates + 1;
            end
          end
          status = 'running';
                
      end %END switch      
    end
  end
end

if numTDUpdates>0
  UpdateTimingDiagram(module); % Flush graphics buffer
end


if debug
  1; %#ok if this is line is unreachable
  fprintf('#Rx: %d   #Rx complete: %d   #Tx: %d \n\n', numRxJobs, numRxJobsComplete, numTxJobs);
end

if (numRxJobsComplete ==0 ) && ( numTxJobs == 0 ) && (numWaiting == 0)
  allowTxSkipping = false;
else
  allowTxSkipping = true;
end

% Check if only non-critical nodes remain
if numCriticalJobs == 0
  nonCritical = ~IsCritical(nodes);
  if sum(nonCritical) > 0
    % Nothing important is happening. Stop non-critical nodes
    nodes(nonCritical) = ShutdownNode(nodes(nonCritical));
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


