.MODEL tiny

.CODE

ORG 100h

start:
.486
;	�������������� LPT
	call init

;	����������� ������� ���������.
mp1:	call analis

	;	������� ������� ��������� � h-���� �� �����.
		mov dL,aL
		call VIVOD_CH

	;	���� ������� ��������� ����� 0D8h ��������, ����� ������� ��������������.
		CMP AL,0D8h
		JE mp2

	;	������� ��������������
		LEA DX,ERROR
		MOV AH,09H
		INT 21h

	;	������ ������ � ����������.
		MOV AH,01h
		INT 21h

	;	���� ������ '0' �� ������� �� ���������, ����� ����������� ������
		CMP AL,'0'
		JE mp3
		jmp mp1

	mp2:
	;	������ ������ � ����������.
		MOV AH,01h
		INT 21h

	;	���� ������ '0' �� ������� �� ���������, ����� ����������� ������
		CMP AL,'0'
		JE mp3

	;	����� ����� �� �������.
		CALL VIVOD_CH_IN_PRINTER
		jmp mp2

		

	mp3:
	 



; ���������, ��������� ����� �� �����
VIVOD_CH Proc 
			PUSHA
			MOV BL,AL
			MOV AH,02h
			MOV DL,BL
			MOV CL,04h
			SHR DL,CL
			ADD DL,30h
			CMP DL,3Ah
			JL metka2_1
			ADD DL,07h
		metka2_1:	INT 21h
			MOV DL,BL
			AND DL,0Fh
			ADD DL,30h
			CMP DL,3Ah
			JL metka2_2
			ADD Dl,07h
		metka2_2: INT 21h
			POPA
	RET
VIVOD_CH ENDP

;��������� ���������������� ������� ����������.

init proc

		PUSH AX
		PUSH DX

	;	��������� ���� �������� ����������.
		MOV AL,00001100b
		MOV DX,037Ah
		OUT DX,AL

		POP DX
		POP AX

	;	�������� ��������� ���������.
		RET
init ENDP

;��������� ������� ������ �� AL �� �������.

VIVOD_CH_IN_PRINTER Proc 
	; ���������� �������� � ����
		PUSHA
			
	;	��������� ���� �� AL � ������� ������.
		MOV DX,0378h
		OUT DX,AL
			
			;	������������� STRB �������� 1.
		MOV AL,00001101b
		MOV DX,037Ah
		OUT DX,AL

	;	������������� STRB �������� 0.
		MOV AL,00001100b
		MOV DX,037Ah
		OUT DX,AL

	; 	��������� �������� AX � DX �� �����
		POPA

	;	�������� ��������� ���������.
		RET
			POPA
	RET
VIVOD_CH_IN_PRINTER ENDP

; ����������� ��������� ��������
analis proc

		PUSH BX
		PUSH DX

	;	������ ������� ���������� LPT.
		MOV DX,0379h
		IN AL,DX
		MOV BL,AL

	;	����������� 7-� ���. BUSY ���������� ��������������� ��������� ����� ������
		TEST BL,10000000b
		JZ metka1_1
		LEA DX,BUSY1
		JMP metka1_2
metka1_1:  	LEA DX,BUSY0
metka1_2:	MOV AH,09h
		INT 21h

	;	����������� 6-� ���. ��� ���������� ��������������� ��������� ���������� � ������ ���������� �����
		TEST BL,01000000b
		JZ metka1_3
		LEA DX,ACK1
		JMP metka1_4
metka1_3:  	LEA DX,ACK0
metka1_4:	MOV AH,09h
		INT 21h

	;	����������� 5-� ���. �� ���������� ������� ������ �� �������� � ��������� ������. 
	;	��� ��������������� � 1, ����� ������� ������������ ������ ����� ������ (Paper End).
		TEST BL,00100000b
		JZ metka1_5
		LEA DX,PE1
		JMP metka1_6
metka1_5:  	LEA DX,PE0
metka1_6:	MOV AH,09h
		INT 21h

	;	����������� 4-� ���.SEL ��������� ������� ��������� ������� ������� (Select) � ��������������� � 1, ����� ���������� ���� �������.
		TEST BL,00010000b
		JZ metka1_7
		LEA DX,SEL1
		JMP metka1_8
metka1_7:  	LEA DX,SEL0
metka1_8:	MOV AH,09h
		INT 21h

	;	����������� 3-� ���. ERR ������ ��������������� ��������� ������ � ����������. 
	;	��� ��������������� � 0 ��� ��������� ��������� ������� ������ (Error).
		TEST BL,00001000b
		JZ metka1_9
		LEA DX,ERR1
		JMP metka1_10
metka1_9:  	LEA DX,ERR0
metka1_10:	MOV AH,09h
		INT 21h

	;	����������� 2-� ���. IRQS ��������� �������� 0, ����� ���������� ����������� ����� ����������� ����� ���������� �������� ������������� 
		TEST BL,00000100b
		JZ metka1_11
		LEA DX,IRQS1
		JMP metka1_12
metka1_11:  LEA DX,IRQS0
metka1_12:	MOV AH,09h
		INT 21h

		mov al,bl

		POP DX
		POP BX

	;	�������� ��������� ���������.
		RET
analis ENDP

	; ������������� ����������
	Msg DB 'Byte in DL=$'

	BUSY1 DB ' YSTROYSTVO SVOBODNO',0ah,0dh,'$'

	BUSY0 DB ' YSTROYSTVO ZANATO',0ah,0dh,'$'

	ACK1 DB ' YSTROYSTVO NE GOTOVO K PRIEMY',0ah,0dh,'$'

	ACK0 DB ' YSTROYSTVO GOTOVO K PRIEMY',0ah,0dh,'$'

	PE1 DB ' NET BYMAGI',0ah,0dh,'$'

	PE0 DB ' BYMAGA EST',0ah,0dh,'$'

	SEL1 DB ' YSTROYSTVO VIBRANO',0ah,0dh,'$'

	SEL0 DB ' YSTROYSTVO NE VIBRANO',0ah,0dh,'$'

	ERR1 DB ' OSHIBOK NET',0ah,0dh,'$'

	ERR0 DB ' EST OSHIBKA',0ah,0dh,'$'

	IRQS1 DB ' SIGNAL PODTVERZDENIA OTSUTSTVYET',0ah,0dh,'$'

	IRQS0 DB ' SIGNAL PODTVERZDENIA POLUCHEN',0ah,0dh,'$'


	ERROR DB 'oshibka',0ah,0dh,'$'

END start