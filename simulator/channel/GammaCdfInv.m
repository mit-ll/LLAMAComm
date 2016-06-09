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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2006-2016 Massachusetts Institute of Technology %
% All rights reserved.   See software license below.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


