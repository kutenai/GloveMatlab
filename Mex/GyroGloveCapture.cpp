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
#include <string.h>

#include <mex.h>
#include <math.h>

static int sock_client = 0;
static sockaddr_in sa;
static char buffer[100];
static unsigned char rxBuf[2048];

void socketClose()
{
    if (sock_client) {
        close(sock_client);
        sock_client = 0;
        mexPrintf("Closed Socket connection.\n");
    }
}

void socketOpen(const char* addr, unsigned long port)
{
    mexPrintf("Opening Socket\n");
    if (sock_client != 0) {
        socketClose();
    }
    
    sock_client = socket(AF_INET, SOCK_STREAM,0);
    if (sock_client == 0) {
        mexErrMsgTxt("Failed to open socket!");
    }
    mexPrintf("Socket Opened\n");

    timeval tv;
    tv.tv_sec = 3;
    tv.tv_usec = 0;
    setsockopt(sock_client, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);

    inet_pton(AF_INET, addr,(void*)&sa.sin_addr.s_addr);

    int retc = connect(sock_client, (const sockaddr*)&sa, sizeof(sa));
    if (retc < 0) {
        // didn't connect.
        close(sock_client);
        sock_client = 0;
        mexErrMsgTxt("Failed to connect socket!");
    } else {
        mexPrintf("Socket opened and connected.\n");
    }
}

void socketSend(const char* s)
{
    send(sock_client,s,strlen(s),MSG_DONTWAIT);
}

bool socketIsOpen()
{
    if (sock_client)
        return true;
    return false;
}

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{

    int   SSEnable = 0;
    
    if (nrhs == 0) {
        socketClose();

        return;
    }
    
    // If the RHS is a cell array, then it will contain
    // some commands, like an address and port to connect to,
    // and then perhaps some commands like start, stop, data
    if (mxIsCell(prhs[0])) {
        mwSize nDims = mxGetNumberOfDimensions(prhs[0]);
        const mwSize *dims = mxGetDimensions(prhs[0]);
        //mexPrintf("nDims:%d \n", nDims);
        //for (int x=0;x<nDims;x++) {
        //    mexPrintf("Dims[%d] = %d\n", x, dims[x]);
        //}
        
        if (nDims != 2) {
            mexErrMsgTxt("Expected a 1 by N Cell array. Number of dimensions is not 2.");
        }
        if (dims[0] != 1) {
            mexErrMsgTxt("Expected a 1 by N Cell array. First dimension is not 1");
        }
    } else {
        mexErrMsgTxt("Expected a 1 by N Cell array. Input is not a cell array.");
    }
    
    size_t nElements = mxGetNumberOfElements(prhs[0]);
    
    const mxArray *cmd = mxGetCell(prhs[0],0);
    if (!mxIsChar(cmd)) {
        mexErrMsgTxt("First element of cell array must be string command.");
    }
    
    char cmdBuf[20];
    mxGetString(cmd,&cmdBuf[0],18);
    //mexPrintf("Command:%s:\n",&cmdBuf[0]);
    
    if (strcmp(&cmdBuf[0],"connect")==0) {
        // Initialize the socket if this is the first time.
        mexPrintf("Connecting...\n");
        //socketOpen("192.168.1.147",5120);
        socketOpen("127.0.0.1",5120);
        
    } else if (strcmp(&cmdBuf[0],"close")==0) {
        socketClose();
    } else if (strcmp(&cmdBuf[0],"start")==0) {
        if (!socketIsOpen()) {
            mexErrMsgTxt("Socket not opened.");
        }
        socketSend("start\n");
    } else if (strcmp(&cmdBuf[0],"stop")==0) {
        if (!socketIsOpen()) {
            mexErrMsgTxt("Socket not opened.");
        }
        socketSend("stop\n");
    } else if (strcmp(&cmdBuf[0],"quit")==0) {
        if (!socketIsOpen()) {
            mexErrMsgTxt("Socket not opened.");
        }
        socketSend("quit\n");
    } else if (strcmp(&cmdBuf[0],"recv")==0) {
        
        if (nlhs != 2) {
            mexErrMsgTxt("recv command requires two output arguments. [couunt, values]");
        }
        double nCount = 1;
        if (nElements > 1) {
            nCount = mxGetScalar(mxGetCell(prhs[0],1));
        }

        // Get nCount number of packets
        ssize_t num;
        // The total # of columns depends on the # of values per IMU.
        int valsPerIMU = 6;
        int numIMUs = 6;

        mwSize dims[] = {mwSize(nCount),1+numIMUs*valsPerIMU};
        mwSize nDims = 2;
        plhs[0] = mxCreateNumericArray(nDims,dims,mxINT16_CLASS, mxREAL);
        plhs[1] =  mxCreateDoubleMatrix(1, 1, mxREAL);
        double* pNumOutput = mxGetPr(plhs[1]);
        *pNumOutput = double(0);
        short *pResults = (short*)mxGetData(plhs[0]);
        bool bDataAvail = true;
        int x = 0;
        while (bDataAvail && (x < nCount)) {
            socketSend("data\n");
            num = recv(sock_client, &rxBuf[0], 5, MSG_WAITALL);
            if (num < 0) {
                // Socket Error
                mexPrintf("Error from recv:%s\n",strerror(errno));
                mexErrMsgTxt("Error in socket read.");
            }
            if (num == 0) {
                mexErrMsgTxt("No data returned. This indicate a closed connection or some other error.");
            }
            if (rxBuf[0] == 0xb7) {
                // This is the correct message type
                unsigned short msgLen;
                unsigned short msgID;
                msgLen = rxBuf[1] << 8 | rxBuf[2];
                msgID =  rxBuf[3] << 8 | rxBuf[4];
                //mexPrintf("Message Length:%d\n",msgLen);
                //mexPrintf("Message ID:%d\n",msgID);
                
                if (msgLen > 0) {
                    num = recv(sock_client, &rxBuf[0], msgLen+1, MSG_WAITALL);
                    //mexPrintf("Received %d bytes\n", num);

                    // First, update the ID. Always the first column, so this indexing is easy.
                    pResults[x] = msgID;
                    unsigned short startIndex = 0;
                    short *pShorts;
                    //int valsPerIMU = 9;
                    for (int imu=0;imu<6;imu++) {
                        // Cast the rxBuffer index by the imu to a short pointer so that
                        // we can easily index into the shorts.
                        pShorts = reinterpret_cast<short *>(&rxBuf[imu*valsPerIMU*2+1]);

                        // imu*valsPerIMU => number of columns per IMU
                        // +1 becuase the first column is the ID
                        // nCount is number of rows per column, hence offset per column.
                        // x is then the row in the index column
                        startIndex = (imu*valsPerIMU+1)*nCount+x;

                        // Now, copy all of the values into the result array.
                        for (int val=0;val<valsPerIMU;val++) {
                            short t;
                            //t = rxBuf[imu*valsPerIMU*2+val*2+1] << 8 | rxBuf[imu*valsPerIMU*2+val*2];
                            //pResults[startIndex+val*int(nCount)] = double(t);
                            pResults[startIndex+val*int(nCount)] = htons(pShorts[val]);
                        }
                    }
                    *pNumOutput = (*pNumOutput + 1);
                } else {
                    // We received a message, but there was no data... that's all we have for now.
                    bDataAvail = false;
                }
            } else {
                mexPrintf("Incorrect message type! 0x%x\n",(unsigned char)rxBuf[0]);
                num = recv(sock_client, &rxBuf[0], 2048, MSG_PEEK | MSG_DONTWAIT);
                mexPrintf("This many bytes left:%d\n",num);
                recv(sock_client,&rxBuf[0],num,MSG_WAITALL);
            }
            x++;
        }
    }
    
}


