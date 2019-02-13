/* 
   Approved for public release: distribution unlimited.
   
   This material is based upon work supported by the Defense Advanced Research 
   Projects Agency under Air Force Contract No. FA8721-05-C-0002. Any opinions, 
   findings, conclusions or recommendations expressed in this material are those 
   of the author(s) and do not necessarily reflect the views of the Defense 
   Advanced Research Projects Agency.
   
   © 2014 Massachusetts Institute of Technology.
   
   The software/firmware is provided to you on an As-Is basis
   
   Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS 
   Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, 
   U.S. Government rights in this work are defined by DFARS 252.227-7013 or 
   DFARS 252.227-7014 as detailed above. Use of this work other than as 
   specifically authorized by the U.S. Government may violate any copyrights
   that exist in this work.
*/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#if defined(_WIN32) || defined(_WIN32_) || defined (__WIN32__)
/* Remap Microsoft Visual C internal types */
typedef unsigned __int8 uint8_t;
typedef __int8 int8_t;
typedef unsigned __int16 uint16_t;
typedef __int16 int16_t;
typedef unsigned __int32 uint32_t;
typedef __int32 int32_t;
typedef unsigned __int64 uint64_t;
typedef __int64 int64_t;
#else
/* Just use the usal stdint.h */
#include <stdint.h>
#endif

#include <mex.h>

#include "coslut65536.h"

/* Make adjustments based on included LUT definition */
#if LUTSIZE == 256
#define INDEXVAR_T uint8_t
#elif LUTSIZE == 65536
#define INDEXVAR_T uint16_t
#else
#define INDEXVAR_T int
#define AWKWARD_LUT_SIZE
#if defined(_WIN32) || defined(_WIN32_) || defined (__WIN32__)
#pragma message("Note: The including LUT size cannot be indexed efficiently")
#else
#warning "Note: The including LUT size cannot be indexed efficiently"
#endif
#endif

#define TWOPI (6.283185307179586)
#define R2D (57.295779513082323)

void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[]){

  double f, twopif, theta;
  double *alphr, *phir, *sphir;
  double *hr, *hrPtr, *hrPtrEnd;
  double *hi, *hiPtr;
  double *t, *tPtr;
  double tempd1, tempd2, tempd3, tempd4;
  double r2dscale;
  int m, nSamp;
  INDEXVAR_T lutIndx;
  double *alphrPtr, *alphrPtrEnd, *phirPtr, *sphirPtr;

  mxArray *M, *Alph, *Phi, *Sphi;

  /*---------------*/

  f = (double)mxGetScalar(prhs[0]);

  t = mxGetPr(prhs[1]);
  nSamp = mxGetNumberOfElements(prhs[1]);

  M     = mxGetField(prhs[2], 0, "M");
  Alph  = mxGetField(prhs[2], 0, "alph");
  Phi   = mxGetField(prhs[2], 0, "phi");
  Sphi  = mxGetField(prhs[2], 0, "sphi");

  m     = (int)mxGetScalar(M);
  alphr = mxGetPr(Alph);
  phir  = mxGetPr(Phi);
  sphir = mxGetPr(Sphi);

  *plhs = mxCreateNumericMatrix(1, nSamp, mxDOUBLE_CLASS, mxCOMPLEX);
  hr = mxGetPr(*plhs);
  hi = mxGetPi(*plhs);

  r2dscale = R2D * STEPSIZE;
  twopif = f * TWOPI;

  hrPtrEnd = hr + nSamp;
  
  /*printf(">> m = %d, nSamp = %d \n", m, nSamp); */

  alphrPtrEnd = alphr + m;
#ifdef AWKWARD_LUT_SIZE
  for(alphrPtr = alphr, phirPtr = phir, sphirPtr = sphir; 
      alphrPtr < alphrPtrEnd ; 
      alphrPtr++, phirPtr++, sphirPtr++){

    lutIndx = ((INDEXVAR_T)(*alphrPtr*r2dscale))%LUTSIZE;
    lutIndx = lutIndx<0 ? lutIndx+LUTSIZE : lutIndx;      
    tempd1 = twopif*coslut[lutIndx];

    lutIndx = ((INDEXVAR_T)((*alphrPtr*R2D-90.)*STEPSIZE))%LUTSIZE;
    lutIndx = lutIndx<0 ? lutIndx+LUTSIZE : lutIndx;

    tempd2 = twopif*coslut[lutIndx];
    tempd3 = *phirPtr;
    tempd4 = *sphirPtr;
  
    for(hrPtr = hr, hiPtr = hi, tPtr = t; hrPtr < hrPtrEnd; hrPtr++, hiPtr++, tPtr++) {
      lutIndx = ((INDEXVAR_T)((tempd1**tPtr+tempd3)*r2dscale))%LUTSIZE;
      lutIndx = lutIndx<0 ? lutIndx+LUTSIZE : lutIndx;
      *hrPtr += 2.*coslut[lutIndx];

      lutIndx = ((INDEXVAR_T)((tempd2**tPtr+tempd4)*r2dscale))%LUTSIZE;
      lutIndx = lutIndx<0 ? lutIndx+LUTSIZE : lutIndx;      
      *hiPtr += 2.*coslut[lutIndx];
    }
  }
  
#else
  for(alphrPtr = alphr, phirPtr = phir, sphirPtr = sphir; 
      alphrPtr < alphrPtrEnd ; 
      alphrPtr++, phirPtr++, sphirPtr++){

    lutIndx = (INDEXVAR_T)(*alphrPtr*r2dscale);
    tempd1 = twopif*coslut[lutIndx];
    lutIndx = (INDEXVAR_T)((*alphrPtr*R2D-90.)*STEPSIZE);

    tempd2 = twopif*coslut[lutIndx];
    tempd3 = *phirPtr;
    tempd4 = *sphirPtr;
    for(hrPtr = hr, hiPtr = hi, tPtr = t; hrPtr < hrPtrEnd; hrPtr++, hiPtr++, tPtr++) {
      
	lutIndx = (INDEXVAR_T)((tempd1**tPtr+tempd3)*r2dscale);
	*hrPtr += 2.*coslut[lutIndx];

	lutIndx = (INDEXVAR_T)((tempd2**tPtr+tempd4)*r2dscale);
	*hiPtr += 2.*coslut[lutIndx];
    }
  }
#endif
  tempd1 = sqrt(1./(4.*m));
  for (hrPtr = hr, hiPtr = hi; hrPtr < hrPtrEnd; hrPtr++, hiPtr++){
    *hrPtr *= tempd1;
    *hiPtr *= tempd1;
  }     
  
  return;
} /*--- end of mexFunction ---*/

#undef AWKWARD_LUT_SIZE
