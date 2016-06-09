function si = mysinint(xx)
% function si = mysinint(x)
% calculate sine integral function int_0^x sin(t) / t dt
% based on Abramowitz and Stegun, p 233

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ndims(xx)>2; %#ok - ismatrix not available for older MATLAB versions
  error('input must have two or fewer dimensions, function mysinint');
end
if ~isreal(xx) 
  error('sine integral input must be real, function mysinint');
end

% work with positive arguments
ysign = sign(xx);
xx    = abs(xx); 

[MM, NN] = size(xx);
yy = zeros(size(xx));


% the xx part
for mm = 1:MM
  for nn = 1:NN
    zz = xx(mm, nn);
    
    if zz <1  
      % series expansion
      Nterms = 100;
      signvec = [ -ones(1, Nterms/2); ones(1, Nterms/2) ];
      signvec = reshape(signvec, 1, Nterms);
      divvec  = 1./(3:2:2*Nterms+1);
      oddvec  = 3:2:2*Nterms+1;
      evenvec = 2:2:2*Nterms;
      zzvec  = zz*cumprod(repmat(zz^2, 1, Nterms)./(oddvec.*evenvec) );

      % Note that if zz==0, this calculation returns yy==0, as it should
      yy(mm, nn) = zz + sum( signvec .* divvec.* zzvec );

    else
      % Rational approximation, zz real, 1 <= zz <Inf
      zz2 = zz^2;
      ff = ((((zz2+38.027264)*zz2+265.187033)* ...
             zz2+335.677320)*zz2+38.102495 ) ./ ( zz* ...
                                                  ((((zz2+40.021433)*zz2+322.624911)* ...
                                                    zz2+570.236280)*zz2+157.105423)); 
      gg = ((((zz2+42.242855)*zz2+302.757865)* ...
             zz2+352.018498)*zz2+21.821899 ) ./ ( zz2* ...
                                                  ((((zz2+48.196927)*zz2+482.485984)* ...
                                                    zz2+1114.978885)*zz2+449.690326));
      yy(mm, nn) = pi/2 - ff*cos(zz) - gg*sin(zz); 
    end
    
  end
end

si = ysign.*yy;


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


