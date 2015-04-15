/****************************************************
*
* SerialIO.cpp
*
* --Educational Use Only
* 
* This is a MEX-FILE for matlab. 
* To compile type: "mex SerialIO.cpp" into prompt.
*
* After compiling, type: 
*			SerialIO('Help'); 
* for usage instructions.
*
* Credits:
*   -Modified for by Lorgio Teodovich, november 2009
*    Based on an example 'serial_write.c' from Kevin Barry
*    Lorgiot@gmail.com
*   -Modified for use with MATLAB by Jason Laska, April 2004
*   http://www.uiuc.edu/~laska
*   -Original code for SerialTerm (serial terminal program
*   from which this was taken)
*   by Albrecht Schmidt, Lancaster University - Oct 2001
*   http://www.comp.lancs.ac.uk/~albrecht 
*   Albrecht@comp.lancs.ac.uk
*   -SerialTerm was based on an example from Robert Mashlan
*   see http://r2m.com/~rmashlan/
*
*****************************************************/

#include <windows.h>

#undef EXTERN_C

#include <process.h>
#include "mex.h"

#define Thread

#define WIN32_LEAN_AND_MEAN

//Global Declarations

#ifdef Thread
// Variables used to detect if the threads are detect RX
// (volatile: reload the variable instead of using the value available in a register)
static volatile int WaitForRX;

// Mutex used to lock WaitForRX variable, to allow only one thread to 
// write it at the same time.
static HANDLE RX_Mutex;

static int EndWaitForRX;  //exit of thread
static int QuitWaitForRX; //success exit of thread

HANDLE Thread1; // Handles to the worker threads
#endif

HANDLE hCom = NULL;
double *SerialData;
int NumPoints;

#ifdef Thread
// The function which is multi threaded. 
void PolingWaitCommEvent(void *param)
{DWORD mask;
    while( ! EndWaitForRX )
    {        
        if(WaitForRX == 0){
                WaitForSingleObject(RX_Mutex, INFINITE);
                if(SetCommMask(hCom,EV_RXCHAR)){
                    if(WaitCommEvent(hCom,&mask, NULL)){
                        if( mask & EV_RXCHAR)
                            WaitForRX = 1 ;                    
                    }
                }
                ReleaseMutex(RX_Mutex);
        }        
        Sleep(5);
    }
    QuitWaitForRX = 1 ;
    // explicit end thread, helps to ensure proper recovery of resources allocated for the thread
    _endthread();
}
#endif

void closeSerial()
{
    if(!(hCom==NULL)){
        #ifdef Thread
        QuitWaitForRX = 0;
        EndWaitForRX = 1;
        while(!QuitWaitForRX)
            Sleep(1);
        #endif        
        CloseHandle(hCom);
        #ifdef Thread
        Sleep(1);
        CloseHandle(RX_Mutex);
        CloseHandle(Thread1);
        #endif
        hCom = NULL;
    }
}

void help() 
{
	printf("Format1:  \n");
	printf("		s = SerialIO('open','port', baud);\n");
	printf("Ports:\n");
	printf("		'com1', 'com2' \n");
	printf("Bauds:  \n");
	printf("		300, 4800, 9600, 19200, 38400, 57600, 115200, 230400\n");
    printf("s:    \n");
    printf("		Is true if open success\n");
    printf("**Note: 'port' must be entered in quotes. 8N1 \n");
    printf("Default comunication in 8N1 \n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format2:  \n");
	printf("		SerialIO('close');\n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format3:  \n");
	printf("		y = SerialIO('read',Size);\n");
	printf("Size:\n");
	printf("		A Row Vector Size of your choice!\n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format4:  \n");
	printf("		SerialIO('write',x,Size);\n");
    printf("x:\n");
	printf("		Vector to send\n");
	printf("Size:\n");
	printf("		A x Row Vector Size \n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format5:  \n");
	printf("		SerialIO('clearRX');\n");
    printf("Clear de input buffer\n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format6:  \n");
	printf("		SerialIO('clearTX');\n");
    printf("Clear de output buffer\n");
    printf("-----------------------------------------------------------\n\n");
    printf("Format7:  \n");
	printf("		SerialIO('setupcomm',InQueue,OutQueue);\n");
    printf("Setup zise of input and output buffer\n");
    #ifdef Thread
    printf("-----------------------------------------------------------\n\n");
    printf("Format8:  \n");
	printf("		s = SerialIO('stateRX');\n");
    printf("s:    \n");
    printf("		Is true if char in RX buffer\n");
    #endif
	printf("-----------------------------------------------------------\n");
}




void PrintError(LPCSTR str)
{
   LPVOID lpMessageBuffer;
   int error = GetLastError();
   FormatMessage(
      FORMAT_MESSAGE_ALLOCATE_BUFFER |
      FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      error,
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), //The user default language
      (LPTSTR) &lpMessageBuffer,
      0,
      NULL
   );
   printf("%s: (%d) %s\n\n",str,error,lpMessageBuffer);
   help();
   LocalFree( lpMessageBuffer );
}


void Receive(HANDLE h)
{
    HANDLE hconn = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD mask;
    DWORD i;
    OVERLAPPED ov;
	int StopStream=0;


	
   #ifdef Thread
   WaitForSingleObject(RX_Mutex, INFINITE);
   WaitForRX = 1 ;
   ReleaseMutex(RX_Mutex);
   #endif
    //Initialization and Set-Up
   ZeroMemory(&ov,sizeof(ov));

   // create event for overlapped I/O
   ov.hEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
   if(ov.hEvent == INVALID_HANDLE_VALUE)
      PrintError("E006_CreateEvent failed");

   // wait for received characters
   if(!SetCommMask(h,EV_RXCHAR))
      PrintError("E007_SetCommMask failed");

   //Get the Data 
   while(1)
   {
      // get the event mask
      if( !WaitCommEvent(h,&mask,&ov) ) 
      {
         DWORD e = GetLastError();
         if( e == ERROR_IO_PENDING ) 
         {
            DWORD r;
            if( !GetOverlappedResult(h,&ov,&r,TRUE) ) 
            {
               PrintError("E008_GetOverlappedResult failed");
               break;
            }
         } 
         else 
         {
            PrintError("E009_WaitCommEvent failed");
            break;
         }
      }

      //There was an error getting the mask.
      if(mask == 0) 
	  {
         break;
      }

      if( mask & EV_RXCHAR) 
      {
         char buf[100];
         DWORD read;
         DWORD numread;
         do 
         {
            read = 0;
            numread = NumPoints - StopStream;
            if (numread>sizeof(buf))
                numread=sizeof(buf);
            if( !ReadFile(h,buf,numread,&read,&ov) ) 
            {
               if( GetLastError() == ERROR_IO_PENDING ) 
               {
                  if( !GetOverlappedResult(h,&ov,&read,TRUE) ) 
                  {
                     PrintError("E010_GetOverlappedResult failed");
                     break;
                  }
               } 
               else 
               {
                  PrintError("E011_ReadFile failed");
                  break;
               }
            }
            
            //Read Data 
            for (i=0; i<read; i++) 
            {
                //Write to matlab vector
                if(StopStream < NumPoints)
                {
                    SerialData[StopStream] = (unsigned char)buf[i];					
					StopStream++;
                }
                else
				{
					CloseHandle(ov.hEvent);
                    #ifdef Thread
                    WaitForSingleObject(RX_Mutex, INFINITE);
                    WaitForRX = 0 ;
                    ReleaseMutex(RX_Mutex);
                    #endif
                    return;
				}
            }
            if(StopStream = NumPoints){
                CloseHandle(ov.hEvent);
                #ifdef Thread
                WaitForSingleObject(RX_Mutex, INFINITE);
                WaitForRX = 0 ;
                ReleaseMutex(RX_Mutex);
                #endif
                return;
            }
        } while(StopStream < NumPoints);
      }
      //Clear Mask
      mask = 0;
   }
   //Close the Event
   CloseHandle(ov.hEvent);
   #ifdef Thread
   WaitForSingleObject(RX_Mutex, INFINITE);
   WaitForRX = 0 ;
   ReleaseMutex(RX_Mutex);
   #endif
 }
 
#ifdef Thread
int State_RXCHAR()
{int StateResult = 0;
    WaitForSingleObject(RX_Mutex, INFINITE);
        StateResult = WaitForRX;
    ReleaseMutex(RX_Mutex);
    return StateResult;
}
#endif
 
 void openSerial(char *portname, int baud)
{
    char portname_w32[255];
    COMMCONFIG lpCC;
    COMMTIMEOUTS lpTo;
    int CBR_baud;

    SerialData[0]=1;
    // Win32 can't open >= COM10 with "COM10"
    // Needs to be \\.\COM10
    #ifndef _MSC_VER
    sprintf(portname_w32, "\\\\.\\%s", portname);
    #else
    sprintf_s(portname_w32, "\\\\.\\%s", portname);
    #endif
    
	
    
    switch(baud) {
        case 9600:
            CBR_baud = CBR_9600;
            break;
        case 19200:
            CBR_baud = CBR_19200;
            break;
        case 38400:
            CBR_baud = CBR_38400;
            break;
        case 57600:
            CBR_baud = CBR_57600;
            break;
        case 115200:
            CBR_baud = CBR_115200;
            break;
        case 230400: // It seems Windows doesn't need CBR for these
        case 460800:
        default:
             CBR_baud = baud;
        break;
    } 

    if (hCom != NULL) {
        mexWarnMsgTxt("Already have an open port, closing first");
        //closeSerial();
        SerialData[0]=0;
    }

    hCom = CreateFile(portname_w32, GENERIC_READ|GENERIC_WRITE, 0, NULL,
                      OPEN_EXISTING, 0, NULL);

    if (hCom == INVALID_HANDLE_VALUE) {
        hCom = NULL;
        SerialData[0]=0;
        PrintError("E012_Failed to open port");
        //mexErrMsgTxt("Could not open serial port");        
    }    
    mexAtExit(closeSerial);

    GetCommState( hCom, &lpCC.dcb);

    lpCC.dcb.BaudRate = CBR_baud;
    lpCC.dcb.ByteSize = 8;
    lpCC.dcb.StopBits = ONESTOPBIT;
    lpCC.dcb.Parity = NOPARITY;

    lpCC.dcb.fDtrControl = DTR_CONTROL_DISABLE;
    lpCC.dcb.fRtsControl = RTS_CONTROL_DISABLE;
    if(!SetCommState( hCom, &lpCC.dcb )){
      SerialData[0]=0;
      PrintError("E014_SetCommState failed");
    }

    GetCommTimeouts(hCom, &lpTo);
    lpTo.ReadIntervalTimeout = 0;
    lpTo.ReadTotalTimeoutMultiplier = 10;
    lpTo.ReadTotalTimeoutConstant = 10;
    lpTo.WriteTotalTimeoutMultiplier = 10;
    lpTo.WriteTotalTimeoutConstant = 100;

    if(!SetCommTimeouts(hCom, &lpTo))
      PrintError("E013_SetCommTimeouts failed");
    
    SetupComm(hCom, 2048, 2048);
    #ifdef Thread
    if(!(hCom==NULL)){
        RX_Mutex = CreateMutex(NULL, FALSE, NULL);    
        EndWaitForRX = 0 ;
        WaitForRX = 0 ;
        Thread1 = (HANDLE)_beginthread( &PolingWaitCommEvent, 0, NULL );
    }
    #endif
}
 
int writeSerial(char *TXdata,int NumP) {
DWORD bytesWritten;
    if (hCom == NULL)
        mexErrMsgTxt("Cannot write. Open serial port first");
    //printf("Writing Serial: [%s]\n", TXdata);    

    if ( WriteFile(hCom, TXdata, NumP, &bytesWritten, NULL) ) {
        return bytesWritten;
    } else {        
        char err_str[128];
        #ifndef _MSC_VER
        sprintf(err_str, "Could not write %d", GetLastError());
        #else
        sprintf_s(err_str, "Could not write %d", GetLastError());
        #endif
        mexErrMsgTxt(err_str);
    }
    return 0;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//Declarations
    char *commandName;
    int commandNum = 0;
	char *In0;
    int Length0;
	mxArray *InArray;
    double *xValues;
    char *xCharData;
	int Baud;
    int ErrorParsec = 1;
    DWORD InQueue, OutQueue;

    
	//Convert the Inputs
    if(nrhs >= 1){
        commandName = (char *) mxArrayToString(prhs[0]);
        if( (strcmp(commandName,"open")== 0)&&(nrhs == 3)&&(nlhs ==1))
        {
            //Get Port
            if (mxIsChar(prhs[1]) != 1)
            {
                mexErrMsgTxt("Input 1 must be a string 'com1' or 'com2' ");
            }
            else
            {
                Length0 = mxGetN(prhs[1])+1;
                In0 =(char *) mxCalloc(Length0, sizeof(char));
                mxGetString(prhs[1],In0,Length0);
                //Get Baud
                Baud = (int)mxGetScalar(prhs[2]);
                //Set up Output array
                plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
                SerialData = mxGetPr(plhs[0]);
                ErrorParsec = 0;
                commandNum = 1;
            }            
        }
        if( (strcmp(commandName,"write")== 0)&&(nrhs = 3))
        {
            int i;
            //Get Size
            NumPoints = (int)mxGetScalar(prhs[2]);
            InArray=(mxArray *)prhs[1];
            xValues = mxGetPr(InArray);
            xCharData= (char *) mxCalloc(NumPoints+1, sizeof(char));
            for(i=0;i<NumPoints;i++)
            {
                xCharData[i]=(unsigned char)xValues[i];
            }
            if(nlhs==1){
                plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
                SerialData = mxGetPr(plhs[0]);
            }
            ErrorParsec = 0;
            commandNum = 2;
        }
        if( (strcmp(commandName,"read")== 0)&&(nrhs = 2)&&(nlhs ==1))
        {            
            //Get Size
            NumPoints = (int)mxGetScalar(prhs[1]);
            //Set up Output array
            plhs[0] = mxCreateDoubleMatrix(1,NumPoints,mxREAL);
            SerialData = mxGetPr(plhs[0]);
            ErrorParsec = 0;
            commandNum = 3;
        }
        if( (strcmp(commandName,"close")== 0)&&(nrhs = 1))
        {
            ErrorParsec = 0;
            commandNum = 4;
        }
        if( (strcmp(commandName,"clearRX")== 0)&&(nrhs = 1))
        {
            ErrorParsec = 0;
            commandNum = 5;
        }
        if( (strcmp(commandName,"clearTX")== 0)&&(nrhs = 1))
        {
            ErrorParsec = 0;
            commandNum = 6;
        }
        if( (strcmp(commandName,"setupcomm")== 0)&&(nrhs = 3))
        {
            InQueue = (DWORD)mxGetScalar(prhs[1]);
            OutQueue = (DWORD)mxGetScalar(prhs[2]);
            ErrorParsec = 0;
            commandNum = 7;
        }
        #ifdef Thread
        if( (strcmp(commandName,"stateRX")== 0)&&(nrhs == 1)&&(nlhs ==1))
        {            
            //Set up Output array
            plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
            SerialData = mxGetPr(plhs[0]);
            ErrorParsec = 0;
            commandNum = 8;            
        }
        #endif
    }

	
   //I Dont know why, but the compiler needs this conditional here also.
   //Set up Port and get Data   
   if((ErrorParsec==0)&&(commandNum>0)) 
   {
      if(commandNum==1){                
        openSerial(In0, Baud);
      }
      if(commandNum==2){
          int BytesWritten;
          BytesWritten = writeSerial(xCharData,NumPoints);
          mxFree(xCharData);
          if(nlhs==1){              
              SerialData[0] = BytesWritten;
          }
      }
      if(commandNum==3){
          if (hCom==NULL) {
              mexErrMsgTxt("Cannot read. Open serial port first");
          }
          Receive(hCom);          
      }
      if(commandNum==4){
          if (hCom==NULL) {
              mexErrMsgTxt("Failed to close port");
          }
          closeSerial();
      }
      if(commandNum==5){
          if (hCom==NULL) {
              mexErrMsgTxt("Failed to clear port");
          }
          #ifdef Thread
          WaitForSingleObject(RX_Mutex, INFINITE);
          #endif
          PurgeComm(hCom,  PURGE_RXABORT | PURGE_RXCLEAR);
          #ifdef Thread
          WaitForRX = 0 ;
          ReleaseMutex(RX_Mutex);
          #endif
      }
      if(commandNum==6){
          if (hCom==NULL) {
              mexErrMsgTxt("Failed to clear port");
          }
          PurgeComm(hCom,  PURGE_TXABORT | PURGE_TXCLEAR);
      }
      if(commandNum==7){
          if (hCom==NULL) {
              mexErrMsgTxt("Failed to setup port");
          }
          SetupComm(hCom , InQueue , OutQueue);
      }
      #ifdef Thread
      if(commandNum==8){
          if (hCom==NULL) {
              mexErrMsgTxt("Cannot read State. Open serial port first");
          }
          SerialData[0] = State_RXCHAR();
      }
      #endif
   } 
   else 
   {
	    if(nlhs == 1)
			plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	    printf("                                                      \n");
        printf("--------------        SerialIO       -----------------\n");
        printf("        Universidad Nacional de Tucuman               \n");
		printf("                                                      \n");
        help();
   }
   return;
}
