TITLE Designing Low-Level I/O Procedures & Macros     (Proj6_thompsti.asm)

; Author: Tim Thompson
; Last Modified: 11/25/20
; OSU email address: thompsti@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:       6         Due Date: 12/6/20
; Description:	This program will request and obtain 10 signed decimal integers from the user.
;				Each number is validated to ensure that it is small enough to fit inside a
;				32 bit register. Once the 10 raw numbers have been inputted and validated, a
;				list of the numbers that the user entered is displayed. The program will then
;				compute the sum of the numbers, and their rounded average, and the results of
;				these computations are then displayed to the user. Finally, a goodbye message
;				is displayed.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------
; Name: mGetString
;
; Prompt user to provide a signed integer number that fits inside a
; SDWORD and then store user input as string.
;
; Preconditions:	Prompt is initialized and is a BYTE array containing
;					the user prompt to display. userInput is initialized
;					and is a BYTE array. userInputLength is initialized
;					and is a DWORD.
;
; Postconditions: None.
;
; Receives:
;		prompt = address of user prompt to display
;		userInput = address of buffer array to store user input
;		userInputLength = address of buffer size to store input length
;
; Returns:
;		userInput contains string of number entered by user.
;		userInputLength contains length of string entered by user.
; ---------------------------------------------------------------------
mGetString	MACRO prompt:REQ, userInput:REQ, userInputLength:REQ
	PUSHAD

	; Prompt user for signed integer number
	MOV		EDX, prompt
	CALL	WriteString

	; Store user input
	MOV		EDX, userInput
	MOV		ECX, 30
	CALL	ReadString

	; Store size of user input
	MOV		[userInputLength], EAX

	POPAD
ENDM

	MINVALIDVAL = -2147483648
	MAXVALIDVAL = 2147483647

.data

	introMessage	BYTE	"Designing Low-Level I/O Procedures & Macros by Tim Thompson",13,10,13,10,0
	instructions	BYTE	"Please provide 10 signed decimal integers.",13,10
					BYTE	"Each number needs to be capable of fitting inside a 32 bit register. After you have finished entering",13,10
					BYTE	"the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	numberPrompt	BYTE	"Please enter a signed number: ",0
	errorMessage	BYTE	"ERROR: Your number was too big, you did not enter a signed number, or your entry was blank. Please try again.",13,10,0
	buffer			BYTE	30 DUP(?)
	bufferSize		DWORD	0
	isNumberValid	DWORD	0

.code
main PROC

	; Introduce program to user and display instructions
	PUSH	OFFSET introMessage
	PUSH	OFFSET instructions
	CALL	introduction

	; Request signed integer number from user
	PUSH	MINVALIDVAL
	PUSH	MAXVALIDVAL
	PUSH	OFFSET errorMessage
	PUSH	OFFSET isNumberValid
	PUSH	OFFSET numberPrompt
	PUSH	OFFSET buffer
	PUSH	OFFSET bufferSize
	CALL	ReadVal

	Invoke ExitProcess,0	; Exit to operating system
main ENDP

; ---------------------------------------------------------------------
; Name: introduction
;
; Displays an introduction message with author name to the user and
; then displays instructions for the user.
;
; Receives:
;		[EBP+8] = reference to program instructions.
;		[EBP+12] = reference to introduction message.
; ---------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Display introduction to user
	MOV		EDX, [EBP+12]
	CALL	WriteString

	; Display program instructions to user
	MOV		EDX, [EBP+8]
	CALL	WriteString

	POPAD
	POP		EBP
	RET		8
introduction ENDP

; ---------------------------------------------------------------------
; Name: ReadVal
;
; Obtain a signed integer number from the user, validate that it is a
; valid signed integer number which can fit in a 32 bit register, and
; then store the validated number in buffer. The length of the string
; entered by the user is stored in bufferSize. If the number is invalid
; then another number is requested from the user, until a valid number
; is provided.
;
; Preconditions:	Buffer is a BYTE array, buffer size is a DWORD.
;					User prompt is a BYTE array containing prompt to
;					display to user. errorMessage is a BYTE array
;					containing an error message to display to user
;					if the number is invalid. Max and min valid values
;					are	initialized to SDWORD upper and lower boundaries.
;
; Postconditions:	isNumberValid contains a 1 if the number entered
;					by the user is valid, 0 if the number is invalid.
;
; Receives:
;		[EBP+8] = reference to buffer size for user input.
;		[EBP+12] = reference to buffer for user input.
;		[EBP+16] = reference to user prompt.
;		[EBP+20] = reference to boolean isNumberValid.
;		[EBP+24] = reference to error message for invalid entry.
;		[EBP+28] = reference to max valid value for number.
;		[EBP+32] = reference to min valid value for number.
;
; Returns:
;		buffer is populated with string of number input by user.
;		buffer size is populated with length of user inputted number.
; ---------------------------------------------------------------------
ReadVal PROC
	PUSH		EBP
	MOV			EBP, ESP
	PUSHAD

	; Get address of parameters to pass to macro
	MOV			EDI, [EBP+8]

_GetNumber:

	; Call macro to get and store number input by user
	mGetString	[EBP+16], [EBP+12], EDI

	; Validate user input to ensure it is not empty and is a number
	PUSH		[EBP+20]
	PUSH		[EBP+12]
	PUSH		[EBP+8]
	CALL		ValidateInput

	; Validate number to ensure it fits in the boundaries of a SDWORD
	PUSH		[EBP+32]
	PUSH		[EBP+28]
	PUSH		[EBP+20]
	PUSH		[EBP+12]
	PUSH		[EBP+8]
	CALL		ValidateNumber

	; Check if number is valid, and if not, display error message
	; then prompt user to enter another number
	MOV			ESI, [EBP+20]
	MOV			AL, [ESI]
	CMP			AL, 1
	JZ			_DoneReadingValue
	MOV			EDX, [EBP+24]
	CALL		WriteString
	JMP			_GetNumber

_DoneReadingValue:
	POPAD
	POP		EBP
	RET		28
ReadVal ENDP

; ---------------------------------------------------------------------
; Name: ValidateInput
;
; Validate the user input passed into the buffer. The user input stored
; in buffer is checked to ensure it is not an empty string and it does
; not have non-numeric characters in it.
;
; Preconditions:	Buffer is a BYTE array, buffer size is a DWORD, and
;					isValid is a BYTE. Buffer contains the string input
;					by the user and buffer size contains the length of
;					the string input by the user.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = reference to buffer size for user input.
;		[EBP+12] = reference to buffer for user input.
;		[EBP+16] = reference to isValid boolean.
;
; Returns:
;		isValid as 1 if input is valid, 0 if input is invalid.
; ---------------------------------------------------------------------
ValidateInput PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Store parameters for validation
	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]
	MOV		EBX, [EBP+16]

	; Check if buffer is an empty string, and if so, validation is done
	CMP		ECX, 0
	JZ		_ValidationFail

	; Check if any invalid characters are in user input
	CLD
_CheckUserInput:
	LODSB
	CMP		AL, 48
	JL		_CheckSign
	CMP		AL, 57
	JG		_CheckSign

_CheckSignPass:
	LOOP	_CheckUserInput

	; If loop finishes and all characters are valid, validation is successful
	JMP		_ValidationSuccess

	; If ASCII character is less than 48, or greater than 58, check if it is + or -
	; If character is + or -, continue checking user input, otherwise validation is done
_CheckSign:
	CMP		AL, 43
	JZ		_CheckSignPass
	CMP		AL, 45
	JNZ		_ValidationFail
	JMP		_CheckSignPass

_ValidationFail:
	; If any checks fail, return isValid as 0
	MOV		DWORD PTR [EBX], 0
	JMP		_ValidationDone

_ValidationSuccess:
	; If all checks pass, return isValid as 1
	MOV		DWORD PTR [EBX], 1

_ValidationDone:
	POPAD
	POP		EBP
	RET		12
ValidateInput ENDP

; ---------------------------------------------------------------------
; Name: ValidateNumber
;
; Validate the number entered by the user to ensure that it fits inside
; the min/max of a SDWORD, so that it is capable of fitting inside a
; 32 bit register.
;
; Preconditions:	Buffer is a BYTE array, buffer size is a DWORD, and
;					isValid is a BYTE. Max and min valid values are
;					initialized to SDWORD upper and lower boundaries.
;					Buffer contains the string input by the user and
;					buffer size contains the length of the string input
;					by the user.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = reference to buffer size for user input.
;		[EBP+12] = reference to buffer for user input.
;		[EBP+16] = reference to isValid boolean.
;		[EBP+20] = reference to max valid value for number.
;		[EBP+24] = reference to min valid value for number.
;
; Returns:
;		isValid as 1 if input is valid, 0 if input is invalid.
; ---------------------------------------------------------------------
ValidateNumber PROC
	LOCAL	numToCheck:SDWORD
	MOV		numToCheck, 0
	PUSHAD

	; Store parameters for validation
	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]

	; Compute number from user input string
	CLD
_ComputeNumber:
	MOV		EAX, numToCheck
	MOV		EDX, 10
	MUL		EDX
	PUSH	EAX
	LODSB
	SUB		AL, 48
	MOVSX	EBX, AL
	POP		EAX
	ADD		EAX, EBX
	CMP		EAX, [EBP+20]
	JO		_NumberInvalid
	MOV		numToCheck, EAX

	LOOP	_ComputeNumber

_NumberValid:
	; If number is within SDWORD bounds, return isValid as 1
	MOV		EBX, [EBP+16]
	MOV		DWORD PTR [EBX], 1
	JMP		_ValidationComplete

_NumberInvalid:
	; If number is outside SDWORD bounds, return isValid as 0
	MOV		EBX, [EBP+16]
	MOV		DWORD PTR [EBX], 0

_ValidationComplete:

	POPAD
	RET		20
ValidateNumber ENDP

END main