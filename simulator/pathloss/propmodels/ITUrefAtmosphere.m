function [tt, pp, rho] = ITUrefAtmosphere(hh, varargin)
%
% USAGE: 
%        ITUrefAtmosphere(hh)
%        ITUrefAtmosphere(hh, latd, season)
%
% DESCRIPTION: 
%  Return atmospheric parameters using reference
%  standard atmosphere models from ITU Recommendation
%  Rec. ITU-R P.835-5, 2012. These atmospheres are 
%  annual means for the season specified.
%
% INPUTS:  
%          hh   - Height above mean sea level, in km
%          latd - Geodetic latitude, in degrees
%          season - Either 'summer' or 'winter'. 
%                   May be omitted for tropical latitudes
%
% OUTPUTS:
%          tt  - Temperature at each input height, K
%          pp  - Total air pressure (dry+wet), in hPa
%                (Note: 1 mbar == 1 hPa )
%          rho - Water-vapor density, in g/m^3
%
% Note vapor pressure = rho*tt/216.7
% Dry air pressure is pp-ee

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin>=2 % there are arguments specifying model to use

  % this allows input arguments to be passed as either a list
  % of arguments or as a single cell array, if desired. 
  % if 2nd argument is a cell array, all subsequent arguments are ignored
  if iscell(varargin{1});
    cellArgs = varargin{1};
  else
    cellArgs = varargin;
  end

  % extract input arguments from cell array, however they got passed
  latd = cellArgs{1};
  if length(cellArgs)>=2; 
    season = cellArgs{2}; % season is required if latitude exceeds 22 degrees
  else
    season = 'summer';
  end
else
  latd = [];
  season = [];
end

if ~isempty(latd) && ~isempty(season) && isnumeric(season)
  % Ad-hoc seasonal interpolation (0 = winter, 1 = summer)
  [tt0, pp0, rho0] = ITUrefAtmosphere(hh, latd, 'winter');
  [tt1, pp1, rho1] = ITUrefAtmosphere(hh, latd, 'summer');

  season = real(season(1));
  Wwinter = cos(pi*season/2).^2;  
  Wsummer = sin(pi*season/2).^2; 
  tt = tt0*Wwinter + tt1*Wsummer;
  pp = pp0*Wwinter + pp1*Wsummer;
  rho = rho0*Wwinter + rho1*Wsummer;
  return;
end

if isempty(latd)  % use reference standard atmosphere, averaged over
              % globe (and season?), Section 1.1
  
  tt = nan(size(hh));              % temperature, K
  pp = nan(size(hh));              % air pressure, hPa
  
  idx = (hh>=0 & hh<11 );
  tt(idx) = 288.15 - 6.5*hh(idx);
  pp(idx) = 1013.25 * ( 288.15 ./ tt(idx) ).^(-34.163/6.5);
  
  idx = (hh>=11 & hh<20 );
  tt(idx) = 216.65;
  pp(idx) = 226.32 * exp( -34.163*(hh(idx)-11)/216.65 );
  
  idx = (hh>=20 & hh<32 );
  tt(idx) = 216.65 + (hh(idx)-20 );
  pp(idx) = 54.75 * ( 216.65 ./ tt(idx) ).^(34.163/1.0);
  
  idx = (hh>=32 & hh<47 );
  tt(idx) = 228.65 + 2.8*(hh(idx)-32);
  pp(idx) =  8.680 * ( 228.65 ./ tt(idx) ).^(34.163/2.8);
  
  idx = (hh>=47 & hh<51 );
  tt(idx) = 270.65;
  pp(idx) = 1.1091 * exp( -34.163*(hh(idx)-47)/270.65);
  
  idx = (hh>=51 & hh<71 );
  tt(idx) = 270.65 -2.8*(hh(idx)-51);
  pp(idx) = 0.669 * ( 270.65 ./ tt(idx) ).^(-34.163/2.8);
  
  idx = (hh>=71 & hh<=85 );
  tt(idx) = 214.65 -2.0*(hh(idx)-71);
  pp(idx) = 0.0395 * ( 214.65 ./ tt(idx) ).^(-34.163/2.0);

  rho = 7.5 * exp( -hh/2 );

elseif abs(latd)<=22; % tropical region, seasons don't matter
  
  tt = nan(size(hh));
  
  idx = (hh>=0 & hh<17 );
  tt(idx) = 300.4222 - 6.3533*hh(idx) + 0.005886*hh(idx).^2;
  
  idx = (hh>=17 & hh<47 );
  tt(idx) = 194 + 2.533*(hh(idx)-17);

  idx = (hh>=47 & hh<52 );
  tt(idx) = 270;
  
  idx = (hh>=52 & hh<80 );
  tt(idx) = 270 - 3.0714*(hh(idx)-52 );
  
  idx = (hh>=80 & hh<= 100 );
  tt(idx) = 184;

  pp = nan(size(hh));

  idx = (hh>=0 & hh<10 );
  pp(idx) = 1012.0306 - 109.0338*hh(idx) + 3.6316*hh(idx).^2;
  
  idx = (hh>=10 & hh<72);
  pp(idx) =  284.8526 * exp( -0.147*(hh(idx)-10) );
  
  idx = (hh>=72 & hh<=100 );
  pp(idx) = 0.03137 * exp( -0.165*(hh(idx)-72) );
  rho = nan(size(hh));

  idx = (hh>=0 & hh<=15 );
  rho(idx) = 19.6542*exp( -0.2313*hh(idx) - 0.1122*hh(idx).^2 + ...
                          0.01351*hh(idx).^3 - 0.0005923*hh(idx).^4 );
  idx = (hh>15);
  rho(idx) = 0;

elseif abs(latd)<=45; % mid-latitudes, summer and winter models

  if strcmpi(season, 'summer')

    tt = nan(size(hh));
  
    idx = (hh>=0 & hh<13);
    tt(idx) = 294.9838 - 5.2159*hh(idx) - 0.07109*hh(idx).^2;
    
    idx = (hh>=13 & hh<17 );
    tt(idx) = 215.15;
    
    idx = (hh>=17 & hh<47);
    tt(idx) = 215.15*exp(0.008128*(hh(idx)-17));
    
    idx = (hh>=47 & hh<53 );
    tt(idx) = 275;
    
    idx = (hh>=53 & hh<80 );
    tt(idx) = 275 + 20*( 1 - exp(0.06*(hh(idx)-53)) ); % = 193 @ hh=80, not 175
    
    idx = (hh>=80 & hh<=100 );
    tt(idx) = 175;
    
    pp = nan(size(hh));
    idx = (hh>=0 & hh<10 );
    
    pp(idx) = 1012.8186 - 111.5569*hh(idx) + 3.8646*hh(idx).^2;
    idx = (hh>=10 & hh<72);
    
    pp(idx) =  283.7096 * exp( -0.147*(hh(idx)-10) );
    idx = (hh>=72 & hh<=100 );
    
    pp(idx) = 0.031240 * exp( -0.165*(hh(idx)-72) );

    rho = nan(size(hh));
    
    idx = (hh>=0 & hh<=15 );
    rho(idx) = 14.3542*exp( -0.4174*hh(idx) - 0.02290*hh(idx).^2 + ...
                            0.001007*hh(idx).^3 );
    idx = (hh>15);
    rho(idx) = 0;

  elseif strcmpi(season, 'winter')

    tt = nan(size(hh));
    
    idx = (hh>=0 & hh<10);
    tt(idx) = 272.7241 - 3.6217*hh(idx) - 0.1759*hh(idx).^2;
    
    idx = (hh>=10 & hh<33 );
    tt(idx) = 218;
    
    idx = (hh>=33 & hh<47);
    tt(idx) = 218 + 3.3571*(hh(idx)-33);
    
    idx = (hh>=47 & hh<53 );
    tt(idx) = 265;
    
    idx = (hh>=53 & hh<80 );
    tt(idx) = 265 - 2.0370*(hh(idx)-53);
    
    idx = (hh>=80 & hh<=100 );
    tt(idx) = 210;
    pp = nan(size(hh));

    idx = (hh>=0 & hh<10 );
    pp(idx) = 1018.8627 - 124.2954*hh(idx) + 4.8307*hh(idx).^2;
    
    idx = (hh>=10 & hh<72);
    pp(idx) =  258.9787 * exp( -0.147*(hh(idx)-10) );
    
    idx = (hh>=72 & hh<=100 );
    pp(idx) = 0.0285170 * exp( -0.155*(hh(idx)-72) );

    rho = nan(size(hh));

    idx = (hh>=0 & hh<=10 );
    rho(idx) = 3.4742*exp( -0.2697*hh(idx) - 0.03604*hh(idx).^2 + ...
                           0.0004489*hh(idx).^3 );
    idx = (hh>10);
    rho(idx) = 0;

  else % oops
    error(['Argument SEASON, unknown value: ' season ]);
  end

elseif abs(latd)<=90  % high latitudes

  if strcmpi(season, 'summer')

    tt = nan(size(hh));

    idx = (hh>=0 & hh<10);
    tt(idx) = 286.8374 - 4.7805*hh(idx) - 0.1402*hh(idx).^2;

    idx = (hh>=10 & hh<23 );
    tt(idx) = 225;

    idx = (hh>=23 & hh<48);
    tt(idx) = 225*exp(0.008317*(hh(idx)-23));

    idx = (hh>=48 & hh<53 );
    tt(idx) = 277;

    idx = (hh>=53 & hh<79 );
    tt(idx) = 277 - 4.0769*(hh(idx)-53);

    idx = (hh>=79 & hh<=100 );
    tt(idx) = 171;

    pp = nan(size(hh));

    idx = (hh>=0 & hh<10 );
    pp(idx) = 1008.0278 - 113.2494*hh(idx) + 3.9408*hh(idx).^2;

    idx = (hh>=10 & hh<72);
    pp(idx) =  269.6138 * exp( -0.140*(hh(idx)-10) );

    idx = (hh>=72 & hh<=100 );
    pp(idx) = 0.045821 * exp( -0.165*(hh(idx)-72) );

    rho = nan(size(hh));

    idx = (hh>=0 & hh<=15 );
    rho(idx) = 8.988*exp( -0.3614*hh(idx) - 0.005402*hh(idx).^2 - ...
                          0.001955*hh(idx).^3 );
    idx = (hh>15);
    rho(idx) = 0;

  elseif strcmpi(season, 'winter')

    tt = nan(size(hh));

    idx = (hh>=0 & hh<8.5);
    tt(idx) = 257.4345 + 2.3473*hh(idx) - 1.5479*hh(idx).^2 + ...
              0.08473*hh(idx).^3;

    idx = (hh>=8.5 & hh<30 );
    tt(idx) = 217.5;
    
    idx = (hh>=30 & hh<50);
    tt(idx) = 217.5 + 2.125*(hh(idx)-30);
    
    idx = (hh>=50 & hh<54 );
    tt(idx) = 260;
    
    idx = (hh>=54 & hh<=100 );
    tt(idx) = 260 - 1.667*(hh(idx)-54);
    
    pp = nan(size(hh));
    
    idx = (hh>=0 & hh<10 );
    pp(idx) = 1010.8828 - 122.2411*hh(idx) + 4.554*hh(idx).^2;
    
    idx = (hh>=10 & hh<72);
    pp(idx) =  243.8718 * exp( -0.147*(hh(idx)-10) );
    
    idx = (hh>=72 & hh<=100 );
    pp(idx) = 0.0268535 * exp( -0.150*(hh(idx)-72) );
    
    rho = nan(size(hh));
    
    idx = (hh>=0 & hh<=10 );
    rho(idx) = 1.2319*exp( 0.07481*hh(idx) - 0.0981*hh(idx).^2 + ...
                           0.00281*hh(idx).^3 );
    idx = (hh>10);
    rho(idx) = 0;

  else % oops
    error(['Argument SEASON unknown value: ', season ]);
  end

else 
  error(['Argmument latitude outside range. Latitude = ', num2str(latd) ]);
end

% Outside the atmisphere
tt(hh>85) = 4.7;  % Anything >0
pp(hh>85) = 0;
rho(hh>85) = 0;


% get water-vapor partial pressure
%ee = rho .* tt / 216.7;

% Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
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

