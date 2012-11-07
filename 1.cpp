#include <iostream>
#include "windows.h"
#define IOCTL_IEEE1284_GET_MODE CTL_CODE (FILE_DEVICE_PARALLEL_PORT, 5, METHOD_BUFFERED, FILE_ANY_ACCESS)
using namespace std;
int main()
{	
	
	HANDLE hLpt=CreateFile("LPT1",GENERIC_WRITE,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);//connect to LPT
	
	//char buffer[100];

	char buf[100];
	strcpy(buf,"h");
	DWORD ret;
	char Mode[100];
	OVERLAPPED ov;
	DeviceIoControl(hLpt,IOCTL_IEEE1284_GET_MODE,NULL,0,&Mode,sizeof(Mode),&ret,NULL);//default mode
	BOOL res=WriteFile(hLpt,&buf,strlen(buf),&ret,NULL);//write to LPT
	CloseHandle(hLpt);//free LPT
	return 0;

}