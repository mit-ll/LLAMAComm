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
#pragma message("Note: The included LUT size cannot be indexed efficiently")
#else
#warning "Note: The included LUT size cannot be indexed efficiently"
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

  plhs[0] = mxCreateNumericMatrix(1, nSamp, mxDOUBLE_CLASS, mxCOMPLEX);
  hr = mxGetPr(plhs[0]);
  hi = mxGetPi(plhs[0]);

  r2dscale = R2D * STEPSIZE;
  twopif = f * TWOPI;

  hrPtrEnd = hr + nSamp;


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
