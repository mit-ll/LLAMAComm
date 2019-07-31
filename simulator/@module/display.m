function display(m)

% MODULE class display function

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

if ~isempty(inputname(1))
  fprintf(1, '\n%s = \n\n', inputname(1));
end

if isempty(m)
  fprintf(1, ' %dx%d module matrix\n', size(m));
elseif length(m) > 1
  % Display for array/matrix of modules
  fprintf(1, ' %dx%d module matrix with names:\n', size(m));
  for r=1:size(m, 1)
    fprintf(1, '  ''%s''', m(r, :).name);
    fprintf(1, '\n');
  end
  fprintf(1, '\n');

elseif m.isGenie
  % Display special genie module info
  fprintf(1, '                 *Genie module*\n\n');
  fprintf(1, '             name: %s\n', m.name);
  fprintf(1, '             type: %s\n', m.type);
  fprintf(1, '\n                 Request\n');
  fprintf(1, '              job: ''%s''\n', m.job);
  fprintf(1, '      requestFlag: %d\n', m.requestFlag);
  fprintf(1, '  genieToNodeName: ''%s''\n', m.genieToNodeName);
  fprintf(1, '   genieToModName: ''%s''\n', m.genieToModName);
  fprintf(1, '\n');
  fprintf(1, '\n                 Contents of Genie Queue\n');
  if ~isempty(m.genieQueue)
    for k=1:length(m.genieQueue)
      fprintf(1, '   Item %d:\n', k);
      display(m.genieQueue{k});
    end
  else
    fprintf(1, '                  -empty-\n\n');
  end

else
  % Display normal module info
  fprintf(1, '             name: %s\n', m.name);
  fprintf(1, '               fc: %s Hz\n', num2str(m.fc));
  fprintf(1, '               fs: %s Hz\n', num2str(m.fs));
  fprintf(1, '             type: %s\n', m.type);
  if isempty(m.callbackFcn)
    fprintf(1, '      callbackFcn: []\n');
  else
    finfo = functions(m.callbackFcn);
    fprintf(1, '      callbackFcn: @%s\n', finfo.function);
  end
  fprintf(1, '          loError: %s parts\n', num2str(m.loError));
  fprintf(1, '     loCorrection: %s parts\n', num2str(m.loCorrection));
  if isempty(m.noiseFigure)
    % Do nothing
  else
    fprintf(1, '          noiseFigure: % 8.2f (dB)\n', m.noiseFigure);
  end
  if isempty(m.antType)
    fprintf(1, '          antType: {}\n');
  else
    fprintf(1, '          antType: %s\n', m.antType{1});
    for k=2:length(m.antType)
      fprintf(1, '                   %s\n', m.antType{k});
    end
  end
  fprintf(1, '      antPosition: ');
  if ~isempty(m.antPosition)
    fprintf(1, '% 8.2f ', m.antPosition(1, :));
    for r=2:size(m.antPosition, 1)
      fprintf(1, '\n                   ');
      fprintf(1, '% 8.2f ', m.antPosition(r, :));
    end
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  if isempty(m.antPolarization)
    fprintf(1, '  antPolarization: {}\n');
  else
    fprintf(1, '  antPolarization: %s\n', m.antPolarization{1});
    for k=2:length(m.antPolarization)
      fprintf(1, '                   %s\n', m.antPolarization{k});
    end
  end
  fprintf(1, '       antAzimuth: ');
  if ~isempty(m.antAzimuth)
    fprintf(1, '% 8.2f ', m.antAzimuth(1, :));
    for r=2:size(m.antAzimuth, 1)
      fprintf(1, '\n                   ');
      fprintf(1, '% 8.2f ', m.antAzimuth(r, :));
    end
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  fprintf(1, '     antElevation: ');
  if ~isempty(m.antElevation)
    fprintf(1, '% 8.2f ', m.antElevation(1, :));
    for r=1:size(m.antElevation, 1)
      fprintf(1, '\n                   ');
      fprintf(1, '% 8.2f ', m.antElevation(r, :));
    end
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  fprintf(1, '     exteriorWallMaterial: ');
  if ~isempty(m.exteriorWallMaterial)
    fprintf(1, '% s ', m.exteriorWallMaterial);
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  fprintf(1, '     distToExteriorWall: ');
  if ~isempty(m.distToExteriorWall)
    fprintf(1, '% 8.2f ', m.distToExteriorWall);
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  fprintf(1, '     exteriorBldgAngle: ');
  if ~isempty(m.exteriorBldgAngle)
    fprintf(1, '% 8.2f ', m.exteriorBldgAngle);
    fprintf(1, '\n');
  else
    fprintf(1, '[]\n');
  end
  fprintf(1, '\n                 Request\n');
  fprintf(1, '              job: ''%s''\n', m.job);
  fprintf(1, '      requestFlag: %d\n', m.requestFlag);
  fprintf(1, '      blockLength: %s\n', num2str(m.blockLength));
  fprintf(1, '       blockStart: %d\n', m.blockStart);

  fprintf(1, '\n                 History\n');
  for k=1:length(m.history)
    if k==1
      fprintf(1, '     Start    Length         Job      fc (MHz)      fs (MHz)      fPtr\n');
    end
    fprintf(1, '  % 8d  % 8d  % 10s  % 12.6f  % 12.6f  % 8d\n', ...
            m.history{k}.start, m.history{k}.blockLength, m.history{k}.job, ...
            m.history{k}.fc/1e6, m.history{k}.fs/1e6, m.history{k}.fPtr);
  end

  fprintf(1, '\n');
  fprintf(1, '\n                 Save file info\n');
  fprintf(1, '         filename: ''%s''\n', m.filename);
  fprintf(1, '              fid: %s\n', num2str(m.fid));
  fprintf(1, '\n\n');
end


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


