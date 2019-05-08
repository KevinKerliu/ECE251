/* sort.s */
/* Loading integers from a file, sorting them, and  writing them to another file */

.data // Make sure variable data is 4 byte aligned

.balign 4
array: .skip 400

.balign 4
prompt1: .asciz "Enter input file name: "	// File of unsorted integers

.balign 4
prompt2: .asciz "Enter output file name: "	// File of sorted integers

.balign 4
scanpattern: .asciz "%s" 			// Scan pattern for scanf

.balign 4
printpattern: .asciz "%d\n"			// Print pattern for printf

.balign 4
writeMode: .asciz "w"				// Write mode for fopen

.balign 4
readMode: .asciz  "r"				// Read mode for fopen

.balign 4
userin: .skip 100				// Store input file name

.balign 4
userout: .skip 100				// Store output file name

.balign 4
inputfilestream: .word 0			// Store input filestream pointer

.balign 4
outputfilestream: .word 0			// Store output filestream pointer

.balign 4
tempint: .word 0				// Temporary integer used for copying each integer into the array one by one from the input file 

.balign 4
errormessage: .asciz "ERROR, input file too large!\n"

.balign 4
return: .word 0					// Store link register to return back to main


.text

.global main
main:
	ldr r1, addr_return		// r1 <- &return
	str lr, [r1]			// return <- *lr

	ldr r0, addr_prompt1		// r0 <- &prompt1
	bl printf			// Call to printf with r0 argument

	ldr r0, addr_scanpattern	// r0 <- &scanpattern
	ldr r1, addr_userin		// r1 <- &userin
	bl scanf			// Call to scanf with r0 and r1 arguments

	ldr r0, addr_prompt2		// r0 <- &prompt2
	bl printf			// Call to printf with r0 argument

	ldr r0, addr_scanpattern	// r0 <- &scanpattern
	ldr r1, addr_userout		// r1 <- &userout
	bl scanf			// Call to scanf with r0 and r1 arguments

	ldr r0, addr_userin		// r0 <- &userin
	ldr r1, addr_readMode		// r1 <- &readMode
	bl fopen			// Call to fopen with r0 and r1 arguments

	ldr r1, addr_inputfilestream	// r1 <- &inputfilestream
	str r0, [r1]			// Storing file pointer into r1

	ldr r0, addr_userout		// r0 <- &userout
	ldr r1, addr_writeMode		// r1 <- &writeMode
	bl fopen			// Call to fopen with r0 and r1 arguments

	ldr r1, addr_outputfilestream	// r1 <- &outputfilestream
	str r0, [r1]			// Storing file pointer into r1

 	mov r6, #0			// Iterator for file
	mov r7, #0			// Iterator for print

file_loop:
	cmp r6, #100			// Make sure file is at most 100 lines
	bgt error			// Error if there were more than 100 integers

	ldr r0, addr_inputfilestream	// r0 <- &inputfilestream
	ldr r0, [r0]			// r0 <- contents of inputfilestream
	ldr r1, addr_printpattern	// r1 <- &printpattern, reusing
	ldr r2, addr_tempint		// r2 <- &tempint
	bl fscanf			// Call to fscanf with arguments r0, r1, and r2

	cmp r0, #1			// Check when fscanf hits the end of file
	bne sort_loop			// Branch to sort at end of file

	ldr r0, addr_tempint		// r0 <- &tempint
	ldr r0, [r0]			// r0 <- contents of tempint
	ldr r1, addr_array		// r1 <- &array
	mov r4, r6			// r4 <- r6, this is the i-th element
	lsl r4, r4, #2			// r4 <- r4 * 4, this is the address offset

	str r0, [r1, r4]		// r0 <- r1 + r4
	add r6, r6, #1			// r6 <- r6 + 1
	b file_loop			// Branch to loop

error:
	ldr r0, addr_inputfilestream	// r0 <- &inputfilestream
	ldr r0, [r0]			// r0 <- contents of inputfilestream
	bl fclose			// Call to fclose with argument r0

	ldr r0, addr_outputfilestream	// r0 <- &outputfilestream
	ldr r0, [r0]			// r0 <- contents of inputfilestream
	bl fclose			// Call to fclose with argument r0

	ldr r0, addr_errormessage	// r0 <- &errormessage
	bl printf			// Call to printf with argument r0

	ldr r1, addr_return		// r1 <- &return
	ldr lr, [r1]			// lr <- *return
	bx lr				// Return out of main

sort_loop:
	ldr r0, addr_array		// r0 <- &array. r0 now points to the start of array
	mov r10, #0			// r10 is the swap check register. r10 <- 0
	sub r11, r6, #1			// Number of iterations of sort_loop = size of array-1
	mov r5, #1			// Index that goes through array from array[0]

sort_loop2:
	ldr r8, [r0]			// r8 is a register to hold a value for comparison
	ldr r9, [r0, #4]		// r9 is a register to hold a value for comparison
	cmp r8, r9			// Comparing the two values
	ble no_swap			// Branch to no_swap if r8 <= r9
	str r8, [r0, #4]		// Next two lines swap the values in  r8 and r9
	str r9, [r0]
	mov r10, #1			// Making the swap check register true

no_swap:
	add r0, r0, #4			// Going to the next element in the array
	cmp r5, r11			// Seeing if we are at end of array
	add r5, r5, #1			// Incrementing the index that goes through array
	blt sort_loop2			// Branch to sort_loop2 if more comparisons need to be done
	cmp r10, #1			// Check to see if a swap has been done
	beq sort_loop			// Go back to the start if a swap has been done


print_loop:
	cmp r6, r7			// Compare the iterators
	beq end				// Check if we have written every member of the array to the output file

	ldr r0, addr_outputfilestream	// r0 <- &outputfilestream
	ldr r0, [r0]			// r0 <- contents of outputfilestream
	ldr r1, addr_printpattern	// r1 <- &printpattern
	ldr r2, addr_array		// r2 <- &array
	mov r4, r7			// r4 <- r7
	lsl r4, r4, #2			// r4 <- r4 * 4
	ldr r2, [r2,r4]			// r2 <- r2 + r4
	bl fprintf			// Call to fprintf with arguments r0, r1, and r2
	add r7, r7, #1			// r7 <- r7 + 1
	b print_loop			// Branch to print

end:
	ldr r0, addr_inputfilestream	// r0 <- &inputfilestream
	ldr r0, [r0]			// r0 <- contents of inputfilestream
	bl fclose			// Call to fclose with argument r0

	ldr r0, addr_outputfilestream	// r0 <- &outputfilestream
	ldr r0, [r0]			// r0 <- contents of outputfilestream
	bl fclose			// Call to fclose with argument r0

	ldr r1, addr_return		// r1 <- return
	ldr lr, [r1]			// lr <- *return
	bx lr				// return out of main

/* Labels to access data */
addr_array: .word array
addr_prompt1: .word prompt1
addr_prompt2: .word prompt2
addr_scanpattern: .word scanpattern
addr_printpattern: .word printpattern
addr_writeMode: .word writeMode
addr_readMode: .word readMode
addr_userin: .word userin
addr_userout: .word userout
addr_inputfilestream: .word inputfilestream
addr_outputfilestream: .word outputfilestream
addr_tempint: .word tempint
addr_errormessage: .word errormessage
addr_return: .word return

/* External */
.global fopen
.global fclose
.global scanf
.global printf
.global fscanf
.global fprintf
