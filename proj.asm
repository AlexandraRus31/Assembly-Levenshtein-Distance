;Group 30413 Rus Alexandra Maria
;main.asm

DATA SEGMENT PARA PUBLIC 'DATA' 
			; 64 characters + 1 for enter
				  ;0 the lenght of the word given, completed by the dos
					  ;initialize with 0 everything
	a db 65, 0, 65 dup(0) 
	b db 65, 0, 65 dup(0)
	c db 65, 0, 65 dup(0)

	menu db "Choose operating mode: ", 13, 10	;message used for printing the menu
		 db "intr [INTERACTIVE]", 13, 10
		 db	"stat [STATISTICAL]", 13, 10
		 db "tri [TRIANGLE INEQUATION]", 13, 10
		 db "Selection: $"
	newline db 13, 10, "$"
	lev_distance db 13, 10, "The Levenshtein Distance is: $"
	mode_buffer db 6, 0, 6 dup(0) ; buffer for reading the mode that was choosed
	exit db 13, 10, "Exiting...$"
	input_intr db 13, 10, "Input two words separated by enter or q to exit$"
	input_tri db 13, 10, "Input three words separated by enter or q to exit$"
	input_stat db 13, 10, "Input two file names (words to check, dictionary), in order, separated by space$"

	;strings used for comparation to find the mode chosen
	cmd_intr db "intr$" ;for command interactive
	cmd_stat db "stat$" ;for command statistical
	cmd_tri db "tri$" ;for command triangle inequation
	cmd_exit db "q" ;command for programm to get out of the main loop

	;triangle print
	lev_ab dw 0
	lev_bc dw 0
	lev_ac dw 0
	header db 13, 10, "Pairwise Levenshtein distances$"
	pairs db "lev($"
	comma db ", $"
	close_parantesis db ") $"
	equal db "= $"
	less_then db " < $"
	plus db " + $"
	colon db ": $"
	true_msg db " - TRUE$"
	false_msg db " - FALSE$"

	;statistics data 
	file_names db 200, 0, 200 dup(0) 
	file1 db 128 dup(0) ; words to check
	file2 db 128 dup(0) ;dictionary
	result_file db "result.csv", 0 
	word_buf db 66 dup(0)
	dict_word_buf db 66 dup(0)
	max_len dw 0
	file1_modif dw 0
	file2_modif dw 0
	result_modif dw 0
	best_sim dw 0
	best_match_ptr dw 0
	no_match_str db "N/F", 0dh
	comma_file db ",", 0
	crlf_file db 13, 10, 0
	write_char_buf db 0
	best_match_buf db 66 dup(0)
	temp_handle dw 0
	file_output_result db "The similarity matrix is saved in result.csv"

	test1 db "test$"


DATA ENDS 

CODE SEGMENT PARA PUBLIC 'CODE' 

ASSUME CS:CODE, DS:DATA 
INCLUDE maclib.asm
INCLUDE proclib.asm
START PROC FAR 
	PUSH  DS 
	XOR AX,AX 
	PUSH AX 
	MOV  AX,DATA 
	MOV  DS,AX 
	
	main_loop:
		
		writing menu
		writing newline
		reading mode_buffer
		call compare_intr
		jz do_interactive

		call compare_stat
		jz do_statistics

		call compare_tri
		jz do_triangle


	jmp main_loop
	
	do_interactive:
		call do_interactive_proc
		jz do_exit ;if q was pressed we break out of the main loop
		jmp do_interactive


	do_statistics:
		call do_statistics_proc
		jmp main_loop

	do_triangle:
		call do_triangle_proc
		jz do_exit; if q was pressed we break out of the main loop
		jmp do_triangle

	do_exit:
		writing exit
		writing newline
		mov ah, 4ch
		int 21h
START ENDP 
CODE ENDS 
END START 