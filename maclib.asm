;Group 30413 Rus Alexandra Maria
;macro library

writing macro message
	push ax ;save the registers
	push dx
	mov ah, 09h ;write the string using the function from INT 21h
	lea dx, message  ;load the address given of the parameter
	int 21h  ;stop the usage of the dos
	pop dx
	pop ax
	
	
endm

reading macro buffer
	push ax ;save the registers
	push dx
	mov ah, 0Ah ;DOS function foe reading
	lea dx, buffer ;save the address of the buffer
	int 21h  ;the end of usage of dos function
	pop dx 
	pop ax

endm

