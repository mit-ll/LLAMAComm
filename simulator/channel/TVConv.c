/*
  This material is based upon work supported by the Defense Advanced Research
  Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
  findings, conclusions or recommendations expressed in this material are those
  of the author(s) and do not necessarily reflect the views of the Defense
  Advanced Research Projects Agency.

  © 2019 Massachusetts Institute of Technology.


  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License version 2 as
  published by the Free Software Foundation;

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mex.h>

/*--- out = TVConv(H, lags, source, longestLag); ---*/

void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[]){

  /********** Values directly related to input arguments **********/

  const mxArray *pH_mxArr = prhs[0];          /* Pointer to the channel matrix mxArray input argument */
  double *pH_re;                              /* Pointer to the real part of the channel matrix H */
  double *pH_im;                              /* Pointer to the imaginary part of the channel matrix H */
  int H_isComplex;                            /* Flag set if channel matrix H is complex */
  int nS;                                     /* Number of rows of the channel matrix */
  int nLags;                                  /* Number of columns of the channel matrix */
  int nLagsm1;                                /* Number of columns of the channel matrix minus 1 */

  const mxArray *pLags_mxArr = prhs[1];       /* Pointer to the lags mxArray input argument */
  double *pLags_re;                           /* Pointer to the real part of the lags array */

  const mxArray *pSource_mxArr = prhs[2];     /* Pointer to the source mxArray input argument*/
  double *pSource_re;                         /* Pointer to the real part of the source array */
  double *pSource_im;                         /* Pointer to the imaginary part of the source array */
  int source_isComplex;                       /* Flag set if channel matrix H is complex */
  double *pSrcLongLag_re;                     /* source pointer offset real part by longestLag */
  double *pSrcLongLag_im;                     /* source pointer offset imaginary part by longestLag */

  const mxArray *pLongestLag_mxArr = prhs[3]; /* Pointer to the longestLag mxArray input argument (Scalar) */
  int longestLag;                             /* Scalar value of longestLag */

  double *pOut_re;                            /* Pointer to the real part of the output */
  double *pOut_im;                            /* Pointer to the imaginary part of the output */
  double *pOutEnd_re;                         /* Sentinel pointer for the end of the output */

  /********** Internally allocated values **********/
  double **pLagSrc_re;                        /* lagSrc real part */
  double **pLagSrc_im;                        /* lagSrc imaginary part */
  double **pLagSrcEnd_re;                     /* Sentinel pointer for the end of lagSrc */

  /********** "Working" values, used for loops **********/
  double *pElLags;                            /* Points to an element of lags */
  int elLags;                                 /* Value of element of lags */
  double **pElLagSrc_re;                      /* Points to real part of an element of lagSrc */
  double **pElLagSrc_im;                      /* Points to imaginary part of an element of lagSrc */
  double elLagSrc_re;                         /* Value of element of lagSrc[][] */
  double elLagSrc_im;                         /* Value of element of lagSrc[][] */
  double *pElH_re;                            /* Points to real part of an element of channel matrix H */
  double *pElH_im;                            /* Points to imaginary part of an element of channel matrix H */
  double elH_re;                              /* Value of real part of an element of channel matrix H */
  double elH_im;                              /* Value of imaginary part of an element of channel matrix H */
  double *pOutEl_re;                          /* Points to real part of an element of output */
  double *pOutEl_im;                          /* Points to imaginary part of an element of output */
  int rowOffset;                              /* Row offset into the channel matrix */
  double sum_re;                              /* Accumulates the real part of multiply and add */
  double sum_im;                              /* Accumulates the imaginary part of multiply and add */


  /* Get Channel Matrix info */
  nS = mxGetM(pH_mxArr);
  nLags = mxGetN(pH_mxArr);
  nLagsm1 = nLags - 1;                               /* nLags minus 1 */
  H_isComplex = mxIsComplex(pH_mxArr);               /* Flag checking if 'H' is complex */
  pH_re = mxGetPr(pH_mxArr);                         /* Pointer to the real part of 'H' */
  if ( H_isComplex ){
    pH_im = mxGetPi(pH_mxArr);                       /* Pointer to the imaginary part of 'H' */
  }

  /* Get Lags info */
  pLags_re = mxGetPr(pLags_mxArr);                   /* Pointer to the real part of 'lags' */

  /* Get Source info */
  pSource_re = mxGetPr(pSource_mxArr);               /* Pointer to real part of source */
  source_isComplex = mxIsComplex(pSource_mxArr);     /* Flag check if 'source' is complex */
  if ( source_isComplex ){
    pSource_im = mxGetPi(pSource_mxArr);             /* Pointer to imaginary part of source */
  }

  /* Get longestLag */
  longestLag = (int)mxGetScalar(pLongestLag_mxArr);  /* Value for longestLag */

  /* Allocate space for the output and get info */
  if ( H_isComplex || source_isComplex ){
    plhs[0] = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxCOMPLEX);
    pOut_re = mxGetPr(plhs[0]);
    pOut_im = mxGetPi(plhs[0]);
  } else {
    plhs[0] = mxCreateNumericMatrix(1, nS, mxDOUBLE_CLASS, mxREAL);
    pOut_re = mxGetPr(plhs[0]);
  }
  pOutEnd_re = pOut_re + nS; /* output array (real part) sentinel value */
  

  /* 
     Build laggedSource so that:
     lagSrc[ii][jj] = Source[jj + longestLag - lags[nLags-ii-1]] 

     pElLags starts at the last element of lags and moves to the start
  */
  pLagSrc_re = (double **)mxCalloc(nLags, sizeof(double *));
  pLagSrcEnd_re = pLagSrc_re + nLags;
  if ( source_isComplex ){
    pLagSrc_im = (double **)mxCalloc(nLags, sizeof(double *));

    pSrcLongLag_re = pSource_re + longestLag;
    pSrcLongLag_im = pSource_im + longestLag;
    for (pElLags = pLags_re+nLagsm1, pElLagSrc_re = pLagSrc_re, pElLagSrc_im = pLagSrc_im; 
	 pElLagSrc_re < pLagSrcEnd_re; 
	 pElLags--, pElLagSrc_re++, pElLagSrc_im++){
      elLags = (int)*pElLags;
      *pElLagSrc_re = pSrcLongLag_re - elLags; 
      *pElLagSrc_im = pSrcLongLag_im - elLags;
    }
  } else {
    pLagSrc_im = (double **)NULL; /* Safe for mxFree */

    pSrcLongLag_re = pSource_re + longestLag;
    for (pElLags = pLags_re + nLagsm1, pElLagSrc_re = pLagSrc_re; 
	 pElLagSrc_re < pLagSrcEnd_re; 
	 pElLagSrc_re++, pElLags--){
      elLags = (int)*pElLags;
      *pElLagSrc_re = pSrcLongLag_re - elLags;      
    }
  }
  

  /*
    Now used laggedSource to do the multiply and add operations
  */
  if ( H_isComplex && source_isComplex ){
    /* 
       Case 1: 
       channel matrix is complex
       source is complex 
    */    
    for (pOutEl_re = pOut_re, pOutEl_im = pOut_im, rowOffset = (nLagsm1*nS); 
	 pOutEl_re < pOutEnd_re; 
	 pOutEl_re++, pOutEl_im++, rowOffset++ ){
      sum_re=0.;
      sum_im=0.; 
      for (pElLagSrc_re = pLagSrc_re, pElLagSrc_im = pLagSrc_im, pElH_re = pH_re + rowOffset, pElH_im = pH_im + rowOffset;
	   pElLagSrc_re < pLagSrcEnd_re; 
	   pElLagSrc_re++, pElLagSrc_im++, pElH_re-=nS, pElH_im-=nS){	
        elH_re = *pElH_re;
        elH_im = *pElH_im;
        elLagSrc_re = *((*pElLagSrc_re)++);
        elLagSrc_im = *((*pElLagSrc_im)++);
	sum_re += (elH_re*elLagSrc_re - elH_im*elLagSrc_im);
        sum_im += (elH_re*elLagSrc_im + elLagSrc_re*elH_im);
      }      
      *pOutEl_re = sum_re;
      *pOutEl_im = sum_im; 
    }

  } else if ( H_isComplex && !source_isComplex ) {
    /* 
       Case 2: 
       channel matrix is complex 
       source is real 
    */
    for (pOutEl_re = pOut_re, pOutEl_im = pOut_im, rowOffset = (nLagsm1*nS); pOutEl_re < pOutEnd_re; pOutEl_re++, pOutEl_im++, rowOffset++ ){
      sum_re=0.;
      sum_im=0.; 
      for (pElLagSrc_re = pLagSrc_re, pElH_re =pH_re + rowOffset, pElH_im = pH_im + rowOffset;
	   pElLagSrc_re<pLagSrcEnd_re; 
	   pElLagSrc_re++, pElH_re-=nS, pElH_im-=nS) {
	elH_re = *pElH_re;
	elH_im = *pElH_im;
	elLagSrc_re = *((*pElLagSrc_re)++);
	sum_re += (elH_re*elLagSrc_re);
	sum_im += (elLagSrc_re*elH_im);
      }
      *pOutEl_re = sum_re;
      *pOutEl_im = sum_im;
    }
  } else if ( !H_isComplex && source_isComplex ) {
    /* 
       Case 3: 
       channel matrix is real
       source is complex
    */
    for (pOutEl_re = pOut_re, pOutEl_im = pOut_im, rowOffset = (nLagsm1*nS); 
	 pOutEl_re < pOutEnd_re; 
	 pOutEl_re++, pOutEl_im++, rowOffset++ ){
      sum_re=0.;
      sum_im=0.;
      for (pElLagSrc_re = pLagSrc_re, pElLagSrc_im = pLagSrc_im, pElH_re =pH_re + rowOffset; 
	   pElLagSrc_re < pLagSrcEnd_re; 
	   pElLagSrc_re++, pElLagSrc_im++, pElH_re-=nS){
	elH_re = *pElH_re;       
	elLagSrc_re = *((*pElLagSrc_re)++);
	elLagSrc_im = *((*pElLagSrc_im)++);
	sum_re += (elH_re*elLagSrc_re);
	sum_im += (elH_re*elLagSrc_im);
      }
      *pOutEl_re = sum_re;
      *pOutEl_im = sum_im;
    }
  } else if ( !H_isComplex && !source_isComplex ) {
    /* 
       Case 4: 
       channel matrix is real
       source is real
    */
    for (pOutEl_re = pOut_re, rowOffset = (nLagsm1*nS); 
	 pOutEl_re < pOutEnd_re; 
	 pOutEl_re++, rowOffset++ ){
      sum_re=0.; 
      for (pElLagSrc_re = pLagSrc_re, pElH_re = pH_re + rowOffset;
	   pElLagSrc_re < pLagSrcEnd_re; 
	   pElLagSrc_re++, pElH_re-=nS) {
	elH_re = *pElH_re;
	elLagSrc_re = *((*pElLagSrc_re)++);
	sum_re += (elH_re*elLagSrc_re);
      }
      *pOutEl_re = sum_re;
    }
  }

  mxFree(pLagSrc_re);
  mxFree(pLagSrc_im);
  return;
} /*--- end of mexFunction ---*/

/*
  This material is based upon work supported by the Defense Advanced Research
  Projects Agency under Air Force Contract No. FA8702-15-D-0001. Any opinions,
  findings, conclusions or recommendations expressed in this material are those
  of the author(s) and do not necessarily reflect the views of the Defense
  Advanced Research Projects Agency.

  © 2019 Massachusetts Institute of Technology.


  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License version 2 as
  published by the Free Software Foundation;

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*/
