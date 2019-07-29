function errStr = corrErrCheck(R)
errStr = [];

d = diag(R);
if(~all(d == 1))
    errStr = [errStr, '(Code 1) at least one diagonal entry differs from unity.'];
end

if(~all(imag(d) == 0))
    errStr = [errStr, '(Code 2) diagonal entries have non-zero imaginary components']; 
end

Dmat = R-R';
if(~all(Dmat(:) == 0))
    errStr = [errStr, '(Code 3) matrix is not Hermitian']; 
end

myeigs = eig(R);
if(~all(real(myeigs) > 0))
   errStr = [errStr,  '(Code 4) matrix is not positive semi-definite'];
end


if(~all(imag(myeigs) == 0))
   errStr = [errStr, ' (Code 5) at least one eigenvalue has a non-zero imaginary component']; 
end




    