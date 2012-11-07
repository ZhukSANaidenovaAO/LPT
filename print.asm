.MODEL tiny

.CODE

ORG 100h

start:
.486
;	инициализируем LPT
	call init

;	анализируем регистр состояния.
mp1:	call analis

	;	выводим регистр состояния в h-виде на экран.
		mov dL,aL
		call VIVOD_CH

	;	если регистр состояния равен 0D8h печатаем, иначе выводим предупреждение.
		CMP AL,0D8h
		JE mp2

	;	выводим предупреждение
		LEA DX,ERROR
		MOV AH,09H
		INT 21h

	;	вводим символ с клавиатуры.
		MOV AH,01h
		INT 21h

	;	если введен '0' то выходим из программы, иначе анализируем дальше
		CMP AL,'0'
		JE mp3
		jmp mp1

	mp2:
	;	вводим символ с клавиатуры.
		MOV AH,01h
		INT 21h

	;	если введен '0' то выходим из программы, иначе анализируем дальше
		CMP AL,'0'
		JE mp3

	;	вывод байта на принтер.
		CALL VIVOD_CH_IN_PRINTER
		jmp mp2

		

	mp3:
	 



; процедура, выводящая число на экран
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

;процедура инициализирующая регистр управления.

init proc

		PUSH AX
		PUSH DX

	;	загружаем байт регистра управления.
		MOV AL,00001100b
		MOV DX,037Ah
		OUT DX,AL

		POP DX
		POP AX

	;	коректно завершаем программу.
		RET
init ENDP

;процедура выводит символ из AL на принтер.

VIVOD_CH_IN_PRINTER Proc 
	; сохранаяем регистры в стек
		PUSHA
			
	;	загружаем байт из AL в регистр данных.
		MOV DX,0378h
		OUT DX,AL
			
			;	устанавливаем STRB значение 1.
		MOV AL,00001101b
		MOV DX,037Ah
		OUT DX,AL

	;	устанавливаем STRB значение 0.
		MOV AL,00001100b
		MOV DX,037Ah
		OUT DX,AL

	; 	возращаем регистры AX и DX из стека
		POPA

	;	коректно завершаем программу.
		RET
			POPA
	RET
VIVOD_CH_IN_PRINTER ENDP

; анализируем состояние принтера
analis proc

		PUSH BX
		PUSH DX

	;	читаем регистр сосотояния LPT.
		MOV DX,0379h
		IN AL,DX
		MOV BL,AL

	;	анализируем 7-й бит. BUSY определяет инвертированное состояние линии занято
		TEST BL,10000000b
		JZ metka1_1
		LEA DX,BUSY1
		JMP metka1_2
metka1_1:  	LEA DX,BUSY0
metka1_2:	MOV AH,09h
		INT 21h

	;	анализируем 6-й бит. АСК показывает инвертированное состояние готовности к приему очередного байта
		TEST BL,01000000b
		JZ metka1_3
		LEA DX,ACK1
		JMP metka1_4
metka1_3:  	LEA DX,ACK0
metka1_4:	MOV AH,09h
		INT 21h

	;	анализируем 5-й бит. РЕ показывает текущий сигнал от принтера о состоянии бумаги. 
	;	Бит устанавливается в 1, когда принтер вырабатывает сигнал конец бумаги (Paper End).
		TEST BL,00100000b
		JZ metka1_5
		LEA DX,PE1
		JMP metka1_6
metka1_5:  	LEA DX,PE0
metka1_6:	MOV AH,09h
		INT 21h

	;	анализируем 4-й бит.SEL указывает текущее состояние сигнала выборка (Select) и устанавливается в 1, когда устройство было выбрано.
		TEST BL,00010000b
		JZ metka1_7
		LEA DX,SEL1
		JMP metka1_8
metka1_7:  	LEA DX,SEL0
metka1_8:	MOV AH,09h
		INT 21h

	;	анализируем 3-й бит. ERR задаст инвертированное состояние ошибки в устройстве. 
	;	Бит устанавливается в 0 при выработке принтером сигнала ошибки (Error).
		TEST BL,00001000b
		JZ metka1_9
		LEA DX,ERR1
		JMP metka1_10
metka1_9:  	LEA DX,ERR0
metka1_10:	MOV AH,09h
		INT 21h

	;	анализируем 2-й бит. IRQS принимает значение 0, когда устройство подтвердило прием предыдущего байта информации сигналом подтверждения 
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

	;	коректно завершаем программу.
		RET
analis ENDP

	; инициализация переменных
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