
section .bss
buffer1  resb 100 ; Buffer for user input
 

buffer2 resb 100 ; Buffer for user input

section .data
msg_size db "Input size is: "
len_msg_size equ $ - msg_size
error_msg db "Input should be smaller than 99 characters.", 0xA
error_len equ $ - error_msg
invalid_msg db "Invalid character: ", 0xA
invalid_len equ $ - invalid_msg
newline db 0xA ; Newline character





section .text
    global _start
print_string:
    ; This function prints the modified input map to the user
    mov rax, 1 ; syscall: write
    mov rdi, 1 ; file descriptor: stdout
    syscall
    ret
print_map:
; This function prints the modified input map to the user
push rcx ; Save rbx on the stack
push rdx ; Save rdx on the stack
xor rcx, rcx ; Clear rcx for counting
.count:
cmp byte [rsi + rcx], 0xA ; Check for newline character
jz .do_print ; If newline is found, exit loop
inc rcx ; Move to the next character
cmp rcx, 100 ; Check if we have reached the maximum length
jge error_too_long ; If we have reached the maximum length, jump to error handling
jmp .count ; Continue counting characters
.do_print:
mov rdx, rcx ; Length of string to print
call print_string ; Call print_string to print the modified input
mov rsi, newline ; syscall: write
mov rdx, 1 ; Length of newline character
call print_string ; Print newline after the modified input
pop rcx ; Restore rbx from the stack
ret

_start:
; this is part 1 of the code, which prompts the user for input and processes it
; Prompt user for input
mov rax, 0 ; syscall: write
mov rdi, 0 ; file descriptor: stdin
mov rsi, buffer1 ; Buffer to store input
mov rdx, 100 ; Number of bytes to read
syscall
; Process input (for simplicity, we just echo it back)
cmp rax, 1 ; Check if read was successful
jl empty_input ; If no input, jump to empty input handling
cmp rax, 100 ; Check if read was successful
jge error_too_long ; If no input, jump to empty input handling
mov rbx, rax ; Store the number of bytes read in rbx
dec rbx ; Decrease by 1 to account for newline character
jmp empty_input ; Jump to empty input handling
empty_input:
mov rbx, 0 ; If no input, set length to 0
print_size:
mov rsi, msg_size ; Load address of message size string
mov rdx, len_msg_size ; Load length of message size string
call print_string ; Print message size string

mov r8, 10 ; Base 10 for division
mov rax, rbx ; Move input length to rax for printing
mov r9, rsp ; Clear r9 for counting digits
sub rsp, 16 ; Allocate space on stack for digits
mov rcx, 0 ; Clear rcx for counting digits
.num_loop:
xor rdx, rdx ; Clear rdx for division
div r8 ; Divide rax by 10, quotient in rax and remainder in rdx
add rdx, '0' ; Convert remainder to ASCII character
mov [rsp + rcx], dl ; Store digit on stack
inc rcx ; Move to the next digit
test rax, rax ; Check if quotient is zero
jnz .num_loop ; If quotient is not zero, continue loop
; Print the digits in reverse order
.print_num:
dec rcx ; Move back to the last digit
lea rsi, [rsp + rcx] ; Load address of current digit
mov rdx, 1 ; Length of digit character
call print_string ; Print current digit
test rcx, rcx ; Check if we have printed all digits
jnz .print_num ; If there are more digits, continue printing
mov rsp, r9 ; Restore stack pointer
mov rsi, newline ; Load address of newline character
mov rdx, 1 ; Length of newline character
call print_string ; Print newline after the message size
mov rcx, 0 ; Clear rcx for counting characters
; This is part 2 of the code, which checks the validity of the input and simulates the character movements
check_char:
cmp rcx, rbx ; Check if we have processed all characters
jz valid_done ; If all characters are valid, jump to success handling
mov al, [buffer1 + rcx] ; Load current character
cmp al, '-' ; Check if character is '-'
je .next_char
cmp al, 'x' ; Check if character is 'x'
je .next_char
cmp al, 'o' ; Check if character is 'o'
je .next_char
cmp al, 0xA ; Check if character is newline
je .next_char
; If character is invalid, print error message and exit
push rax ; Save rax on the stack
mov rsi, invalid_msg ; Load address of invalid character message
mov rdx, invalid_len ; Load length of invalid character message
call print_string ; Print invalid character message
mov [rsp - 1], al ; Store invalid character on stack
mov rsi, rsp - 1 ; Load address of invalid character
mov rdx, 1 ; Length of invalid character
call print_string ; Print invalid character
pop rax ; Restore rax from the stack
jmp exit_error ; Exit with error status
.next_char:
inc rcx ; Move to the next character
jnz check_char ; If there are more characters, continue checking
; If all characters are valid, print success message and exit
valid_done:
mov rsi, buffer1 ; Load address of user input
call print_map ; Print the original input
mov r10, 0 ; Clear r10 for counting characters
mov r11, buffer1 ; Load address of user input
mov r12, buffer2 ; Load address of output buffer

; This is part 3 and 4 of the code, which simulates the character movements and prints the modified input
.sim_loop:
cmp r10, rbx ; Check if we have processed all characters
jge .sim_done ; If all characters are processed, jump to done
mov rsi, r11 ; Load address of current character
mov rdi, r12 ; Load address of output buffer
mov rcx, 0 ; Length of character to write
.update_loop:
cmp rcx, rbx ; Check if we have processed the current character
jz .update_end ; If current character is processed, jump to done
mov al, [rsi + rcx] ; Load current character
mov ah, [rsi + rcx + 1] ; Write character to output buffer
cmp ah, 0xA ; Check if next character is newline
je .write_last
cmp al, 'x' ; Check if character is 'x'
jne .check_hole
cmp ah, 'o' ; Check if next character is 'o'
jne .check_empty_x
mov byte [rdi + rcx], '-' ; If character is valid, write it to output buffer
mov byte [rdi + rcx + 1], '-' ; If character is valid, write it to output buffer
add rcx, 2 ; Move to the next character
jmp .update_loop ; Continue updating current character
.swap_chars:
mov byte [rdi + rcx], '-' ; Swap 'o' and newline to '-'
mov byte [rdi + rcx + 1], 'o' ; Swap 'o' and newline to '-'
add rcx, 2 ; Move to the next character
jmp .update_loop ; Continue updating current character
.check_empty_x:
cmp al, '-' ; Check if character is '-'
jne .x_blocked
mov byte [rdi + rcx], '-' ; If character is 'o', write it to output buffer
mov byte [rdi + rcx + 1], 'x' ; If character is 'x', write it to output buffer
add rcx, 2 ; Move to the next character
jmp .update_loop ; Continue updating current character
.x_blocked:
mov [rdi + rcx], al ; If character is 'x', write it to output buffer
inc rcx ; Move to the next character
jmp .update_loop ; Continue updating current character
.check_hole:
cmp al, 'o' ; Check if character is 'o'
jne .copy_one
mov [rdi + rcx], al ; If character is 'o', write it to output buffer
inc rcx ; Move to the next character
jmp .update_loop ; Continue updating current character
.copy_one:
mov [rdi + rcx], al ; If character is '-', write it to output buffer
inc rcx ; Move to the next character
jmp .update_loop ; Continue updating current character
.write_last:
mov [rdi + rcx], al ; Write last character as '-'
mov byte [rdi + rcx + 1], 0xA ; Write last character as newline
.update_end:
mov rsi, r12 ; Load address of user input
call print_map ; Print the modified input
mov rax, r11 ; Move input length to rax for printing
mov r11, r12 ; Base 10 for division
mov r12, rax ; Move input length to r12 for printing
inc r10 ; Increase character count
jmp .sim_loop ; Continue simulating characters
.sim_done:
; Exit with success status
mov rax, 60 ; syscall: exit
xor rdi, rdi ; status: 0
error_too_long:
; Print error message for input that is too long
mov rax, 1 ; syscall: write
mov rdi, 2 ; file descriptor: stderr
mov rsi, error_msg ; Load address of error message
mov rdx, error_len ; Load length of error message
call print_string ; Print error message
exit_error:
; Exit with error status
mov rax, 60 ; syscall: exit
mov rdi, 1 ; status: 1
syscall

















    


