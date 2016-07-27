function N = refractivity(T, p, rho); %#ok - f unused
%
%Usage:
%
%   N = refractivity(T, p, rho)
%
%Description:
%
%   Returns the approximate refractivity N of the 
% atmosphere. Note that the index of refraction is 
% n = 1 + (1e-6*N)
%
%Reference: Radio Meteorology
%           B. R. Bean and E. J. Dutton
%           National Bureau of Standards Monograph 92
%           March 1966
%           Eq 1.15, p. 7
%

e = rho.*T/216.7; % H2O

N = 77.6*((p-e)./T) + 72*(e./T) + 3.75e5*e./(T.*T);

