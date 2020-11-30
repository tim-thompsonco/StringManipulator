TITLE Designing Low-Level I/O Procedures & Macros     (Proj6_thompsti.asm)

; Author: Tim Thompson
; Last Modified: 11/28/20
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
;					the user prompt to display. inputBuffer is initialized
;					and is a BYTE array. inputBufferLength is initialized
;					and is a DWORD. maxBufferSize is initialized and is
;					a DWORD.
;
; Postconditions: None.
;
; Receives:
;		prompt = address of user prompt to display.
;		inputBuffer = address of buffer array to store user input.
;		inputBufferLength = address of buffer size to store input length.
;		maxBufferSize = value of max buffer size.
;
; Returns:
;		inputBuffer contains string of number entered by user.
;		inputBufferLength contains length of string entered by user.
; ---------------------------------------------------------------------
mGetString	MACRO prompt:REQ, inputBuffer:REQ, inputBufferLength:REQ, maxBufferSize:REQ
	PUSHAD

	; Prompt user for signed integer number
	MOV		EDX, prompt
	CALL	WriteString

	; Store user input
	MOV		EDX, inputBuffer
	MOV		ECX, maxBufferSize
	CALL	ReadString

	; Store size of user input
	MOV		EDI, inputBufferLength
	MOV		[EDI], EAX

	POPAD
ENDM

; ---------------------------------------------------------------------
; Name: mDisplayString
;
; Reads string and then displays the string to console.
;
; Preconditions:	stringToRead is an address pointing to a BYTE array
;					containing the string to display.
;
; Postconditions: None.
;
; Receives:
;		stringToRead = address of array containing string.
;
; Returns: None.
; ---------------------------------------------------------------------
mDisplayString	MACRO stringToRead:REQ
	PUSH	EDX

	; Display number
	MOV		EDX, stringToRead
	CALL	WriteString

	POP		EDX
ENDM

	MINVALIDVAL = -2147483648
	MAXVALIDVAL = 2147483647
	NUMCOUNT = 10
	MAXBUFFERSIZE = 14

.data

	introMessage	BYTE	"Designing Low-Level I/O Procedures & Macros by Tim Thompson",13,10,13,10
					BYTE	"Please provide 10 signed decimal integers.",13,10
					BYTE	"Each number needs to be capable of fitting inside a 32 bit register. After you have finished entering",13,10
					BYTE	"the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	goodbyeMessage	BYTE	13,10,13,10,"So long and thanks for all the knowledge! Wonderful class.",13,10,0
	numberPrompt	BYTE	"Please enter a signed number: ",0
	errorMessage	BYTE	"ERROR: Your number was too big, you did not enter a signed number, or your entry was blank. Please try again.",13,10,0
	resultPrompt1	BYTE	13,10,"You entered these numbers:",13,10,0
	sumTotalMsg		BYTE	13,10,13,10,"The sum of these numbers is: ",0
	roundedAvgMsg	BYTE	13,10,13,10,"The rounded average of these numbers is: ",0
	buffer			BYTE	MAXBUFFERSIZE DUP(?)
	firstNumToShow	DWORD	0
	bufferSize		DWORD	0
	isNumberValid	DWORD	0
	validatedNums	SDWORD	NUMCOUNT DUP(?)
	sumTotal		SDWORD	0
	numAvg			SDWORD	0

.code
main PROC

	; Introduce program to user and display instructions
	mDisplayString OFFSET introMessage

	; Obtain values from user
	MOV		ECX, NUMCOUNT
_GetValue:
	; Get first address of validatedNums that is empty to store number in
	MOV		EAX, NUMCOUNT
	MOV		EBX, ECX
	SUB		EAX, EBX
	MOV		EBX, 4
	MUL		EBX
	MOV		ESI, OFFSET validatedNums
	ADD		ESI, EAX

	; Request signed integer number from user
	PUSH	MAXBUFFERSIZE
	PUSH	ESI
	PUSH	MINVALIDVAL
	PUSH	MAXVALIDVAL
	PUSH	OFFSET errorMessage
	PUSH	OFFSET isNumberValid
	PUSH	OFFSET numberPrompt
	PUSH	OFFSET buffer
	PUSH	OFFSET bufferSize
	CALL	ReadVal

	LOOP	_GetValue

	; Notify user that they have entered numbers which are about to be written
	mDisplayString OFFSET resultPrompt1
	
	; Write values to console
	MOV		ECX, NUMCOUNT
_WriteValue:
	; Get address of next number to write to console
	MOV		EAX, NUMCOUNT
	MOV		EBX, ECX
	SUB		EAX, EBX
	MOV		EBX, 4
	MUL		EBX
	MOV		ESI, OFFSET validatedNums
	ADD		ESI, EAX

	; Set boolean firstNumToShow to 1 if first number to display, 0 if not
	CMP		ECX, NUMCOUNT
	JNZ		_ShowNumber
	MOV		DWORD PTR firstNumToShow, 1

_ShowNumber:
	; Write value to console
	PUSH	firstNumToShow
	PUSH	[ESI]
	PUSH	OFFSET buffer
	PUSH	OFFSET bufferSize
	CALL	WriteVal

	; Reset boolean firstNumToShow for later use
	MOV		DWORD PTR firstNumToShow, 0

	LOOP	_WriteValue

	; Calculate sum total of validated numbers
	PUSH	OFFSET sumTotal
	PUSH	OFFSET validatedNums
	PUSH	NUMCOUNT
	CALL	CalculateSum

	; Display sum total message
	mDisplayString OFFSET sumTotalMsg

	; The sum and average will both be the first number to display
	MOV		DWORD PTR firstNumToShow, 1

	; Display sum total of validated numbers
	PUSH	firstNumToShow
	PUSH	sumTotal
	PUSH	OFFSET buffer
	PUSH	OFFSET bufferSize
	CALL	WriteVal

	; Calculate rounded average of validated numbers
	PUSH	OFFSET numAvg
	PUSH	sumTotal
	PUSH	NUMCOUNT
	CALL	CalculateAverage

	; Display rounded average message
	mDisplayString OFFSET roundedAvgMsg

	; Display rounded average of validated numbers
	PUSH	firstNumToShow
	PUSH	numAvg
	PUSH	OFFSET buffer
	PUSH	OFFSET bufferSize
	CALL	WriteVal

	; Say goodbye to the user
	mDisplayString OFFSET goodbyeMessage

	Invoke	ExitProcess,0	; Exit to operating system
main ENDP

; ---------------------------------------------------------------------
; Name: ReadVal
;
; Obtain a signed integer number from the user, validate that it is a
; valid signed integer number which can fit in a 32 bit register, and
; then store the validated number in an array. The length of the string
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
;					has capacity to accept another number. maxBufferSize
;					contains the maximum length the input buffer accepts.
;
; Postconditions:	isNumberValid contains a 1 if the number entered
;					by the user is valid, 0 if the number is invalid.
;					buffer is populated with string of number input by user.
;					bufferSize is populated with length of user inputted number.
;
; Receives:
;		[EBP+8] = address of buffer size for user input.
;		[EBP+12] = address of buffer for user input.
;		[EBP+16] = address of user prompt.
;		[EBP+20] = address of boolean value isNumberValid.
;		[EBP+24] = address of error message for invalid entry.
;		[EBP+28] = value of max valid value for number.
;		[EBP+32] = value of min valid value for number.
;		[EBP+36] = address of array to store validated numbers.
;		[EBP+40] = value of max buffer size.
;
; Returns:
;		validatedNums array contains number input by user.
; ---------------------------------------------------------------------
ReadVal PROC
	PUSH		EBP
	MOV			EBP, ESP
	PUSHAD

_GetNumber:
	; Call macro to get and store number input by user
	mGetString	[EBP+16], [EBP+12], [EBP+8], [EBP+40]

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
	mDisplayString [EBP+24]
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
	mDisplayString [EBP+24]
	JMP			_GetNumber

_DoneReadingValue:
	POPAD
	POP		EBP
	RET		36
ReadVal ENDP

; ---------------------------------------------------------------------
; Name: ValidateInput
;
; Validate the user input passed into the buffer. The user input stored
; in buffer is checked to ensure it is not an empty string and it does
; not have non-numeric characters in it other than an optional leading sign.
;
; Preconditions:	Buffer is a BYTE array, buffer size is a DWORD, and
;					isValid is a BYTE. Buffer contains the string input
;					by the user and buffer size contains the length of
;					the string input by the user.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = address of buffer size for user input.
;		[EBP+12] = address of buffer for user input.
;		[EBP+16] = address of boolean value isValid.
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
; Preconditions:	Buffer is a BYTE array, bufferSize is a DWORD, and
;					isValid is a BYTE. Max and min valid values are
;					initialized to SDWORD upper and lower boundaries.
;					Buffer contains the string input by the user and
;					bufferSize contains the length of the string input
;					by the user.
;
; Postconditions: validatedNums array contains number if valid.
;
; Receives:
;		[EBP+8] = address of buffer size for user input.
;		[EBP+12] = address of buffer for user input.
;		[EBP+16] = address of boolean value isValid.
;		[EBP+20] = value of max valid value for number.
;		[EBP+24] = value of min valid value for number.
;		[EBP+28] = address of array to store validated numbers.
;
; Returns:
;		isValid as 1 if input is valid, 0 if input is invalid.
; ---------------------------------------------------------------------
ValidateNumber PROC
	LOCAL	numIsNegative:BYTE
	MOV		numIsNegative, 0
	PUSHAD

	MOV		EBX, [EBP+8]			; address of buffer size
	MOV		ECX, [EBX]				; value of buffer size
	MOV		ESI, [EBP+12]			; address of buffer

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
; Preconditions:	Buffer is a BYTE array, bufferSize is a DWORD.
;					Number is a SDWORD. All three identifiers are
;					initialized and number is validated. firstNumToShow
;					is a DWORD containing a 1 if this is the first number
;					to display to console, 0 if it is not the first.
;
; Postconditions:	Buffer contains reversed number as string of ASCII
;					digits. bufferSize contains length of number.
;
; Receives:
;		[EBP+8] = address of bufferSize for user input.
;		[EBP+12] = address of buffer for user input.
;		[EBP+16] = value of number.
;		[EBP+20] = boolean value of firstNumToShow.
;
; Returns: None.
; ---------------------------------------------------------------------
WriteVal PROC
	LOCAL	numToWrite:SDWORD
	LOCAL	stringLength:BYTE
	LOCAL	numIsNegative:BYTE
	MOV		stringLength, 0
	MOV		numIsNegative, 0
	PUSHAD

	MOV		EDI, [EBP+12]			; Buffer to store ASCII digits
	MOV		EAX, [EBP+16]			; Value of number to be converted
	CLD

	; Store number in local variable since EAX/EDX will be used for division
	MOV		numToWrite, EAX

	; Check number, and if negative, set numIsNegative boolean to true
	CMP		EAX, 0
	JGE		_ConvertNumber
	NEG		EAX
	INC		BYTE PTR numIsNegative
	MOV		numToWrite, EAX			; If negative, update numToWrite so value is positive

_ConvertNumber:
	; Strip off last digit using division and store in buffer
	MOV		EAX, numToWrite
	MOV		EBX, 10
	CDQ
	DIV		EBX
	PUSH	EAX
	MOV		AL, DL
	ADD		AL, 48					; Convert back to ASCII character for number
	STOSB
	INC		BYTE PTR stringLength
	POP		EAX
	MOV		numToWrite, EAX
	CMP		EAX, 0
	JNZ		_ConvertNumber

	; Check if number is negative, and if so, add sign to end of string
	CMP		numIsNegative, 1
	JNZ		_ConversionDone
	MOV		AL, '-'
	STOSB
	INC		BYTE PTR stringLength

_ConversionDone:
	; Add formatting to end of string for display to console if not the first number
	MOV		EAX, [EBP+20]
	CMP		EAX, 1
	JZ		_StringReadyToComplete
	MOV		AL, ' '
	STOSB
	MOV		AL, ','
	STOSB
	ADD		BYTE PTR stringLength, 2

_StringReadyToComplete:
	; Add null terminator to end of string to complete it
	MOV		AL, 0
	STOSB

	; Update buffer size to length of string
	MOVZX	EAX, stringLength
	MOV		ESI, [EBP+8]
	MOV		[ESI], EAX

	; Check if number is single digit, and if so, it is ready to display
	CMP		EAX, 1
	JZ		_DisplayNumber

	; Number is populated as string of ASCII digits in reverse, so we
	; reverse the string to get the string to be displayed
	PUSH	[ESI]
	PUSH	[EBP+12]
	CALL	ReverseString

_DisplayNumber:
	; Display number to console
	MOV		ESI, [EBP+12]
	mDisplayString ESI

	POPAD
	RET		16
WriteVal ENDP

; ---------------------------------------------------------------------
; Name: ReverseString
;
; Reverses a string of ASCII digits that represents a number.
;
; Preconditions:	Buffer is a BYTE array and buffer size is a DWORD.
;					Buffer contains a string of ASCII digits which
;					represents a number. Buffer size contains the
;					length of the string, which includes any sign.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = address of buffer for user input.
;		[EBP+12] = value of buffer size for user input.
;
; Returns:
;		Reversed string of ASCII digits representing a number.
; ---------------------------------------------------------------------
ReverseString PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; To reverse the string in place, we use the two pointer technique
	MOV		EDI, [EBP+8]
	MOV		ESI, [EBP+8]

	; EDI will track the beginning of the array, ESI tracks the end
	ADD		ESI, [EBP+12]
	DEC		ESI

	; To reverse the string, we will iterate through half the string
	MOV		EAX, [EBP+12]
	MOV		EBX, 2
	CDQ
	DIV		EBX
	MOV		ECX, EAX
_ReverseDigits:
	; For each iteration, the first and last numbers are replaced
	MOV		BYTE PTR AL, [EDI]
	MOV		BYTE PTR AH, [ESI]
	MOV		[EDI], BYTE PTR AH
	MOV		[ESI], BYTE PTR AL

	; The front of the array (EDI) is then incremented by one
	INC		EDI

	; The back of the array (ESI) is then decremented by one
	DEC		ESI

	LOOP	_ReverseDigits
	
	POPAD
	POP		EBP
	RET		8
ReverseString ENDP

; ---------------------------------------------------------------------
; Name: CalculateSum
;
; Calculates the sum of the validated numbers entered by the user.
;
; Preconditions:	validatedNums is a SDWORD array initialized and
;					populated with validated numbers for the entirety
;					of its length. The length of the array is equal
;					to the constant value NUMCOUNT. sumTotal is a
;					SDWORD and is initialized.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = value of length of validatedNums array.
;		[EBP+12] = address of array of validatedNums array.
;		[EBP+16] = address of sumTotal to store results in.

; Returns:
;		Sum total of the numbers entered by the user in sumTotal.
; ---------------------------------------------------------------------
CalculateSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Running sum will be stored in EAX, address of array in ESI
	MOV		EAX, 0
	MOV		ESI, [EBP+12]

	; Length of validatedNums array will be used as loop counter
	MOV		ECX, [EBP+8]
_AddNumberToSum:
	; Add current number to running total then go to next number
	ADD		EAX, [ESI]
	ADD		ESI, 4

	LOOP	_AddNumberToSum

	; Store and return results
	MOV		EDI, [EBP+16]
	MOV		[EDI], EAX

	POPAD
	POP		EBP
	RET		12
CalculateSum ENDP

; ---------------------------------------------------------------------
; Name: CalculateAverage
;
; Calculates the rounded average of the validated numbers entered by the
; user.
;
; Preconditions:	sumTotal is a SDWORD and is populated with the sum
;					total of the validated numbers. The number count is
;					equal to the constant value NUMCOUNT. numAvg is a
;					SDWORD and is initialized.
;
; Postconditions: None.
;
; Receives:
;		[EBP+8] = value of number count.
;		[EBP+12] = value of total sum of numbers.
;		[EBP+16] = address of numAvg to store results in.

; Returns:
;		Rounded average of the numbers entered by the user in numAvg.
; ---------------------------------------------------------------------
CalculateAverage PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; Obtain rounded average by dividing sum total by count of numbers
	MOV		EAX, [EBP+12]
	MOV		EBX, [EBP+8]
	CDQ
	IDIV	EBX

	; Store and return results
	MOV		EDI, [EBP+16]
	MOV		[EDI], EAX

	POPAD
	POP		EBP
	RET		12
CalculateAverage ENDP

END main