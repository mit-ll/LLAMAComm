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

#include <stdio.h>
#ifdef MATLAB_MEX_FILE
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]){


  mwSize dims[2];
  int nRowsIn, nColsIn, complexIn, classIn;
  int nRowsOut, nColsOut;
  int nShifts;
  double *shifts;

  /* Gather Information */
  classIn = mxGetClassID(*prhs); 
  complexIn = mxIsComplex(*prhs);
  nRowsIn = mxGetM(*prhs);
  nColsIn = mxGetN(*prhs);
  nShifts = mxGetNumberOfElements(prhs[1]);
  shifts = mxGetPr(prhs[1]);  

  nRowsOut = nRowsIn*nShifts;
  nColsOut = nColsIn;
  


  /* (int)(*(double *)mxGetData(prhs[1])); */

  
  /* Checks */
  if ((nRowsOut < 1)|(nColsOut < 1)|(nShifts < 1)){
    /* Match corner cases */
    dims[0] = (nRowsOut > 1 ? nRowsOut: 0);
    dims[1] = (nColsOut > 0 ? nColsOut: 0);
    plhs[0] = mxCreateNumericArray(2, dims, classIn, complexIn);
    return;
  }
  if (classIn!=mxDOUBLE_CLASS){
    mexErrMsgTxt("One designed to work with double");
  }

  /* Allocate output space */
  dims[0] = nRowsOut;
  dims[1] = nColsOut;
  plhs[0] = mxCreateNumericArray(2, dims, classIn, complexIn);


  /* Note: Return values ignored - could add error checks here */
  (void)Stackzs(mxGetPr(*plhs), 
		mxGetPr(*prhs), 
		nRowsIn, nColsIn, 
		nShifts, shifts);  
  if (complexIn){
    (void)Stackzs(mxGetPi(*plhs),
		     mxGetPi(*prhs), 
		     nRowsIn, nColsIn, 
		     nShifts, shifts);  
    
  }
 

}
#endif

/*************************************************************************/
int Stackzs(double *ptrOut, 
	    double *ptrIn, 
	    int nrIn, 
	    int ncIn, 
	    int nShifts,
	    double *shifts){

  double *inPtr1, *inPtr2;
  double *outPtr1, *outPtr2, *outPtr3;
  double *endInPtr;
  double *endPtr2;
  double *shiftPtr, *endShifts;
  int cyc;
  int nrOut = nrIn*nShifts;
  /* int ncOut = ncIn; */

  /*
    function Z=Stackzs(z,shifts)

    shifts = -shifts ;
    Z=zeros(size(z,1)*length(shifts),size(z,2));
    for cnt=1:length(shifts)
    perm=cycle(size(z,2),shifts(cnt));
    Z((cnt-1)*size(z,1)+1:cnt*size(z,1),:)=z(:,perm);
    end
  */

  /* Some Argument Checks */
  if ((ptrIn==NULL)||(ptrOut==NULL)){
    return(1); /*Error */
  }
  if (nrIn < 0){
    return(2); /*Error */
  }
  if (ncIn < 0){
    return(3); /*Error */
  }
  if (nShifts < 0){
    return(3); /*Error */
  }
  
  endInPtr = ptrIn+(nrIn*ncIn);

  /* Loop over shifts */
  for(shiftPtr = shifts, endShifts = shifts+nShifts, outPtr1 = ptrOut; 
      shiftPtr < endShifts; 
      shiftPtr++, outPtr1+=nrIn){

    /* Index in to the correct starting column */
    cyc = -((int) (*shiftPtr))%ncIn;
    if (cyc < 0){
      cyc+=ncIn;
    }

    inPtr1 = ptrIn + (cyc*nrIn);
    /* Loop ove columns */
    for(outPtr2 = outPtr1, endPtr2 = outPtr1 + nrIn, inPtr2 = inPtr1;
	inPtr2 < endInPtr;
	outPtr2+=nrOut, endPtr2+=nrOut){

      /* Loop down rows */
      for(outPtr3 = outPtr2; 
	  outPtr3 < endPtr2; 
	  outPtr3++){
	*outPtr3 = *inPtr2++;
      }
    }

    /* Start back at the start of the input, loop over columns */
    for(inPtr2 = ptrIn;
	inPtr2 < inPtr1;
	outPtr2+=nrOut, endPtr2+=nrOut){

      /* Loop down rows */
      for(outPtr3 = outPtr2; 
	  outPtr3 < endPtr2; 
	  outPtr3++){
	*outPtr3 = *inPtr2++;
      }
    }       
  }

  
  return(0);
}
/*************************************************************************/
#ifndef MATLAB_MEX_FILE
/* This is just for testing */
int main(void){
  return(0);
}
#endif

