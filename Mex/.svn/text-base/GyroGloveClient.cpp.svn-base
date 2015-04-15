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

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>

#include <mex.h>
#include <math.h>

static int sock_client = 0;
static sockaddr_in sa;
static char buffer[100];

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{

    int   SSEnable = 0;
    
    if (nrhs == 0) {
        if (sock_client) {
            close(sock_client);
            sock_client = 0;
            mexPrintf("Closed Socket connection.\n");
        }

        return;
    }
    
    if (nrhs < 2) {
        mexErrMsgTxt("Two arguments required. The index,"
            " and an array of position and rotation.");
    }
    
    double idx = mxGetScalar(prhs[0]);
    
    // I am expecting an nxm array, where n is the # of clusters
    // and m is the number of features.
    mwSize nrows = mxGetM(prhs[1]);
    mwSize ncols = mxGetN(prhs[1]);
    mwSize elements = mxGetNumberOfElements(prhs[1]);
    mwSize number_of_dims=mxGetNumberOfDimensions(prhs[1]);
   
    if (ncols != 6) {
        mexErrMsgTxt("Input array in 2nd argument must have 6 columns");
    }
    
    unsigned long sleeptime = 10000;
    if (nrhs > 2) {
        sleeptime = int(mxGetScalar(prhs[2]));
    }
    
    double* pin = mxGetPr(prhs[1]);
    
    // Initialize the socket if this is the first time.
    if (sock_client == 0 ) {
        sock_client = socket(AF_INET, SOCK_DGRAM,0);
        if (sock_client == 0) {
            mexErrMsgTxt("Failed to open socket!");
        }
        mexPrintf("Opened Socket connection.\n");
        
        sa.sin_family = AF_INET;
        sa.sin_port = htons(5432);
        
        inet_pton(AF_INET, "127.0.0.1",(void*)&sa.sin_addr.s_addr);
    }
    
    double* pStart = pin;
    
    for (int r = 0;r< nrows;r++) {
        sprintf(buffer,"%d,%f,%f,%f,%f,%f,%f",
            int(idx),
            pStart[r],
            pStart[r+1*nrows], 
            pStart[r+2*nrows],
            pStart[r+3*nrows],
            pStart[r+4*nrows],
            pStart[r+5*nrows]
            );
        
        sendto(sock_client, &buffer[0], strlen(buffer), 0, 
            (const sockaddr*)&sa, sizeof(struct sockaddr_in)
            );
        
        usleep(sleeptime);
    }
}


