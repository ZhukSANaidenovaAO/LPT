#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <iostream>
#include <string>

using namespace std;

void send_byte(HANDLE hLPT, int perem)
{
	DWORD bytes;
	char perem_char;
	perem_char = (char)perem;
	WriteFile(hLPT, &perem_char, 1, &bytes, NULL);
	cout << perem_char;
}

int exit(HANDLE hLPT)
{
	send_byte(hLPT, 13);
	send_byte(hLPT, 10);
	CloseHandle(hLPT);
	return 0;
}

int main()
{
	HANDLE hLPT;
	hLPT = CreateFile("LPT1", GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
	if (hLPT == INVALID_HANDLE_VALUE)
	{
		printf("Could not open file (error %d)\n", GetLastError());
		return exit(hLPT);
	}

	bool input = true;
	int perem;
	while(input)
	{
		perem = getch();
		if(perem == 27)
		{
			return exit(hLPT);
		}
		if(perem == 13)
		{
			send_byte(hLPT, 13);
			send_byte(hLPT, 10);
		}else{
			send_byte(hLPT, perem);
		}
	}
	return exit(hLPT);
}
