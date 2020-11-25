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

; (insert macro definitions here)

; (insert constant definitions here)

.data

	introMessage	BYTE	"Designing Low-Level I/O Procedures & Macros by Tim Thompson",13,10,13,10,0
	instructions	BYTE	"Please provide 10 signed decimal integers.",13,10
					BYTE	"Each number needs to be capable of fitting inside a 32 bit register. After you have finished entering",13,10
					BYTE	"the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,13,10,0

.code
main PROC

	; Introduce program to user and display instructions
	PUSH OFFSET introMessage
	PUSH OFFSET instructions
	CALL introduction

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
	PUSH EBP
	MOV	 EBP, ESP
	PUSHAD

	; Display introduction to user
	MOV	 EDX, [EBP+12]
	CALL WriteString

	; Display program instructions to user
	MOV	 EDX, [EBP+8]
	CALL WriteString

	POPAD
	POP	 EBP
	RET	 8
introduction ENDP

END main
