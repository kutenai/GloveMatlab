#include <fcntl.h>
#include <sys/ioctl.h>
#include <paths.h>
#include <sysexits.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

#include <mex.h>
#include <math.h>


void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{

    int   SSEnable = 0;
    
    if (nrhs < 1) {
        mexErrMsgTxt("One input required.");
    } else if (nlhs != 1) {
        mexErrMsgTxt("One output argument required.");
    }
    
    // I am expecting an nxm array, where n is the # of clusters
    // and m is the number of features.
    mwSize nrows = mxGetM(prhs[0]);
    mwSize ncols = mxGetN(prhs[0]);
    mwSize elements = mxGetNumberOfElements(prhs[0]);
    mwSize number_of_dims=mxGetNumberOfDimensions(prhs[0]);
    
    if (!mxIsDouble(prhs[0])) {
        mexErrMsgTxt("Input must be a double array.");
    }
    
    if (nrhs > 1) {
        SSEnable = 1;
    }
    
    plhs[0] = mxCreateDoubleMatrix(1,3,mxREAL);
    
    double *pOut = mxGetPr(plhs[0]);
    
    pOut[0] = 12.2;
    pOut[1] = 1.12;
    pOut[2] = 12;
    
    double *pFa = mxGetPr(prhs[0]);
    
    double *pCol[10];
    for (int z=0;z<ncols;z++) {
        pCol[z] = pFa+z*nrows;
    }

    double dMin = 1e12;
    
    // Data is in column major order... so, 
    // x and y can point to each column, then
    // iterate on features by adding x/y + mcols
    double fsum;
    for (int x=0;x<nrows;x++) {
        for (int y=0;y<nrows;y++) {
            if (y != x) {
                fsum = 0;
                for (int z=0;z<ncols;z++) {
                    // Simple squared function.
                    double t = (pCol[z][x]-pCol[z][y]);
                    fsum += t*t;
                    //fsum += (pFa[x+z*nrows]-pFa[y+z*nrows])*(pFa[x+z*nrows]-pFa[y+z*nrows]);
                }
                //fsum = sqrt(fsum); // Don't bother with the sqrt.. we just want t relative value..
                if (fsum < dMin) {
                    dMin = fsum;
                    pOut[0] = double(x+1);
                    pOut[1] = double(y+1);
                    pOut[2] = dMin;
                    
                    // This is an optimization. If a lot of pixels are close to zero in distance,
                    // then it is not that important to find the "closest" of those.
                    if (dMin < 0.02) {
                        return;
                    }
                }
            }
        }
    }
}


