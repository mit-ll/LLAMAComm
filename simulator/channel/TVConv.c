/* 
   Copyright (c) 2006-2016, Massachusetts Institute of Technology All rights
   reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
        * Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above  copyright
 	  notice, this list of conditions and the following disclaimer in
	  the documentation and/or other materials provided with the
	  distribution.
	* Neither the name of the Massachusetts Institute of Technology nor
	  the names of its contributors may be used to endorse or promote
	  products derived from this software without specific prior written
	  permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mex.h>

/*--- out = TVConv(H, lags, source, longestLag); ---*/

void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[]){
  /*--- Local.. ---*/

  double *pHr, *pHi, *pSr, *pSi;
  double *pOr, *pOi, *pL;

  int nS, nLags, iLag;
  int complexH, complexS;
  int longestLag, lag, i, nLagsm1;

  double rp1, ip1, rp2, ip2;
  double sumr, sumi;
  double **pSSr, **pSSi;

  int j0;
  double *pOrPtr, *pOiPtr, *pOrPtrEnd;
  double **pSSrPtr, **pSSiPtr, **pSSrPtrEnd;
  double *pLPtr, *pSrPtr, *pSiPtr;
  double *rp1Ptr, *ip1Ptr;

  /*---------------*/

  nS    = mxGetM(prhs[0]);
  nLags = mxGetN(prhs[0]);

  pHr = mxGetPr(prhs[0]);
  complexH = mxIsComplex(prhs[0]);
  if ( complexH ){
    pHi = mxGetPi(prhs[0]);
  }

  pL = mxGetPr(prhs[1]);

  pSr = mxGetPr(prhs[2]);
  complexS = mxIsComplex(prhs[2]);

  longestLag = (int)mxGetScalar(prhs[3]);

  pSSr = (double **)mxCalloc(nLags, sizeof(double *));
  pSSrPtrEnd = pSSr + nLags;

  if ( complexS ){
    pSi = mxGetPi(prhs[2]);
    pSSi = (double **)mxCalloc(nLags, sizeof(double *));
    pSrPtr = pSr + longestLag;
    pSiPtr = pSi + longestLag;
    for (pSSrPtr = pSSr, pSSiPtr = pSSi, pLPtr = pL+nLags-1; pSSrPtr < pSSrPtrEnd; pSSrPtr++, pSSiPtr++, pLPtr--){
      lag = (int)*pLPtr;
      *pSSrPtr = pSrPtr - lag;      
      *pSSiPtr = pSiPtr - lag;
    }
  } else {
    pSSi = (double **)NULL; /* Safe for mxFree */
    pSrPtr = pSr + longestLag;
    for (pSSrPtr = pSSr, pLPtr = pL+nLags-1; pSSrPtr < pSSrPtrEnd; pSSrPtr++, pLPtr--){
      lag = (int)*pLPtr;
      *pSSrPtr = pSrPtr - lag;      
    }
  }
  
  nLagsm1 = nLags - 1;
  if ( complexH && complexS ){
    *plhs = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxCOMPLEX);
    pOr = mxGetPr(*plhs);
    pOi = mxGetPi(*plhs);
    pOrPtrEnd = pOr + nS;
    for (pOrPtr = pOr, pOiPtr = pOi, j0 = (nLagsm1*nS); pOrPtr < pOrPtrEnd; pOrPtr++, pOiPtr++, j0++ ){
      for (pSSrPtr = pSSr, pSSiPtr = pSSi, rp1Ptr =pHr + j0, ip1Ptr = pHi + j0, sumr=0., sumi=0.; 
	   pSSrPtr < pSSrPtrEnd; 
	   pSSrPtr++, pSSiPtr++, rp1Ptr-=nS, ip1Ptr-=nS){	
        rp1 = *rp1Ptr;
        ip1 = *ip1Ptr;
        rp2 = *((*pSSrPtr)++);
        ip2 = *((*pSSiPtr)++);
	sumr += (rp1*rp2 - ip1*ip2);
        sumi += (rp1*ip2 + rp2*ip1);
      }      
      *pOrPtr = sumr;
      *pOiPtr = sumi; 
    }

  } else if ( complexH && !complexS ) {
    *plhs = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxCOMPLEX);
    pOr = mxGetPr(*plhs);
    pOi = mxGetPi(*plhs);
    pOrPtrEnd = pOr + nS;
    for (pOrPtr = pOr, pOiPtr = pOi, j0 = (nLagsm1*nS); pOrPtr < pOrPtrEnd; pOrPtr++, pOiPtr++, j0++ ){
      for (pSSrPtr = pSSr, rp1Ptr =pHr + j0, ip1Ptr = pHi + j0, sumr=0., sumi=0.; 
	   pSSrPtr<pSSrPtrEnd; 
	   pSSrPtr++, rp1Ptr-=nS, ip1Ptr-=nS) {
	rp1 = *rp1Ptr;
	ip1 = *ip1Ptr;
	rp2 = *((*pSSrPtr)++);
	sumr += (rp1*rp2);
	sumi += (rp2*ip1);
      }
      *pOrPtr = sumr;
      *pOiPtr = sumi;
    }
  } else if ( !complexH && complexS ) {
    *plhs = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxCOMPLEX);
    pOr = mxGetPr(*plhs);
    pOi = mxGetPi(*plhs);
    pOrPtrEnd = pOr + nS;
    for (pOrPtr = pOr, pOiPtr = pOi, j0 = (nLagsm1*nS); pOrPtr < pOrPtrEnd; pOrPtr++, pOiPtr++, j0++ ){
      for (pSSrPtr = pSSr, pSSiPtr = pSSi, rp1Ptr =pHr + j0, sumr=0., sumi=0.; pSSrPtr < pSSrPtrEnd; pSSrPtr++, pSSiPtr++, rp1Ptr-=nS){
	rp1 = *rp1Ptr;       
	rp2 = *((*pSSrPtr)++);
	ip2 = *((*pSSiPtr)++);
	sumr += (rp1*rp2);
	sumi += (rp1*ip2);
      }
      *pOrPtr = sumr;
      *pOiPtr = sumi;
    }
  } else if ( !complexH && !complexS ) {
    *plhs = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxREAL);
    pOr = mxGetPr(*plhs);
    pOrPtrEnd = pOr + nS;
    for (pOrPtr = pOr, j0 = (nLagsm1*nS); 
	 pOrPtr < pOrPtrEnd; 
	 pOrPtr++, j0++ ){
      for (pSSrPtr = pSSr, rp1Ptr = pHr + j0, sumr=0; 
	   pSSrPtr<pSSrPtrEnd; 
	   pSSrPtr++, rp1Ptr-=nS) {
	rp1 = *rp1Ptr;
	rp2 = *((*pSSrPtr)++);
	sumr += (rp1*rp2);
      }
      *pOrPtr = sumr;
    }
  }

  mxFree(pSSr);
  mxFree(pSSi);
  return;
} /*--- end of mexFunction ---*/
