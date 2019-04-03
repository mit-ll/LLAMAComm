function ci = mycosint(xx)
% function ci = mycosint(x)
% calculate cosine integral function - int_x^infty cos(t) / t dt
% based on Abramowitz and Stegun, p 233

% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.

if ndims(xx)>2; %#ok - ismatrix not available for older MATLAB versions
  error('input must have two or fewer dimensions, function mycosint');
end
if ~isreal(xx) || any(any(xx < 0))
  error('cosine integral input must be positive real values, function mycosint');
end

[MM, NN] = size(xx);

ci = zeros(size(xx));
% the xx part
for mm=1:MM
  for nn = 1:NN
    zz = xx(mm, nn);

    if zz<1
      % series expansion
      Nterms = 1000;
      C = 0.5772156649;   % euler's constant
      signvec = [ ones(1, Nterms/2); -ones(1, Nterms/2) ];
      signvec = reshape(signvec, 1, Nterms);
      divvec  = 1./(2:2:2*Nterms);
      oddvec  = 1:2:2*Nterms-1;
      evenvec = 2:2:2*Nterms;
      zzvec  = cumprod(repmat(zz^2, 1, Nterms)./(oddvec.*evenvec) );

      % Note that if zz==0, this calculation will produce -Inf, as it should:
      ci(mm, nn) = C + log(zz) - sum( signvec .* divvec.* zzvec );

    else
      % Rational approximation, zz real,   1 <= zz < Inf:
      zz2 = zz^2;
      ff = ((((zz2+38.027264)*zz2+265.187033)* ...
             zz2+335.677320)*zz2+38.102495 ) ./ ( zz* ...
                                                    ((((zz2+40.021433)*zz2+322.624911)* ...
                                                      zz2+570.236280)*zz2+157.105423));
      gg = ((((zz2+42.242855)*zz2+302.757865)* ...
             zz2+352.018498)*zz2+21.821899 ) ./ ( zz2* ...
                                                    ((((zz2+48.196927)*zz2+482.485984)* ...
                                                      zz2+1114.978885)*zz2+449.690326));
      ci(mm, nn) = ff*sin(zz) - gg*cos(zz);

    end
  end
end


% DISTRIBUTION STATEMENT A. Approved for public release.
% Distribution is unlimited.
%
% This material is based upon work supported by the Defense Advanced Research
% Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
% findings, conclusions or recommendations expressed in this material are those
% of the author(s) and do not necessarily reflect the views of the Defense
% Advanced Research Projects Agency.
%
% © 2019 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% The software/firmware is provided to you on an As-Is basis
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or
% DFARS 252.227-7014 as detailed above. Use of this work other than as
% specifically authorized by the U.S. Government may violate any copyrights
% that exist in this work.


