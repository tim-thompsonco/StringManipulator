TITLE Designing Low-Level I/O Procedures & Macros     (Proj6_thompsti.asm)

; Author: Tim Thompson
; Last Modified: 11/27/20
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
	MOV		ECX, 11
	CALL	ReadString

	; Store size of user input
	MOV		[userInputLength], EAX

	POPAD
ENDM

; ---------------------------------------------------------------------
; Name: mShowIntroduction
;
; Displays an introduction message with author name to the user and
; then displays instructions for the user.
;
; Receives:
;		introMessage = reference to address of introduction message.
;		instructions = reference to address of program instructions.
; ---------------------------------------------------------------------
mShowIntroduction	MACRO introMessage:REQ, instructions:REQ
	PUSH	EDX

	; Display introduction to user
	MOV		EDX, OFFSET introMessage
	CALL	WriteString

	; Display program instructions to user
	MOV		EDX, OFFSET instructions
	CALL	WriteString

	POP		EDX
ENDM

; ---------------------------------------------------------------------
; Name: mShowGoodbye
;
; Displays a goodbye message to the user.
;
; Receives:
;		goodbyeMessage = reference to address of goodbye message.
; ---------------------------------------------------------------------
mShowGoodbye	MACRO goodbyeMessage:REQ
	PUSH	EDX

	; Display goodbye message to user
	MOV		EDX, OFFSET goodbyeMessage
	CALL	WriteString

	POP		EDX
ENDM

; ---------------------------------------------------------------------
; Name: mShowErrorMessage
;
; Displays an error message to the console.
;
; Receives:
;		errorMessage = reference to address of error message.
; ---------------------------------------------------------------------
mShowErrorMessage	MACRO errorMessage:REQ
	PUSH	EDX

	MOV		EDX, errorMessage
	CALL	WriteString

	POP		EDX
ENDM

; ---------------------------------------------------------------------
; Name: mGetValues
;
; Get 10 signed integer numbers from user which fit inside a SDWORD and
; populate an array with the validated numbers.
;
; Preconditions:	Prompt is initialized and is a BYTE array containing
;					the user prompt to display. userInput is initialized
;					and is a BYTE array. userInputLength is initialized
;					and is a DWORD.
;
; Postconditions: None.
;
; Receives:
;		numsToGet = reference to constant value of numbers to read in.
;		numArr = reference to address of array to store validated numbers.
;		minVal = reference to constant value of min valid value for number.
;		maxVal = reference to constant value max valid value for number.
;		errorMsg = reference to address of error message for invalid entry.
;		isNumValid = reference to address of boolean isNumberValid.
;		numPrompt = reference to address of user prompt.
;		inputBuffer = reference to address of buffer to store user input.
;		inputBufferSize = reference to address to store length of user input.
;
; Returns:
;		buffer is populated with string of number input by user.
;		buffer size is populated with length of user inputted number.
;		numArr contains validated numbers input by user.
; ---------------------------------------------------------------------
mGetValues	MACRO numsToGet:REQ, numArr:REQ, minVal:REQ, maxVal:REQ, errorMsg:REQ, isNumValid:REQ, numPrompt:REQ, inputBuffer:REQ, inputBufferSize:REQ
	PUSHAD

	MOV		ECX, numsToGet
_GetValue:
	; Get first address of numArr that is empty to store number in
	MOV		EAX, numsToGet
	MOV		EBX, ECX
	SUB		EAX, EBX
	MOV		EBX, 4
	MUL		EBX
	MOV		ESI, OFFSET numArr
	ADD		ESI, EAX

	; Request signed integer number from user
	PUSH	ESI
	PUSH	minVal
	PUSH	maxVal
	PUSH	OFFSET errorMsg
	PUSH	OFFSET isNumValid
	PUSH	OFFSET numPrompt
	PUSH	OFFSET inputBuffer
	PUSH	OFFSET inputBufferSize
	CALL	ReadVal

	LOOP _GetValue

	POPAD
ENDM

	MINVALIDVAL = -2147483648
	MAXVALIDVAL = 2147483647
	NUMCOUNT = 10
	MAXBUFFERSIZE = 11

.data

	introMessage	BYTE	"Designing Low-Level I/O Procedures & Macros by Tim Thompson",13,10,13,10,0
	goodbyeMessage	BYTE	13,10,"So long and thanks for all the knowledge! Wonderful class.",0
	instructions	BYTE	"Please provide 10 signed decimal integers.",13,10
					BYTE	"Each number needs to be capable of fitting inside a 32 bit register. After you have finished entering",13,10
					BYTE	"the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	numberPrompt	BYTE	"Please enter a signed number: ",0
	errorMessage	BYTE	"ERROR: Your number was too big, you did not enter a signed number, or your entry was blank. Please try again.",13,10,0
	buffer			BYTE	MAXBUFFERSIZE DUP(?)
	bufferSize		DWORD	0
	isNumberValid	DWORD	0
	validatedNums	SDWORD	NUMCOUNT DUP(?)

.code
main PROC

	; Introduce program to user and display instructions
	mShowIntroduction introMessage, instructions

	; Obtain values from user
	mGetValues NUMCOUNT, validatedNums, MINVALIDVAL, MAXVALIDVAL, errorMessage, isNumberValid, numberPrompt, buffer, bufferSize

	; Say goodbye to the user
	mShowGoodbye goodbyeMessage

	Invoke ExitProcess,0	; Exit to operating system
main ENDP

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
;					validatedNums is a SDWORD array, initialized, and
;					has capacity to accept another number.
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
;		[EBP+36] = reference to array to store validated numbers.
;
; Returns:
;		buffer is populated with string of number input by user.
;		buffer size is populated with length of user inputted number.
;		validatedNums array contains number input by user.
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

	; Check if user input is a number, and if not, display error message
	; then prompt user to enter a number
	MOV			ESI, [EBP+20]
	MOV			AL, [ESI]
	CMP			AL, 1
	JZ			_CheckNumberSize
	mShowErrorMessage [EBP+24]
	JMP			_GetNumber

_CheckNumberSize:
	; Validate number to ensure it fits in the boundaries of a SDWORD
	PUSH		[EBP+36]
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
	mShowErrorMessage [EBP+24]
	JMP			_GetNumber

_DoneReadingValue:
	POPAD
	POP		EBP
	RET		32
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
; Postconditions: validatedNums array contains number if valid.
;
; Receives:
;		[EBP+8] = reference to buffer size for user input.
;		[EBP+12] = reference to buffer for user input.
;		[EBP+16] = reference to isValid boolean.
;		[EBP+20] = reference to max valid value for number.
;		[EBP+24] = reference to min valid value for number.
;		[EBP+28] = reference to array to store validated numbers.
;
; Returns:
;		isValid as 1 if input is valid, 0 if input is invalid.
; ---------------------------------------------------------------------
ValidateNumber PROC
	LOCAL	numIsNegative:BYTE
	MOV		numIsNegative, 0
	PUSHAD

	; Store parameters for validation
	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]

	; Check first buffer character to see if it's a sign
	MOV		EAX, [ESI]
	CMP		AL, 43
	JZ		_PositiveSign
	CMP		AL, 45
	JZ		_NegativeSign
	JMP		_ReadyToCompute

	; If the first character is positive, advance ESI one character
_PositiveSign:
	ADD		ESI, 1
	DEC		ECX
	JMP		_ReadyToCompute

	; If the first character is negative, advance ESI one character, set numIsNegative boolean
_NegativeSign:
	INC		BYTE PTR numIsNegative
	ADD		ESI, 1
	DEC		ECX

_ReadyToCompute:
	; Prepare EAX and direction flag for number computation
	MOV		EAX, 0
	CLD

	; Compute number from user input string
_ComputeNumber:
	MOV		EDX, 10
	MUL		EDX
	PUSH	EAX
	LODSB
	SUB		AL, 48
	MOVSX	EBX, AL
	POP		EAX
	ADD		EAX, EBX

	LOOP	_ComputeNumber

	; Determine if number is negative and go to appropriate limit check
	CMP		numIsNegative, 1
	JZ		_CheckMinLimit

_CheckMaxLimit:
	; Check if number is above maximum value
	CMP		EAX, [EBP+20]
	JO		_NumberInvalid
	JMP		_NumberValid

_CheckMinLimit:
	; Check if negative number is below minimum value
	NEG		EAX
	CMP		EAX, [EBP+24]
	JO		_NumberInvalid

_NumberValid:
	; Number is within SDWORD bounds, return isValid as 1
	MOV		EBX, [EBP+16]
	MOV		DWORD PTR [EBX], 1

	; Store number now that it is validated
	CLD
	MOV		EDI, [EBP+28]
	STOSD

	JMP		_ValidationComplete

_NumberInvalid:
	; Number is outside SDWORD bounds, return isValid as 0
	MOV		EBX, [EBP+16]
	MOV		DWORD PTR [EBX], 0

_ValidationComplete:
	POPAD
	RET		24
ValidateNumber ENDP

; ---------------------------------------------------------------------
; Name: WriteVal
;
; Convert a numeric value into a string of ASCII digits and then display
; the value to the console.
;
; Preconditions:	Buffer is a BYTE array, buffer size is a DWORD.
;					Number is a SDWORD. All three identifiers are
;					initialized and number is validated.
;
; Postconditions:	Buffer contains reversed number. Buffer size contains
;					length of number.
;
; Receives:
;		[EBP+8] = reference to address of buffer size for user input.
;		[EBP+12] = reference to address of buffer for user input.
;		[EBP+16] = reference to value of number.
;
; Returns: None.
; ---------------------------------------------------------------------
WriteVal PROC
	PUSH		EBP
	MOV			EBP, ESP
	PUSHAD

	; To get string of ascii digits, use / 10 trick to strip off
	; the last digit of number and store in buffer, increment
	; buffer size as you do, and once done the number will be in
	; buffer in reverse. Should be able to use buffer size to get
	; to end of reverse number and walk backwards through array
	; to print correctly.
	
	POPAD
	POP		EBP
	RET		12
WriteVal ENDP

END main