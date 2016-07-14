function gamma = ITUspecificAtten(f, T, p, rho)
%
% USAGE: gamma = ITUspecificAtten(f, T, p, rho)
%
% DESCRIPTION:
%  Returns the specific attenuation of the atmosphere given the frequency
% and the gas parameters. Based on the ITU Recommendation Rec. ITU-R P.676-10
% (2013)
%
% Input arguments:
%
%   f   - Frequency (in GHz). Must be in the range 0 <= f <=1000
%   T   - Atmosphereic tempurature (in Kelvin. Typical value 300 K)
%   p   - Total Pressure (dry+wet), in hPa. (Note: Typical vale 1013 hPa )
%         (Note: 1 mbar == 1 hPa )
%   rho - Water vapor density (in g/cm^3. Typical value 7.5 g/cm^3)
%
% Output arguments:
%
%  gamma - Specific attenuation of the atmosphere (in dB/km)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% f in GHz
% T in Kelvin
% p in hPa
% rho in g/m3

% ITU--R P.676-3 (1997):
% data_o2 = [50.474238,    0.94,  9.694,  8.60,   0,  1.600,  5.520; ...
%           50.987749,    2.46,  8.694,  8.70,   0,  1.400,  5.520; ...
%           51.503350,    6.08,  7.744,  8.90,   0,  1.165,  5.520; ...
%           52.021410,   14.14,  6.844,  9.20,   0,  0.883,  5.520; ...
%           52.542394,   31.02,  6.004,  9.40,   0,  0.579,  5.520; ...
%           53.066907,   64.10,  5.224,  9.70,   0,  0.252,  5.520; ...
%           53.595749,  124.70,  4.484, 10.00,   0, -0.066,  5.520; ...
%           54.130000,  228.00,  3.814, 10.20,   0, -0.314,  5.520; ...
%           54.671159,  391.80,  3.194, 10.50,   0, -0.706,  5.520; ...
%           55.221367,  631.60,  2.624, 10.79,   0, -1.151,  5.514; ...
%           55.783802,  953.50,  2.119, 11.10,   0, -0.920,  5.025; ...
%           56.264775,  548.90,  0.015, 16.46,   0,  2.881, -0.069; ...
%           56.363389, 1344.00, 1.660,  11.44,   0, -0.596,  4.750; ...
%           56.968206, 1763.00, 1.260,  11.81,   0, -0.556,  4.104; ...
%           57.612484, 2141.00, 0.915,  12.21,   0, -2.414,  3.536; ...
%           58.323877, 2386.00, 0.626,  12.66,   0, -2.635,  2.686; ...
%           58.446590, 1457.00, 0.084,  14.49,   0,  6.848, -0.647; ...
%           59.164207, 2404.00, 0.391,  13.19,   0, -6.032,  1.858; ...
%           59.590983, 2112.00, 0.212,  13.60,   0,  8.266, -1.413; ...
%           60.306061, 2124.00, 0.212,  13.82,   0, -7.170,  0.916; ...
%           60.434776, 2461.00, 0.391,  12.97,   0,  5.664, -2.323; ...
%           61.150560, 2504.00, 0.626,  12.48,   0,  1.731, -3.039; ...
%           61.800154, 2298.00, 0.915,  12.07,   0,  1.738, -3.797; ...
%           62.411215, 1933.00, 1.260,  11.71,   0, -0.048, -4.277; ...
%           62.486260, 1517.00, 0.083,  14.68,   0, -4.290,  0.238; ...
%           62.997977, 1503.00, 1.665,  11.39,   0,  0.134, -4.860; ...
%           63.568518, 1087.00, 2.115,  11.08,   0,  0.541, -5.079; ...
%           64.127767,  733.50, 2.620,  10.78,   0,  0.814, -5.525; ...
%           64.678903,  463.50, 3.195,  10.50,   0,  0.415, -5.520; ...
%           65.224071,  274.80, 3.815,  10.20,   0,  0.069, -5.520; ...
%           65.764772,  153.00, 4.485,  10.00,   0, -0.143, -5.520; ...
%           66.302091,   80.09, 5.225,   9.70,   0, -0.428, -5.520; ...
%           66.836830,   39.46, 6.005,   9.40,   0, -0.726, -5.520; ...
%           67.369598,   18.32, 6.845,   9.20,   0, -1.002, -5.520; ...
%           67.900867,    8.01, 7.745,   8.90,   0, -1.255, -5.520; ...
%           68.431005,    3.30, 8.695,   8.70,   0, -1.500, -5.520; ...
%           68.960311,    1.28, 9.695,   8.60,   0, -1.700, -5.520; ...
%           118.750343, 945.00, 0.009,  16.30,   0, -0.247,  0.003; ...
%           368.498350,  67.90, 0.049,  19.20, 0.6,      0,      0; ...
%           424.763124, 638.00, 0.044,  19.16, 0.6,      0,      0; ...
%           487.249370, 235.00, 0.049,  19.20, 0.6,      0,      0; ...
%           715.393150,  99.60, 0.145,  18.10, 0.6,      0,      0; ...
%           773.839675, 671.00, 0.130,  18.10, 0.6,      0,      0; ...
%           834.145330, 180.00, 0.147,  18.10, 0.6,      0,      0];
% data_h2o=[ 22.235080,   0.1090, 2.143, 28.11, 0.69, 4.80, 1.00; ...
%           67.813960,   0.0011, 8.735, 28.58, 0.69, 4.93, 0.82; ...
%          119.995941,   0.0007, 8.356, 29.48, 0.70, 4.78, 0.79; ...
%          183.310074,   2.3000, 0.668, 28.13, 0.64, 5.30, 0.85; ...
%          321.225644,   0.0464, 6.181, 23.03, 0.67, 4.69, 0.54; ...
%          325.152919,   1.5400, 1.540, 27.83, 0.68, 4.85, 0.74; ...
%          336.187000,   0.0010, 9.829, 26.93, 0.69, 4.74, 0.61; ...
%          380.197372,  11.9000, 1.048, 28.73, 0.69, 5.38, 0.84; ...
%          390.134508,   0.0044, 7.350, 21.52, 0.63, 4.81, 0.55; ...
%          437.346667,   0.0637, 5.050, 18.45, 0.60, 4.23, 0.48; ...
%          439.150812,   0.9210, 3.596, 21.00, 0.63, 4.29, 0.52; ...
%          443.018295,   0.1940, 5.050, 18.60, 0.60, 4.23, 0.50; ...
%          448.001075,  10.6000, 1.405, 26.32, 0.66, 4.84, 0.67; ...
%          470.888947,   0.3300, 3.599, 21.52, 0.66, 4.57, 0.65; ...
%          474.689127,   1.2800, 2.381, 23.55, 0.65, 4.65, 0.64; ...
%          488.491133,   0.2530, 2.853, 26.02, 0.69, 5.04, 0.72; ...
%          503.568532,   0.0374, 6.733, 16.12, 0.61, 3.98, 0.43; ...
%          504.482692,   0.0125, 6.733, 16.12, 0.61, 4.01, 0.45; ...
%          556.936002, 510.0000, 0.159, 32.10, 0.69, 4.11, 1.00; ...
%          620.700807,   5.0900, 2.200, 24.38, 0.71, 4.68, 0.68; ...
%          658.006500,   0.2740, 7.820, 32.10, 0.69, 4.14, 1.00; ...
%          752.033227, 250.0000, 0.396, 30.60, 0.68, 4.09, 0.84; ...
%          841.073593,   0.0130, 8.180, 15.90, 0.33, 5.76, 0.45; ...
%          859.865000,   0.1330, 7.989, 30.60, 0.68, 4.09, 0.84; ...
%          899.407000,   0.0550, 7.917, 29.85, 0.68, 4.53, 0.90; ...
%          902.555000,   0.0380, 8.432, 28.65, 0.70, 5.10, 0.95; ...
%          906.205524,   0.1830, 5.111, 24.08, 0.70, 4.70, 0.53; ...
%          916.171582,   8.5600, 1.442, 26.70, 0.70, 4.78, 0.78; ...
%          970.315022,   9.1600, 1.920, 25.50, 0.64, 4.94, 0.67; ...
%          987.926764, 138.0000, 0.258, 29.85, 0.68, 4.55, 0.90];


% ITU--R P.676-10 (09/2013):
data_o2 = [50.474214,    0.975, 9.651,  6.690, 0.0,  2.566,  6.850; ...
          50.987745,    2.529, 8.653,  7.170, 0.0,  2.246,  6.800; ...
          51.503360,    6.193, 7.709,  7.640, 0.0,  1.947,  6.729; ...
          52.021429,   14.320, 6.819,  8.110, 0.0,  1.667,  6.640; ...
          52.542418,   31.240, 5.983,  8.580, 0.0,  1.388,  6.526; ...
          53.066934,   64.290, 5.201,  9.060, 0.0,  1.349,  6.206; ...
          53.595775,  124.600, 4.474,  9.550, 0.0,  2.227,  5.085; ...
          54.130025,  227.300, 3.800,  9.960, 0.0,  3.170,  3.750; ...
          54.671180,  389.700, 3.182, 10.370, 0.0,  3.558,  2.654; ...
          55.221384,  627.100, 2.618, 10.890, 0.0,  2.560,  2.952; ...
          55.783815,  945.300, 2.109, 11.340, 0.0, -1.172,  6.135; ...
          56.264774,  543.400, 0.014, 17.030, 0.0,  3.525, -0.978; ...
          56.363399, 1331.800, 1.654, 11.890, 0.0, -2.378,  6.547; ...
          56.968211, 1746.600, 1.255, 12.230, 0.0, -3.545,  6.451; ...
          57.612486, 2120.100, 0.910, 12.620, 0.0, -5.416,  6.056; ...
          58.323877, 2363.700, 0.621, 12.950, 0.0, -1.932,  0.436; ...
          58.446588, 1442.100, 0.083, 14.910, 0.0,  6.768, -1.273; ...
          59.164204, 2379.900, 0.387, 13.530, 0.0, -6.561,  2.309; ...
          59.590983, 2090.700, 0.207, 14.080, 0.0,  6.957, -0.776; ...
          60.306056, 2103.400, 0.207, 14.150, 0.0, -6.395,  0.699; ...
          60.434778, 2438.000, 0.386, 13.390, 0.0,  6.342, -2.825; ...
          61.150562, 2479.500, 0.621, 12.920, 0.0,  1.014, -0.584; ...
          61.800158, 2275.900, 0.910, 12.630, 0.0,  5.014, -6.619; ...
          62.411220, 1915.400, 1.255, 12.170, 0.0,  3.029, -6.759; ...
          62.486253, 1503.000, 0.083, 15.130, 0.0, -4.499,  0.844; ...
          62.997984, 1490.200, 1.654, 11.740, 0.0,  1.856, -6.675; ...
          63.568526, 1078.000, 2.108, 11.340, 0.0,  0.658, -6.139; ...
          64.127775,  728.700, 2.617, 10.880, 0.0, -3.036, -2.895; ...
          64.678910,  461.300, 3.181, 10.380, 0.0, -3.968, -2.590; ...
          65.224078,  274.000, 3.800,  9.960, 0.0, -3.528, -3.680; ...
          65.764779,  153.000, 4.473,  9.550, 0.0, -2.548, -5.002; ...
          66.302096,   80.400, 5.200,  9.060, 0.0, -1.660, -6.091; ...
          66.836834,   39.800, 5.982,  8.580, 0.0, -1.680, -6.393; ...
          67.369601,   18.560, 6.818,  8.110, 0.0, -1.956, -6.475; ...
          67.900868,    8.172, 7.708,  7.640, 0.0, -2.216, -6.545; ...
          68.431006,    3.397, 8.652,  7.170, 0.0, -2.492, -6.600; ...
          68.960312,    1.334, 9.650,  6.690, 0.0, -2.773, -6.650; ...
          118.750334,  940.300, 0.010, 16.640, 0.0, -0.439,  0.079; ...
          368.498246,   67.400, 0.048, 16.400, 0.0,  0.000,  0.000; ...
          424.763020,  637.700, 0.044, 16.400, 0.0,  0.000,  0.000; ...
          487.249273,  237.400, 0.049, 16.000, 0.0,  0.000,  0.000; ...
          715.392902,   98.100, 0.145, 16.000, 0.0,  0.000,  0.000; ...
          773.839490,  572.300, 0.141, 16.200, 0.0,  0.000,  0.000; ...
          834.145546,  183.100, 0.145, 14.700, 0.0,  0.000,  0.000];

data_h2o = [22.235080, 0.1130, 2.143, 28.11, .69, 4.800, 1.00; ...
           67.803960, 0.0012, 8.735, 28.58, .69, 4.930, .82; ...
           119.995940, 0.0008, 8.356, 29.48, .70, 4.780, .79; ...
           183.310091, 2.4200, .668, 30.50, .64, 5.300, .85; ...
           321.225644, 0.0483, 6.181, 23.03, .67, 4.690, .54; ...
           325.152919, 1.4990, 1.540, 27.83, .68, 4.850, .74; ...
           336.222601, 0.0011, 9.829, 26.93, .69, 4.740, .61; ...
           380.197372, 11.5200, 1.048, 28.73, .54, 5.380, .89; ...
           390.134508, 0.0046, 7.350, 21.52, .63, 4.810, .55; ...
           437.346667, 0.0650, 5.050, 18.45, .60, 4.230, .48; ...
           439.150812, 0.9218, 3.596, 21.00, .63, 4.290, .52; ...
           443.018295, 0.1976, 5.050, 18.60, .60, 4.230, .50; ...
           448.001075, 10.3200, 1.405, 26.32, .66, 4.840, .67; ...
           470.888947, 0.3297, 3.599, 21.52, .66, 4.570, .65; ...
           474.689127, 1.2620, 2.381, 23.55, .65, 4.650, .64; ...
           488.491133, 0.2520, 2.853, 26.02, .69, 5.040, .72; ...
           503.568532, 0.0390, 6.733, 16.12, .61, 3.980, .43; ...
           504.482692, 0.0130, 6.733, 16.12, .61, 4.010, .45; ...
           547.676440, 9.7010, .114, 26.00, .70, 4.500, 1.00; ...
           552.020960, 14.7700, .114, 26.00, .70, 4.500, 1.00; ...
           556.936002, 487.4000, .159, 32.10, .69, 4.110, 1.00; ...
           620.700807, 5.0120, 2.200, 24.38, .71, 4.680, .68; ...
           645.866155, 0.0713, 8.580, 18.00, .60, 4.000, .50; ...
           658.005280, 0.3022, 7.820, 32.10, .69, 4.140, 1.00; ...
           752.033227, 239.6000, .396, 30.60, .68, 4.090, .84; ...
           841.053973, 0.0140, 8.180, 15.90, .33, 5.760, .45; ...
           859.962313, 0.1472, 7.989, 30.60, .68, 4.090, .84; ...
           899.306675, 0.0605, 7.917, 29.85, .68, 4.530, .90; ...
           902.616173, 0.0426, 8.432, 28.65, .70, 5.100, .95; ...
           906.207325, 0.1876, 5.111, 24.08, .70, 4.700, .53; ...
           916.171582, 8.3400, 1.442, 26.70, .70, 4.780, .78; ...
           923.118427, 0.0869, 10.220, 29.00, .70, 5.000, .80; ...
           970.315022, 8.9720, 1.920, 25.50, .64, 4.940, .67; ...
           987.926764, 132.1000, .258, 29.85, .68, 4.550, .90; ...
           1780.000000, 22300.0000, .952, 176.20, .50, 30.500, 5.00];


e = rho.*T/216.7; % H2O
theta = 300./T;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dry continuum contribution
d = 5.6e-4*(p+e).*(theta.^0.8);

num1 = 6.14e-5;
den1 = d.*(1 + ((f./d).^2));
num2 = 1.4e-12.*p.*(theta.^1.5);
den2 = 1+ (1.9e-5.*(f.^1.5));

%Ndry = f.*p.*(theta.^2).*((num1./den1)+(num2.*(1-(1.2e-5.*(f.^1.5))))); % P.676-3 (1997) 
Ndry = f.*p.*(theta.^2).*((num1./den1)+(num2./den2)); % P.676-10 (9/2013)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wet continuum contribution
% Nwet = f.*((3.57.*(theta.^7.5).*e) + 0.113.*p).*1e-7.*e.*(theta.^3); % P.676-3 (1997) 
Nwet = 0; % P.676-10 (9/2013)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial estimate
Npp = Ndry + Nwet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Oxygen contribution
for ii = 1:size(data_o2,1);
  S = data_o2(ii, 2).*1e-7.*p.*(theta.^3).*exp(data_o2(ii, 3).*(1-theta));

  % "e" in the calculation below looks suspicious:
  Deltaf = data_o2(ii,4).*1e-4.*(p.*(theta.^(0.8 - data_o2(ii,5))) + (1.1.*e.*theta)); 
  
  % Line-width modification (P.676-10, not in P.676-3):
  Deltaf = sqrt((Deltaf.^2) + 2.25e-6);
  
  
  delta = (data_o2(ii,6) + data_o2(ii,7)*theta).*1e-4.*(p+e).*(theta.^0.8);
  
  num1 = Deltaf - delta.*(data_o2(ii,1) - f);
  den1 = ((data_o2(ii,1) - f).^2) + (Deltaf.^2);
  num2 = Deltaf - delta.*(data_o2(ii,1) + f);
  den2 = ((data_o2(ii,1) + f).^2) + (Deltaf.^2);
  
  F = (f./data_o2(ii,1)).*((num1./den1) + (num2./den2));
  
  Npp = Npp + S.*F;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Water contribution
for ii = 1:size(data_h2o, 1);

  S = data_h2o(ii,2).*1e-1.*e.*(theta.^3.5).*exp(data_h2o(ii,3).*(1-theta));
  Deltaf = data_h2o(ii, 4).*1e-4.*(p.*(theta.^(data_h2o(ii,5))) + data_h2o(ii, 6).*e.*(theta.^data_h2o(ii, 7)));
  % Doppler broadening:
  Deltaf = 0.535.*Deltaf + sqrt(0.217.*(Deltaf.^2)+((2.1316e-12).*(data_h2o(ii,1).^2)./theta)); 
  
  den1 = ((data_h2o(ii,1) - f).^2) + (Deltaf.^2);
  den2 = ((data_h2o(ii,1) + f).^2) + (Deltaf.^2);
  F = (f./data_h2o(ii,1)).*((Deltaf./den1) + (Deltaf./den2));

  Npp = Npp + S.*F;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


gamma = 0.1820.*f.*Npp;

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
