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

.global add
.type add, @function

add:
        pushl %ebp			# push content of ebp register on the stack
	movl %esp, %ebp	
	pushl %ebx

	jmp get_first_number

get_first_number:
	movl 8(%ebp), %ecx
	movl $0, %edi

mov_first_number:
	movb (%ecx, %edi, 1), %dl
	movb %dl, first_number(, %edi, 1)
	incl %edi
	cmpb $0, %dl
	je mov_first_exit
	jmp mov_first_number

mov_first_exit:
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
	je mov_second_exnit
	jmp mov_second_number

mov_second_exnit:
	subl $3, %edi
	movl %edi, second_number_length
	movl second_number_length, %eax

determine_loop_length:
        movb $0, carry			# zero possible carry
        movl first_number_length, %edi
        cmpl second_number_length, %edi
        jg start_calc_start
        movl second_number_length, %edi		# designated number of loops
        movl %edi, number_len		# result length

start_calc_start:
        movl %edi, size             
        incl %edi

start_calc:
        xorl %edx, %edx			# reset edx
        movl first_number_length, %edx		# copy length of the first number to the register
        cmpl $0, %edx			# compare 
        jl first_number_end		# jump if less to first_number_end
        xorl %ebx, %ebx			# reset ebx
        decl first_number_length		# decrease length number for read to another digit in next iteration
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
        jge start_add			# jump if greater or equal to start_add
        cmpl $0, second_number_length
        jge start_add
        cmpl $0, %eax			# the length will be zeroed first but the values will still be
        jne start_add
        cmpl $0, %ebx
        jne start_add
        cmpl $1, carry
        je start_add
        jmp exit_calc

start_add:
        addl %ebx, %eax			# add registry values
        addl carry, %eax		# add possible carry
        movb $0, carry			# zero carry

        cmpl $10, %eax			# check if sum is not larger than 10 
        jb save_result			# if sum is below 10, jump to save_result

        subl $10, %eax			# if the result is greater than the base (10), the base (10) is subtracted
        movb $1, carry			# and carry is activated
        jmp save_result

save_result:
        pushl %eax
        call number_to_char
        addl $4, %esp

        movb %al, result(, %edi, 1)	# save the result to the variable "result"
        decl %edi			# and decrement the register after "result"

        jmp start_calc

exit_calc:
        xorl %edi, %edi
        xorl %eax, %eax
        movb result(, %edi, 1), %al
        cmpl $'1', %eax
        je exit_calc_next
        movb $'0', result(, %edi, 1)

	call find_zeros

exit_calc_next:
	movl $result, %eax
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret

.type char_to_number, @function
char_to_number:
        pushl %ebp
        movl %esp, %ebp
        xorl %ebx, %ebx			# zero ebx
        movl 8(%ebp), %ebx		# put a character into ebx
        subb $0x30, %bl			# subtract the value of the character '0' from the character, the number remains
        movl %ebx, %eax			# conversion successful, rewrite ebx to eax
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
	movl $0, %edx
	decl size_counter
	movb result(,%edx,1), %al
	incl %edx
	cmpl $'0', %eax
	je remove_zeros
	ret

remove_zeros:
	xorl %eax, %eax
	movb result(,%edx,1), %al
	decl %edx
	movb %al, result(,%edx,1)
	addl $2, %edx
	cmpl size_counter, %edx
	jle remove_zeros
	decl %edx
	movl $0, result(,%edx,1)
	jmp find_begining_zeros
