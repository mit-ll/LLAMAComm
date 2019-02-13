function out = GammaCdfInv(cdfx,alph,theta)
% Function 'simulator/channel/GammaCdfInv.m':  
% Evaluates the inverse gamma cdf paramaterized by alph and theta
%
%
% USAGE:  x = GammaCdfInv(cdfx,alph,lam)
%
% Input arguments:
%  cdfx             (double array)  cdf-values
%  alph             (double) Gamma pdf shape parameter
%  theta            (double) Gamma pdf scale parameter
%
% Output argument:
%  x                (double array) value of x which generates cdfx
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

xvec = linspace(0,4.5*theta*sqrt(alph),100);
%yvec = gammainc(xvec/theta,alph)/gamma(alph);
yvec = gammainc(xvec/theta,alph);  % Don't need to divide by gamma(alph) because gammainc does it already
out  = f_inv(cdfx,xvec,yvec);

% out = zeros(1,length(theta));
% for I = 1:length(theta)
%     del = sqrt(alph)*theta(I)/100;
%     x = 0;
%     s = 0;
%     while s < cdfx
%         s = sum(GammaPdf([0:del:x*del],alph,theta(I)))*del;
%         x = x + 1;
%     end
%     out(I) = x*del;
% end

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


