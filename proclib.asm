;Group 30413 Rus Alexandra Maria
;procedure library

print_a PROC NEAR

	mov cl, [a+1] ;keep the lenght of the string in cl
	xor ch,ch
	lea si, [a+2] ;load the word

	print_word_loop_a:
		cmp cx, 0 ;check if everything was printed
		je done_word_a
		mov dl, [si]
		mov ah, 02h ;print
		int 21h
		inc si
		dec cx
		jmp print_word_loop_a
	done_word_a:
		ret
	
print_a ENDP

print_b PROC NEAR;print string b same as above

	mov cl, [b+1] ;keep the lenght of the string in cl
	xor ch,ch
	lea si, [b+2] ;load the word

	print_word_loop_b:
		cmp cx, 0
		je done_word_b
		mov dl, [si]
		mov ah, 02h
		int 21h
		inc si
		dec cx
		jmp print_word_loop_b
	done_word_b:
		ret
	
print_b ENDP

print_c PROC NEAR ; print string c same as above

	mov cl, [c+1] ;keep the lenght of the string in cl
	xor ch,ch
	lea si, [c+2] ;load the word

	print_word_loop_c:
		cmp cx, 0
		je done_word_c
		mov dl, [si]
		mov ah, 02h
		int 21h
		inc si
		dec cx
		jmp print_word_loop_c
	done_word_c:
		ret
	
print_c ENDP

to_lower PROC NEAR;convert a string to lowercase
	
	push si
	push cx

	low_loop:
		cmp cx, 0 ;see if we changed all characters
		je done_lower

		mov al, [si]
		cmp al, 'A'
		jb next ;if is below 'A' then is not upper case
		cmp al, 'Z'
		ja next ;if is above 'Z' then is not upper case

		add byte ptr al, 20h
		mov [si], al ;save converted into memory
		next:
			inc si
			dec cx
			jmp low_loop

	done_lower:
		pop cx
		pop si
		ret

to_lower ENDP

compare_intr PROC NEAR;compare user input to the string "intr"
	;use si for the user input and di for the cmp_intr string we defined

	mov al, [mode_buffer+1] ;set to al the lenght of the input from the user

	;first check if its the same lenght
	cmp al, 4
	jne not_equal_intr

	lea si, [mode_buffer+2]
	lea di , cmd_intr

	;now wwe check for every character => we need a loop of 4

	mov cx, 4

	check_intr:
		mov al, [si]
		mov bl, [di]
		cmp al, bl
		jne not_equal_intr
		inc si
		inc di
		loop check_intr ;repeat for every character using cx register for the loop

		cmp ax, ax ;set zf=1
		ret

		not_equal_intr:
			test ax, ax ;set zf=0
			ret
compare_intr ENDP

compare_stat PROC NEAR;compare user input with "stat"
	;the same as before si for the input and di for my text cmp_stat
	mov al, [mode_buffer+1]
	cmp al, 4
	jne not_equal_stat

	lea si, [mode_buffer+2]
	lea di, cmd_stat

	mov cx, 4 ;we want to repeat the loop 4 time for every character in the string "stat"
	check_stat:
		mov al, [si]
		mov bl, [di]
		cmp al, bl    ;we want to check every first character and see if they are equal or not, if they are then we go to the next one
		jne not_equal_stat
		inc si
		inc di
		loop check_stat

	;if we got there then its the same work "stat"
	cmp ax,ax ;set zf=1
	ret

	not_equal_stat:
		test ax,ax ;set zf=0
		ret
compare_stat ENDP

compare_tri PROC NEAR;compare user input with "tri"

	;use bi for the user input and di for our string "tri"
	mov al, [mode_buffer+1]
	cmp al, 3
	jne not_equal_tri

	lea si, [mode_buffer+2] ;get the pointer to the start of the string
	lea di, cmd_tri

	mov cx, 3
	check_tri:
		mov al, [si] 
		mov bl, [di]
		cmp al, bl  ;compare every character of each string with the other
		jne not_equal_tri
		inc si
		inc di
		loop check_tri
	cmp ax, ax ;set zf=1
	ret

	not_equal_tri:
		test ax,ax ;set zf=0
		ret

compare_tri ENDP

strlen PROC NEAR
	;returns the lenght of a string 
	;si=pointer o that string
	;cx stores the lenght
	push si ;save the value that was in si
	xor cx,cx ;clear the register
	;we can not use a loop because cx is used for counting the number of characters so we will use a jump
	do:
		;check for carry return
		cmp byte ptr [si], 0Dh ;see if we are at the end of the string
		je end_strlen ;if yes then break out of the loop
		;check for null terminator
		cmp byte ptr [si], 0
		je end_strlen
		inc si  ;else move to the next character and increase the lenght of the string by 1
		inc cx
	jmp do

	end_strlen:
		pop si
		ret

strlen ENDP

lev PROC NEAR  ;we have a and b two strings
				;for a we use si
				;for b we use di
	;this procedure computes the levenshtein distance for two strings
	push bp  ;save the pointer to the stack
	mov bp, sp 
	push si  ;save the 2 strings
	push di
	push bx

	;so now at [bp] we have the start of this iteration
	;at [bp+2] we have bx
	;at [bp+4] we have di
	;at [bp+6] we have si
	mov di, [bp+4]
	mov si, [bp+6]


	;FIRST STEP

	;if |b|=0 the return |a|
	cmp byte ptr [di], 0Dh ;we have to see if we are at the end of the string b
	jne check_a_empty ;if not then go to the other instructions
	call strlen ;if we are then compute the lenght of a, returned val in cx
	mov ax, cx  ;save the lenght and break out of this recursive call
	jmp return_value

	;if |a|=0 return |b|
	check_a_empty:
		cmp byte ptr [si], 0Dh  ; we have to find out if we are at the end of string a
		jne check_heads ;if not then go to the other instructions, checking the first characters of each
		push si 
		mov si, di   ;first save what we have in si and then move the string b in it to prepare for the strlen call
		call strlen ;returned val in cx
		pop si  ;get the value back to si
		mov ax, cx  ; the lenght of the string b is moved into ax 
		jmp return_value ;break out of this recursive call

	;SECOND STEP
	;check the first characters of the 2 strings and see if they are equal or not

	check_heads:
		mov al, [si] ;head(a)
		mov bl, [di] ;head(b)

		cmp al, bl
		jne otherwise

		;make the recursive call lev(tail(a), tail(b))
		;tail(a)=ptr+1
		;we are using ax for moving through characters to not change the val of si and di, because we need them later
		mov ax, di
		inc ax  ;tail(a)
		push ax
		mov ax, si
		inc ax  ;tail(b)
		push ax  
		call lev ;returned val in ax
		add sp, 4 ;delete the elements from the stack

		jmp return_value

	;THIRD STEP
	;1+min(
	;	(tail(a), b),
	;	(a, tail(b)),
	;	(tail(a), tail(b))
	;)
	otherwise:
		;first call (tail(a),b)
		;the value will be stored in bx
		push di  ;we do not change b
		mov ax, si
		inc ax ;tail(a)
		push ax
		call lev ;returned val in ax
		add sp, 4 ;delete the elements from the stack
		mov bx, ax  ;storing the value of the call lev(tail(a), b) into bx

		;second call (a,tail(b))
		;at the end we compune min between the value we have just got into bx and the new value in ax
		;to obtain the minimum value, the minimum number of single character edits
		mov ax, di
		inc ax  ;tail(b)
		push ax
		push si ;a is unchanged
		call lev ;returned val in ax
		add sp, 4 ;delete the elements from the stack

		;now compare the 2 values and keep the smaller one
		cmp ax, bx
		jge min_bx1 ;if bx is smaller we keep it and go to the next instructions
		mov bx, ax ;else, the minimum is moved into bx

	min_bx1:
		;third call (tail(a), tail(b))
		;at the end we compute the min between
		mov ax, di
		inc ax ;tail(b)
		push ax
		mov ax, si
		inc ax ;tail(a)
		push ax
		call lev ;returned val in ax
		add sp, 4 ;delete the elements from the stack

		;min(bx, result)
		cmp ax, bx
		jge min_bx2
		mov bx, ax
	
	min_bx2:
		;now we need the return 1+min
		mov ax, bx
		inc ax ;add the 1

	return_value:
		;delete all the values that were saved in the stack
		pop bx
		pop di
		pop si
		pop bp
		ret
		

lev ENDP


printAX PROC NEAR ;convert ax to string and print it
	;print as a string the integer in AX register
	push ax
	push bx
	push cx ;for digit counting
	push dx ;for division to get last digit, remainder

	mov bx, 10 ;divide by 10 to get the last digit
	xor cx, cx ;clear the cx register

	extract_digits:
		xor dx, dx ;clear the register
		div bx ;ax=ax/bx dx=ax%10
		push dx ;save the remainder
		inc cx
		cmp ax, 0
		jne extract_digits

	print_digits:
		pop dx ;pop in order from left to right the number
		add dl, '0' ;convert to ascii
		mov ah, 02h
		int 21h
		loop print_digits ;loops cx times

	pop dx
	pop cx
	pop bx
	pop ax
	ret

printAX ENDP

compare_exit PROC NEAR ;check if input is 'q' to exit
	
	mov al, [a+1]
	cmp al, 1 ;see if the lenght of the word is 1
	jne not_exit

	lea si, [a+2]
	mov al, [si]
	cmp al, 'q' ;see if the word is "q"
	jne not_exit
	cmp ax, ax ;set zf=1
	ret

	not_exit:
		or ax, 1; set zf=0
		ret

compare_exit ENDP

do_interactive_proc PROC NEAR

	writing newline
	writing input_intr
	writing newline
	reading a ;we need to convert it to lower case

	mov cl, [a+1] ;keep the lenght 
	xor ch, ch ;clear ch
	lea si, [a+2] ;load the stat of the string
	call to_lower

	writing newline
	call compare_exit
	jz stop_interactive
	reading b ;now convert it to lower case
	mov cl, [b+1] ;keep the lenght
	xor ch, ch; clear ch
	lea si, [b+2]
	call to_lower
	writing newline

	;compute lev distance
	;pushing the strings into the stack in reversed order
	lea ax, b+2
	push ax
	lea ax, a+2
	push ax
	call lev
	add sp, 4 ;delete the elements from the stack
	;ax holds the result
	writing lev_distance
	call printAX
	writing newline

	stop_interactive:
		ret

do_interactive_proc ENDP

print1 PROC NEAR ;procedure to print the lev distance between the first two
	;lev(a,b)
	writing pairs
	call print_a
	writing comma
	call print_b
	writing close_parantesis
	writing equal
	mov ax, [lev_ab]
	call printAX
	writing newline
	ret

print1 ENDP

print2 PROC NEAR ;procedure to print the lev distance between last two
	;lev(b,c)
	writing pairs
	call print_b
	writing comma
	call print_c
	writing close_parantesis
	writing equal
	mov ax, [lev_bc]
	call printAX
	writing newline
	ret

print2 ENDP

print3 PROC NEAR ;procedure to printthe lev distance between first and last
	;lev(a,c)
	writing pairs
	call print_a
	writing comma
	call print_c
	writing close_parantesis
	writing equal
	mov ax, [lev_ac]
	call printAX
	writing newline
	ret

print3 ENDP

check_triangle1 PROC NEAR
	;check tri ineq lev(a,b)<lev(a,c)+lev(b,c)
	mov ax, [lev_ab]
	mov bx, [lev_ac]
	add bx, [lev_bc]; bx contains the sum lev(a,c)+lev(b,c)

	;start the printing
	writing pairs
	call print_a
	writing comma
	call print_b
	writing close_parantesis;lev(a,b)

	writing less_then ;<

	writing pairs
	call print_a
	writing comma
	call print_c
	writing close_parantesis ;lev(a,c)

	writing plus ;+

	writing pairs
	call print_b
	writing comma
	call print_c
	writing close_parantesis ;lev(b,c)
	writing colon ; :

	;
	mov ax, [lev_ab]
	call printAX
	writing less_then
	mov ax, bx
	call printAX
	;writing boolean message
	cmp [lev_ab], bx
	jl print_true1
	writing false_msg
	ret
	print_true1:
		writing true_msg
		ret

check_triangle1 ENDP

check_triangle2 PROC NEAR
	;check tri ineq lev(a,c)<lev(a,b)+lev(b,c)
	mov ax, [lev_ac]
	mov bx, [lev_ab]
	add bx, [lev_bc]; bx contains the sum lev(a,b)+lev(b,c)

	;start the printing
	writing pairs
	call print_a
	writing comma
	call print_c
	writing close_parantesis;lev(a,c)

	writing less_then ;<

	writing pairs
	call print_a
	writing comma
	call print_b
	writing close_parantesis ;lev(a,b)

	writing plus ;+

	writing pairs
	call print_b
	writing comma
	call print_c
	writing close_parantesis ;lev(b,c)
	writing colon ;:

	;
	mov ax, [lev_ac]
	call printAX
	writing less_then
	mov ax, bx
	call printAX
	;writing boolean message
	cmp [lev_ab], bx
	jl print_true2
	writing false_msg
	ret
	print_true2:
		writing true_msg
		ret

check_triangle2 ENDP

check_triangle3 PROC NEAR
	;check tri ineq lev(b,c)<lev(a,b)+lev(a,c)
	mov ax, [lev_bc]
	mov bx, [lev_ab]
	add bx, [lev_ac]; bx contains the sum lev(a,b)+lev(a,c)

	;start the printing
	writing pairs
	call print_b
	writing comma
	call print_c
	writing close_parantesis;lev(b,c)

	writing less_then ;<

	writing pairs
	call print_a
	writing comma
	call print_b
	writing close_parantesis ;lev(a,b)

	writing plus ;+

	writing pairs
	call print_a
	writing comma
	call print_c
	writing close_parantesis ;lev(a,c)
	writing colon ;:

	;
	mov ax, [lev_bc]
	call printAX
	writing less_then
	mov ax, bx
	call printAX
	;write boolean message
	cmp [lev_ab], bx
	jl print_true3
	writing false_msg
	ret
	print_true3:
		writing true_msg
		ret

check_triangle3 ENDP

do_triangle_proc PROC NEAR

	writing newline
	writing input_tri
	writing newline
	reading a
	writing newline
	
	;check if it was q
	call compare_exit
	jnz continue_triangle
	jmp stop_triangle

	continue_triangle:
	reading b
	writing newline
	reading c
	writing newline

	;compute lev(a,b)
	;pushing the strings into the stack in reversed order
	lea ax, b+2
	push ax
	lea ax, a+2
	push ax
	call lev
	add sp, 4 ;delete the elements from the stack
	;ax holds the result
	mov [lev_ab], ax
	
	;start printing
	writing header
	writing newline
	mov ax, [lev_ab]
	call print1

	;compute lev(b,c)
	;pushing the strings into the stack in reversed order
	lea ax, c+2
	push ax
	lea ax, b+2
	push ax
	call lev
	add sp, 4 ;delete the elements from the stack
	;ax holds the result
	mov [lev_bc], ax
	mov ax, [lev_bc]
	call print2

	;compute lev(a,c)
	;pushing the strings into the stack in reversed order
	lea ax, c+2
	push ax
	lea ax, a+2
	push ax
	call lev
	add sp, 4 ;delete the elements from the stack
	;ax holds the result
	mov [lev_ac], ax
	mov ax, [lev_ac]
	call print3
	writing newline

	call check_triangle1
	writing newline
	call check_triangle2
	writing newline
	call check_triangle3
	writing newline


	stop_triangle:
		ret

do_triangle_proc ENDP

write_word PROC NEAR ;write a word in a file
	;si=pointer to word, bx=file
	push ax
	push bx
	push cx
	push dx
	push si

	mov dx, si
	xor cx, cx

	count: ;computes the lenght of the word
		cmp byte ptr [si], 0dh
		je go
		cmp byte ptr [si], 0
		je go
		inc si
		inc cx
		jmp count
	
	go:
		mov ah, 40h ;write to file
		int 21h
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
write_word ENDP

write_comma PROC NEAR ;write ',' to file
	
	push ax
	push bx
	push cx
	push dx
	mov ah, 40h
	lea dx, comma_file
	mov cx, 1
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret

write_comma ENDP

write_crlf PROC NEAR
	;cr=carriage return=0dh=cursor to the start of the line
	;lf=line feed=0ah=character move to the line below
	push ax
	push bx
	push cx
	push dx
	mov ah, 40h
	lea dx, crlf_file
	mov cx, 2
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret

write_crlf ENDP

write_num_to_file PROC NEAR ;write a number as a string
	;in ax we have the number and in bx the file
	push ax
	push bx
	push cx
	push dx
	push si
	mov cx, 0
	mov si, 10

	extract: ;take each digit pop into a stack and print them out after pop
		xor dx, dx
		div si ;catul e in ax si restul in dx
		push dx
		inc cx
		cmp ax, 0
		jne extract
	mov si, bx
	mov bx, cx
	write:  ;pop and write each digit
		pop dx
		add dl, '0'
		mov byte ptr [write_char_buf], dl
		push bx
		push si
		mov bx, si
		mov ah, 40h
		lea dx, write_char_buf
		mov cx, 1
		int 21h
		pop si
		pop bx
		dec bx
		jnz write
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
write_num_to_file ENDP

split_files PROC NEAR
	;save the values
	push si;used to take characters out of the buffer
	push di;used to save the file names
	push ax

	lea si, file_names+2 
	lea di, file1 

	;copy until space
	copy_first:
		mov al, [si]
		cmp al, ' '
		je first_done
		mov [di], al
		inc si
		inc di
		jmp copy_first

	first_done:
		inc si
		mov byte ptr [di], 0 ;terminate in null
		lea di, file2

	copy_second: ;now take the second word(file)
		mov al, [si]
		cmp al, 0dh
		je done_second
		mov [di], al
		inc si
		inc di
		jmp copy_second

	done_second:
		mov byte ptr [di], 0 ;terminate with null the second file
		pop ax
		pop di
		pop si
		ret
	
split_files ENDP

read_word_file PROC NEAR ;read a single word from a file(up to new line)
	
	push ax
	push bx
	push dx
	mov temp_handle, bx
	xor cx, cx ;clear cx, used to output lenght of string read
	;use di as buffer to read

	read_char:
		mov ah, 3fh; read file
		mov dx, di ;use di to get the word
		add dx, cx ;get to current position
		push cx
		mov cx, 1 ;read 1 byte
		mov bx, temp_handle
		int 21h
		pop cx
		jc eof ;if carry flag is active we have error or no more words in the file
		cmp ax, 0 ;nothig read=end of file
		je eof
		mov bx, cx
		mov al, byte ptr [di+bx] ;move the last word read
		cmp al, 0dh
		je skip_lf
		cmp al, 0ah ;if we are at the end of line
		je done_word
		inc cx
		jmp read_char

	skip_lf:
		;skip the 0ah after 0dh
		mov ah, 3fh
		push dx
		push cx
		mov cx, 1
		mov bx, temp_handle
		int 21h
		pop cx
		pop dx
		jmp done_word

	done_word:
		;put 0dh at the end=move cursor at the start of line
		mov bx, cx
		mov byte ptr [di+bx], 0dh ;terminat with odh
		clc ;clear carry
		pop dx
		pop bx
		pop ax
		ret

	eof:
		stc ;set carry 
		pop dx
		pop bx
		pop ax
		ret

read_word_file ENDP

compute_sim PROC NEAR;compute sim=1-(lev(a,b)/max(|a|,|b|))*100
	;ax has the lev dist
	;si=a di=b
	 push bx
	 push cx
	 push dx
	 push ax

	 call strlen ;lenght of the first word
	 mov bx, cx;

	 push si
	 mov si, di
	 call strlen;lenght of the second word
	 pop si
	 ;now we have bx=strlen(si), cx=strlen(di)

	 ;max(len1, len2)
	 cmp bx, cx
	 jge maximum
	 mov max_len, cx
	 jmp got_max

	 maximum:
		mov max_len, bx

	;now in max_len we have the maximum lenght

	 got_max:
		pop ax ;get the lev dist
		mov bx, max_len
		cmp bx, 0
		je sim_zero

		sub bx, ax ;bx=max_len-lev
		mov ax, bx ;move for multiply
		mov bx, 100
		mul bx
		div max_len ;ax has the final computation
		jmp sim_done

	sim_zero:
		xor ax, ax

	sim_done:
		pop dx
		pop cx
		pop bx
		ret

compute_sim ENDP

do_statistics_proc PROC NEAR
	
	writing newline
	writing input_stat
	writing newline
	reading file_names
	call split_files

	;open file 1
	lea dx, file1
	mov al, 0
	mov ah, 3dh
	int 21h
	jnc file_open_next
	file_open_next:
	mov file1_modif, ax

	;open file 2
	lea dx, file2
	mov al, 0
	mov ah, 3dh
	int 21h
	mov file2_modif, ax

	;create output file
	lea dx, result_file
	mov ah, 3ch
	mov cx, 0
	int 21h

	mov result_modif, ax

	

	stat_word_loop:
		mov bx, file1_modif
		lea di, word_buf
		call read_word_file
		jnc continue
		jmp stat_done ;reached end of file

		continue:
		;reset dictionary file pointer to start
		mov bx, result_modif
		lea si, word_buf
		call write_word
		call write_comma
		mov ah, 42h;move the index in the file
		mov al, 0
		xor cx, cx
		xor dx, dx
		mov bx, file2_modif
		int 21h

		mov best_sim, 0
		dict_loop: ;compare source word with every in dictionary
			mov bx, file2_modif
			lea di, dict_word_buf
			call read_word_file
			jnc continue_search
			jmp end_dict

		continue_search:
			;compute the lev distance
			lea ax, dict_word_buf
			push ax
			lea ax, word_buf
			push ax
			call lev
			add sp, 4 ;clear the stack
			
			lea si, word_buf
			lea di, dict_word_buf
			call compute_sim ;percentage is in ax

			mov bx, result_modif
			call write_num_to_file
			call write_comma

			;for similarity over 75 keep the word
			cmp ax, 75 ;if the similarity is under  75% repeat the loop
			jle dict_loop
			cmp ax, best_sim
			jl dict_loop
			mov best_sim, ax
			lea si, dict_word_buf
			lea di, best_match_buf
			copy_best:
				mov al, [si]
				mov [di], al
				cmp al, 0dh
				je copy_done
				cmp al, 0
				je copy_done
				inc si
				inc di
				jmp copy_best
		copy_done:
			lea bx, best_match_buf ;load the word into memory
			mov best_match_ptr, bx
			jmp dict_loop
		end_dict: ;write best match
			mov bx, result_modif
			cmp best_sim, 75
			jle write_nf
			lea si, best_match_buf
			call write_word
			jmp next_word
		write_nf:
			mov bx, result_modif
			lea si, no_match_str
			call write_word
		next_word:
			mov bx, result_modif
			call write_crlf
			jmp stat_word_loop
	stat_done: ;close all files

		;close files
		mov bx, file1_modif
		mov ah, 3eh
		int 21h
		mov bx, file2_modif
		mov ah, 3eh
		int 21h
		mov bx, result_modif
		mov ah, 3eh
		int 21h

		writing file_output_result
		writing newline
		writing exit
		writing newline
		ret


do_statistics_proc ENDP
