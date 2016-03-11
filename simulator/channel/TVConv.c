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
