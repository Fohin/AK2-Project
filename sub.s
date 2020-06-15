.section .bss
.equ BYTES_2K, 2048
.equ BYTES_4K, 4096
.equ LENGTH, 8
.equ BYTE, 1
.lcomm first_number, BYTES_2K
.lcomm second_number, BYTES_2K
.lcomm first_number_length, LENGTH
.lcomm second_number_length, LENGTH
.lcomm number_len, LENGTH
.lcomm result, BYTES_4K
.lcomm carry, BYTE

.data
    size: .long 0
    size_counter: .long 0
    base: .byte 10

.text

.global sub
.type sub, @function
sub:
	pushl %ebp			# push content of ebp register on the stack
	movl %esp, %ebp
	pushl %ebx

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
	movl second_number_length, %eax

determine_number_of_iteration:
        movb $0, carry			# zero possible carry
        movl first_number_length, %edi
        cmpl second_number_length, %edi
        jg start_calc
        movl second_number_length, %edi		# designated number of loops
        movl %edi, number_len		# result length
		movl %edi, size

start_calc:
	movl first_number_length, %edx		# copy length of the first number to the register
	cmpl $0, %edx			# compare
	jl first_number_end		# jump if less to first_number_end
	xorl %ebx, %ebx			# reset ebx
	decl first_number_length		# decrease length number for read to another digit in next
	movb first_number(, %edx, 1), %bl	# load a character to ebx

	pushl $base
	pushl %ebx
	call char_to_number
	addl $8, %esp
	cmpb base, %al			# invalid values
	jge get_first_number		# back to questions about numbers

	jmp continue_calc

first_number_end:
	xorl %eax, %eax			# pass through the whole first number

continue_calc:
	xorl %ebx, %ebx	
	movl second_number_length, %edx		# load the second number into the register
	cmpl $0, %edx	
	jl second_number_end	
	decl second_number_length		
	movb second_number(, %edx, 1), %bl	# loading a character to ebx

	pushl %eax			# put the digit from the first number on the stack

	pushl $base
	pushl %ebx
	call char_to_number
	addl $8, %esp
	cmpb base, %al
	jge get_first_number
	
	movl %eax, %ebx			# in ebx there is now a digit from the second number
	popl %eax			# restore the digit from the first number

second_number_end:
	cmpl $0, first_number_length
	jge start_sub			# jump if greater or equal to start_sub
	cmpl $0, second_number_length
	jge start_sub
	cmpl $0, %eax			# the length will be zeroed first but the values will still be
	jne start_sub
	cmpl $0, %ebx
	jne start_sub
	cmpl $1, carry
	je start_sub
	jmp exit_calc

start_sub:
	subl %ebx, %eax			# subtract registry values
	xorl %ecx, %ecx
	movl carry, %ecx
	subl carry, %eax		# subtract potential loan
	movb $0, carry 
	cmpl $0, %eax
	jge save_result
	
	addl base, %eax			# if the result is less than 0 then add the base...
	movb $1, carry			# ... and activate the loan

save_result:
	pushl %eax
	call number_to_char
	addl $4, %esp

	movb %al, result(, %edi, 1)	# save the result to the variable "result"
	decl %edi			# and decrement the register after "result"

	jmp start_calc

exit_calc:
	call find_zeros
	movl $result, %eax
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

.type find_zeros, @function
find_zeros:
	xorl %edx, %edx
	xorl %eax, %eax
	xorl %ecx, %ecx
	movl size, %eax
	movl %eax, size_counter
	addl $3, size_counter
	xorl %eax, %eax

find_begining_zeros:
	movl $0, %edx		# index from zero
	decl size_counter
	movb result(, %edx, 1), %al
	incl %edx
	cmpl $'0', %eax
	je remove_zeros
 	#movl %ebp, %esp
	#popl %ebp
	ret
    
remove_zeros:
	xorl %eax, %eax
	movb result(, %edx, 1), %al
	decl %edx
	movb %al, result(, %edx, 1)
	addl $2, %edx	
	cmpl size_counter, %edx
	jle remove_zeros
	decl %edx
	movl $0, result(, %edx, 1)
	jmp find_begining_zeros
