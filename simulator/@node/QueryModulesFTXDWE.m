function [complete, relevant] = QueryModulesFTXDWE(nodes, selfnodeidx, selfmodidx)

% Function @node/QueryModulesFTXDWE.m:
% (Query Modules for Transmit Data With Exceptions)
% This function is used when a particular module wants to receive.
% Given an array of node objects, this function queries all modules
% other than the specified one (specified by node and module index)
% for transmit data in a particular sample range.  The query is "complete"
% if all modules that are transmitting in the same band has analog signal
% computed for the requested time period.
%
% USAGE: [complete, relevant] = ...
%          QueryModulesFTXDWE(nodes, selfnodeidx, selfmodidx)
%
% Input arguments:
%  nodes         (node obj array) Array of all node objects in the simulation
%  selfnodeidx   (int) Index of the node requesting to receive
%  selfmodidx    (int) Index of the module within the node that is receiving
%
% Output arguments:
%  complete      (bool) true (1) if all relevant data is ready, 0 otherwise
%  relevant      (cell array) Cell array of structs containing node
%                 index and module index for modules that are transmitting
%                 during the requested time.  (Not valid if not complete)
%                 Contains fields:
%   .nodeidx       (int) Node index
%   .modidx        (int) Module index
%   .histidx       (1xB int) History indices of relevant blocks
%

%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


% Default outputs
complete = 1;

% Recall request
req = GetRequest(nodes(selfnodeidx).modules(selfmodidx));
startIdx = req.blockStart;
stopIdx = startIdx+req.blockLength-1;

% Count of modules with available transmit data
rcount = 0;

% Initialize
relevant = cell(1, numel([nodes(:).modules]));

% Search all other modules
for nodeidx = 1:length(nodes)
  for modidx = 1:length(nodes(nodeidx).modules)

    % Exclude self module
    if (nodeidx==selfnodeidx) && (modidx==selfmodidx)
      continue;
    end

    % Skip genie modules
    if IsGenie(nodes(nodeidx).modules(modidx))
      continue;
    end

    % Check if data is available
    [response, histidx] = CheckHistory(nodes(nodeidx).modules(modidx), ...
                                      startIdx, stopIdx, req.fc, req.fs);

    switch response
      case 'data_available'
        % Store results in cell array
        rcount = rcount + 1;
        rstruct.nodeidx = nodeidx;
        rstruct.modidx = modidx;
        rstruct.histidx = histidx;
        relevant{rcount} = rstruct;

      case 'not_transmitting_inband'
        % Just skip

      case 'not_ready'
        % Flag as incomplete and return
        complete = 0;
        relevant = relevant(1:rcount);
        return;

      otherwise
        error('Unknown response.');
    end

  end
end

relevant = relevant(1:rcount);


%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation;
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


