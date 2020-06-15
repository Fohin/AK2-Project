.section .bss
.equ BYTES_2K, 2048
.equ BYTES_4K, 4096
.equ LENGTH, 8
.equ BYTE, 1
.lcomm first_number, BYTES_2K
.lcomm second_number, BYTES_2K
.lcomm first_number_temp, LENGTH
.lcomm first_number_length, LENGTH
.lcomm second_number_length, LENGTH
.lcomm second_number_length_secondary, LENGTH
.lcomm result, BYTES_4K
.lcomm final_result, BYTES_4K
.lcomm carry, BYTE
.lcomm last_carry, BYTE

.data
    size: .long 512
    variable_size: .long 0
    size_counter: .long 0
    base: .byte 10

.text

.global multiplication
.type multiplication, @function
multiplication:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl size, %eax
    movl %eax, variable_size
    xorl %eax, %eax

    movl size, %edi
	decl %edi

resetfinal_result:
    movb $0, final_result(, %edi, 1)
    decl %edi
    cmpl $0, %edi
    jge resetfinal_result	

get_first_number:
    movl 8(%ebp), %ecx
    movl $0, %edi

mov_first_number:
    movb (%ecx, %edi, 1), %dl
    movb %dl, first_number(, %edi, 1)
    incl %edi
    cmpb $0, %dl
    je mov_first_end
    jmp mov_first_number

mov_first_end:
    subl $3, %edi
    movl %edi, first_number_length

get_second_number:
    movl 12(%ebp), %ecx
    movl $0, %edi

mov_second_number:
    movb (%ecx, %edi, 1), %dl
    movb %dl, second_number(, %edi, 1)
    incl %edi
    cmpb $0, %dl
    je mov_second_exit
    jmp mov_second_number

mov_second_exit:
    subl $3, %edi
    movl %edi, second_number_length

    xorl %edx, %edx
    movl second_number_length, %edx
    movl %edx, second_number_length_secondary
    xorl %edx, %edx

prepare_result: 
    cmpl $0, first_number_length
    jl third_case_result
    xorl %edi, %edi
    movl size, %edi

clear_result: 
    movb $0, result(, %edi, 1)
    decl %edi
    cmpl $0, %edi
    je clear_result_exit
    jmp clear_result

clear_result_exit:
    movl size, %edi
	xorl %ecx, %ecx 	
	movb $0xA, result(, %edi, 1) 
	decl %edi
    movl size, %ecx
    subl variable_size, %ecx
    decl variable_size

loop:
    cmpl $0, %ecx
    je start_calc
    movb $0, result(, %edi, 1)
    decl %edi
    decl %ecx
    jmp loop
    
start_calc:
    xorl %ecx, %ecx
    xorl %edx, %edx

    movl $0, first_number_temp
	movl first_number_length, %edx
	cmpl $0, %edx
	jl first_number_exit
	xorl %ebx, %ebx
	decl first_number_length
	movb first_number(, %edx, 1), %bl

	pushl $base
	pushl %ebx
	call char_to_number
	addl $8, %esp    
    movl %eax, first_number_temp
	jmp mov_2nd_num_len

first_number_exit:
	xorl %eax, %eax
    movl %eax, first_number_temp
    
mov_2nd_num_len:
    movl second_number_length_secondary, %edx
    movl %edx, second_number_length  
  
continue_calc:
	xorl %eax, %eax	
	movl second_number_length, %edx	# pobierz dlugosc drugiej liczby do rejestru
	cmpl $0, %edx	
	jl second_number_exit	
	decl second_number_length		
	movb second_number(, %edx, 1), %bl # pobieranie znaku do ebx

	pushl $base
	pushl %ebx
	call char_to_number
	addl $8, %esp
    jmp multiplication_start

second_number_exit:
	cmpl $0, first_number_length
	jge multiplication_start
	cmpl $0, second_number_length
	jge multiplication_start
	cmpl $0, carry
	jg multiplication_start
	jmp first_case_result

multiplication_start:
    xorl %ecx, %ecx
	imull first_number_temp, %eax	
	addl carry, %eax # dodajemy ewentualne przeniesienie
	movb $0, carry # zerujemy przeniesienie

compare:
	cmpl base, %eax	
	jb save_result
	subl base, %eax #jezeli wynik jest wiekszy od podstawy to odejmujemy podstawe...
	incl %ecx
	jmp compare

save_result:
    movl %ecx, carry

	#pushl %eax
	#call number_to_char
	#addl $4, %esp

	movb %al, result(,%edi,1) 
	decl %edi 
    
    xorl %ecx, %ecx
    movl second_number_length, %ecx
    addl $1, %ecx
    cmpl $0, %ecx 
	jg continue_calc   

    xorl %ecx, %ecx
    movl carry, %ecx
    cmpl $0, %ecx   
    jne continue_calc  

first_case_result:
    decl %edi
    cmpl $0, %edi
    jl second_case_result
    movb $0, result(, %edi, 1)
    jmp first_case_result

second_case_result:
    call add_to_final_result  
    jmp prepare_result

third_case_result:
    call find_zeros
    movl $final_result, %eax
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

.type char_to_number, @function
char_to_number:
	pushl %ebp
	movl %esp, %ebp
	xorl %ebx, %ebx
	movl 8(%ebp), %ebx
	subb $0x30, %bl
	movl %ebx, %eax
	movl %ebp, %esp
	popl %ebp
	ret

.type number_to_char, @function
number_to_char:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	addb $0x30, %al
	movl %ebp, %esp
	popl %ebp
	ret

.type add_to_final_result, @function
add_to_final_result:
	pushl %ebp
	movl %esp, %ebp
    xorl %edx, %edx
    movl size, %edx
    decl %edx

add_to_final_result_2:
    xorl %ebx, %ebx
    movb result(, %edx, 1), %bl # pobieranie znaku do ebx
    movb final_result(, %edx, 1), %al
    addl %ebx, %eax
    addl last_carry, %eax
    movl $0, last_carry
    cmpl base, %eax
    jl add_to_final_result_3

    xorl %ecx, %ecx
    subl base, %eax
    incl %ecx
    movl %ecx, last_carry
    
add_to_final_result_3:
    cmpl $0, first_number_length
    jl add_to_final_result_4
    movb %al, final_result(, %edx, 1)
    decl %edx
    cmpl $0, %edx
    jge add_to_final_result_2
    jmp add_to_final_result_exit

add_to_final_result_4:
    pushl %eax
    call number_to_char
    addl $4, %esp
    movb %al, final_result(, %edx, 1)
    decl %edx
    cmpl $0, %edx
    jge add_to_final_result_2

add_to_final_result_exit:
    movl %ebp, %esp
	popl %ebp
	ret

.type find_zeros ,@function
find_zeros:
    xorl %eax, %eax
    xorl %ecx, %ecx
    movl size, %eax
    movl %eax, size_counter
    xorl %eax, %eax

find_begining_zeros:
    xorl %edx, %edx
    decl size_counter
    movb final_result(, %edx, 1), %al
    incl %edx
    cmpl $'0', %eax
    je remove_zeros
    ret
    
remove_zeros:
    xorl %eax, %eax
    movb final_result(,%edx, 1), %al
    decl %edx
    movb %al, final_result(, %edx, 1)
    addl $2, %edx
    cmpl size_counter, %edx
    jle remove_zeros
    decl %edx
    movl $0, final_result(, %edx, 1)
    jmp find_begining_zeros
