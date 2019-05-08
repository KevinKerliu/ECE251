/* calc.s */
/* Implementing a basic calculator in the ARMv8 assembly language */
/* Sources/Works Cited: thinkingeek.com and classmates Minh-Thai Nguyen and Junpeng Lu*/
/* Kevin Kerliu, Shyam Paidipati */

.data
.balign 4
scanpattern: .asciz "%f" 				// Input message format

.balign 4
printpattern: .asciz "Output: %lf\n"			// Output message format 

.balign 4
error_message: .asciz "ERROR. Invalid input.\n" 	// Error message for any error thrown 

.balign 4
storage_num: .skip 256 					// Array to store numbers 

.balign 4
storage_operator: .skip 64 				// Array to store operators and right parenthese 

.balign 4
check_operator: .word 0					// Address of previous operator (To do error checking when reading in input) 

.balign 4
stack_end: .word 0					// Address of the bottom of the stack 

.balign 4
return:	.word 0						// Address of return to exit out of main
	

.text
.global main
main:
// Section loads value of current lr for future exit and sets r2 as the address end of the stack to keep track of size of stack
	ldr r2, addr_return			// r2 <- &return 
	str lr, [r2]            		// *r2 <- lr
	ldr r2, addr_stack_end   		// r2 <- &stack_end 
	str sp, [r2]            		// *r2 <- sp 
// Making r4 start of input char array 
	ldr r4, [r1, #4]        		// r4 <- r1 + 4
	mov r5, #-1				// r5 <- #-1 (Done since we use increment before running through the loop ie. -1 -> 0 at 1st loop interation) 
	ldr r2, addr_check_operator     	// r2 <- &check_operator 
	str r4, [r2]            		// *r2 <- r4
// Making r6,r8 starts of storage operator and storage num respectively. r7, r9 act as indicies for r6, r8 respectively
// r10 is a check for right parentheses. This allows us to not need to to store left parentheses. r11 is a check for decimal points to make sure input is valid
	ldr r6, addr_storage_operator		// r6 <- &storage_operator 
	mov r7, #0 				// r7 <- #0
	ldr r8, addr_storage_num		// r8 <- &storage_num 
	mov r9, #0 				// r9 <- #0
	mov r10, #0				// was last operator a right parenthesis? 0 if no 
	mov r11, #0				// Was there another decimal point when passing over a number? 0 if no 
// Section includes interating through the input char array and indentifing each char and inputting them into corresponding arrays
read_and_determine_input:
	add r5, r5, #1             		// r5 <- r5 + 1 
	ldrb r3, [r4, r5]           		// r3 <- r4 shifted by r5 
	cmp r3, #0
	beq string_end            		// Check null char. If true, branch to string_end 
	cmp r3, #57                 		// Input > 57 is never valid under specification of project
	bgt error_print		    		
	cmp r3, #48	        		// Lowest number is ASCII 48. If within range of numbers, branch to num
	bge num
	cmp r3, #46	        		// Check for decimal point. (We check for it first since it is the easiest to check with r10 
	beq decimal
	cmp r3, #40				// Check for left parentheses. If left parentheses, branch to push_left_parentheses 
	beq push_left_parenthesis
	strb r3, [r6, r7]			// Preparing r3 for input. r3 is ith element of storage_operator
	add r7, r7, #1				// Incrementing index r7, which increments through r6 
	cmp r3, #43 				// Next for comparisons checks for +,-,*,/ in order. If it is those charecters, branch to push_op to put them in the array
	beq push_op
	cmp r3, #45            		 	
	beq push_op
	cmp r3, #42           			
	beq push_op
	cmp r3, #47           			
	beq push_op
	cmp r3, #41             		// Special case for pushing operators. Branch to push_right_parenthesis 
	beq push_right_parenthesis
	b error_print   			// Catching any unknown input. Branch to error
// Section catches an error of a poorly formatted input
num:
	cmp r10, #1				// If a right parenthese has been read before this, it is an invalid input 
	beq error_print 			// Branch to error to exit 
	b read_and_determine_input
// Section catches decimal errors, such as a decimal next to a parentheses or multiple decimals in one number input
decimal:
	cmp r10, #1				// If a right parenthese has been read before this input, it is an invalid input
	beq error_print 			// Branch to error to exit
	cmp r11, #1				// If a decimal has been read before this input, it is an invalid input 
	beq error_print 			// Branch to error to exit 
	mov r11, #1				// Decimal has been found. Update r11
	b read_and_determine_input
// Section addresses when a left parenthese has been read. Updates stack with location of left parenthese and updates r1 with correct index. Branches back to read_and_determine_input to get rest of input array
push_left_parenthesis:
	push {r7}               		// Index of left parenthese pushed onto stack 
	add r1, r4, r5          		// r1 <- r4 + r5 
	add r1, r1, #1          		// r1 <- r1 + #1 
	ldr r2, addr_check_operator    		// r2 <- &check_operator 
	str r1, [r2]            		// *r2 <- r1 (Updated r1)
	b read_and_determine_input
// Section has the same behavior as above but instead checks for right parentheses beforehand and logs index of right parenthese in check_operator
push_right_parenthesis:
	mov r0, r10 				// Stores check value to r0 (So it is not lost). r0 <- r10
	mov r10, #1         			// Since last op was a right parenthese, must update r10. r10 <- #1
	cmp r0, #0          			// Checking old value of r10. If it was not another right parenthese, number must be scanned
	beq push_num	    			 
	add r1, r4, r5      			// Next two lines update r1 to point to the correct element in the input char array. r1 <- r4 + r5 
	add r1, r1, #1      			// r1 <- r1 + #1
	ldr r2, addr_check_operator 		// r2 <- &check_operator 
	str r1, [r2]        			// *r2 <- r1 (Updated r1) 
	b read_and_determine_input
// Same as above
push_op:
	mov r0, r10         			// Stores check value to r0 (So it is not lost)
	mov r10, #0         			// Since last op was not a right parenthese (case taken above), must update r10. 
	cmp r0, #0          			// Checking old value of r10. If it was not a right parenthese, number must be scanned
	beq push_num        			
	add r1, r4, r5      			// Next two lines update r1 to point to the correct element in the input char array. 
	add r1, r1, #1      			// r1 <- r1 + #1 
	ldr r2, addr_check_operator  		// r2 <- &check_operator 
	str r1, [r2]        			// *r2 <- r1 (Updated r1) 
	b read_and_determine_input
// Section reads in number present and resets checks to take next input. The number goes into storage_num with index in input char array
push_num:
	mov r11, #0				// Decimal value taken care of before, so reset check to #0 
	mov r3, #0        			
	add r1, r4, r5      			// r1 <- r4 + r5 
	strb r3, [r1]       			// Loads null charecter from r3 into r1 
	ldr r2, addr_check_operator 		// r2 <- &check_operator 
	ldr r0, [r2]            		// r0 <- *check_operator 
	add r1, r1, #1          		 
	str r1, [r2]            		 
	ldr r1, =scanpattern    		// Prepare call to sscanf with registers r0, r1, r2 
	add r2, r8, r9          		// r2 points to ith element in storge_num
	add r9, r9, #4          		// Increment r9, pointer to storage_num 
	bl sscanf               		// Call to sscanf with r0,r1,r2
	cmp r0, #0
	blt error_print    			// Checking if sscanf throws an exception to parameters given. If so, exit program with error
	b read_and_determine_input              
// Section deals with when we reach the end of the input char array. Also does final error checking (ie. checks if input ends with right parenthese, checks if sscanf will throw exception at the end if the input array
string_end:
	strb r3, [r6, r7]       		// *r6 offset by r7 <- r3 
	ldr r7, addr_stack_end  		// r7 <- &stack_end 
	ldr r7, [r7]            		// r7 <- *r7
	cmp r10, #1				// Check to see if last op was right parenthese
	beq input_to_func_evaluate

	ldr r2, addr_check_operator 		// r2 <- &check_operator 
	ldr r0, [r2]            		// r0 <- *check_operator 
	ldr r1, =scanpattern    		// Prepare call to sscanf with registers r0, r1, r2 
	add r2, r8, r9          		// r2 points to ith element in storage_num  
	bl sscanf				// Call to sscanf with r0, r1, r2
	cmp r0, #0
	blt error_print				// Check if sscanf throws and exception to parameters given. If so, exit program with error
// Section checks to see if all values and pointers are valid. First starts checking if left parentheses were inputted
input_to_func_evaluate:
	cmp sp, r7              		// Checks to see if there are left parentheses. If not, go to solve inputted expression
	bne parentheses_evaluate         	 
	mov r0, r8             			// r0 <- addr_storage_num 
	mov r2, r6	            		// r2 <- addr_storage_operators 
	mov r10, #0				// Resets parenthese check. Used to check if left parentheses align up with right parentheses
	bl evaluate				// Calls function evaluate 
	b display_output
// Sections addresses if there are parentheses in the inputted char array. Makes calls to num_of_right_parentheses and evaluate to start addressing parentheses
parentheses_evaluate:
	pop {r2}                		// Number of operators before before the left parentheses that need to be evaluated 
	mov r1, r6              		// r1 <- r6. r1 is prepped for a call to num_of_right_parentheses
	add r2, r2, r6          		// r2 <- r2 + r6. r2 points to start of storage_operator 
	mov r3, #0              		
	bl num_of_right_parentheses		// Call to num_of_right_parentheses
	sub r0, r2, r6				// r0 <- r2 - r6
	sub r0, r0, r3          		// r0 <- r0 - r3
	lsl r0, r0, #2          		// r0 <- r0 *4  
	add r0, r8, r0          		// r0 points to correct element in storage_num (w.r.t current operation) 
	mov r10, #1				// Used to check if parentheses are alligned 
	bl evaluate
	b input_to_func_evaluate
// Counts the number of right parentheses before the starting element passed to the function. Parameters passed r1, r2
num_of_right_parentheses:
	cmp r1, r2				
	bxeq lr                 		// If at the end of storage_operator (meaning no more operators), branch to last plave link register points to
	ldrb r0, [r1]           		
	cmp r0, #41
	addeq r3, r3, #1  			// If equal, r3 <- r3 + #1      		 
	add r1, r1, #1          		// r1 <- r1 + #1
	b num_of_right_parentheses		
// Solves expression with no parentheses (Everything inside parentheses in input char array). Parameters passed r0, r2
evaluate:
	push {lr}				// Next three instructions push respective values to stack           			 
	push {r0}           			 
	push {r2}           			 
	mov r1, r0          			// r1 and r3 point to start of storage_num, storage_operator respectively
	mov r3, r2          			
	flds s1, [r0]       			// Loads floating point value to s1 
// Section addresses multiply and divide operators. With the null charecters inputted into storage_operator, set_function_parameters allows for reindexing of both arrays
multiply_and_divide:
	fcpys s0, s1        			
	ldrb r4, [r2]       			// r4 <- storage_operator[i] 
	cmp r4, #0          			// First comparison checks if the null char is reached in storage_operator. Second comparison checks if a right parenthese is on the top of storage_operator 
	beq set_function_parameters        	// Both brach to set_function_parameters if they are true		 
    	cmp r4, #41         			
	beq set_function_parameters        			
	flds s1, [r0, #4]   			// s1 <- storage_num[i+1] 
	add r0, r0, #4      			// r0 <- r0 + 4 
	add r2, r2, #1      			// r2 <- r2 + 1 
	cmp r4, #42				// Checks if multiplication or division is needed. If not, puts operator back into array and increments the pointers fro both arrays
	beq multiply            		
	cmp r4, #47
	beq divide             			 
	fsts s0, [r1]				
	strb r4, [r3]				// Puts operator back into storage_operator for later evaluation
	add r1, r1, #4      			// r1 <- r1 + #4 
	add r3, r3, #1      			// r3 <- r3 + #1 
	b multiply_and_divide
// Section simply multiplies or divides numbers
multiply:
	fmuls s1, s1, s0    			
	b multiply_and_divide
divide:
	fdivs s1, s0, s1    			
	b multiply_and_divide
// Stated above. 
set_function_parameters:
	bl iterate_storage_num           	// Call to itererate_storage_num to look at next elements 
	pop {r2}            			// r2 is now the starting point in storage_operator 
	pop {r0}            			// r0 is now the starting point in storage_num
	mov r1, r0          			
	mov r3, r2          			
	flds s1, [r0]       			// s1 <- storage_num[k]  
// Section addresses add and subtract operations. 
addition_and_subtraction:
	fcpys s0, s1        			// s0 <- s1 
	ldrb r4, [r2]       			// r4 <- &r2 
	cmp r4, #0          			// If the null charecter is reached, that means there are no more operators to check. Go to final_check_and_exit to prepare to return value and exit
	beq final_check_and_exit       			
    	cmp r4, #41         			// If the last right parenthese is reached, same condition as above with final check in end_expression 
	beq end_expression         		
	flds s1, [r0, #4]   			
    	add r0, r0, #4      			// r0 <- r0 + #4 
    	add r2, r2, #1      			// r2 <- r2 + #1 
	cmp r4, #43         			// If addition sign, add the numbers  
	beq add        				
// Sections simply adds or subtracts numbers
subtract:
	fsubs s1, s0, s1    			
	b addition_and_subtraction      	

add:
	fadds s1, s0, s1    			
	b addition_and_subtraction      	
// Set up for final_check_and_exit
end_expression:
	sub r10, r10, #1			// r10 <- r10 - #1. Resets check for parentheses for next section
	add r2, r2, #1      			// r2 <- r2 + 1. Skip parentheses while incrementing storage_operator
// Checks if number of left parentheses equals number of right parentheses and makes a call to iterate_storage_num to prepare to exit
final_check_and_exit:
	cmp r10, #0
	bne error_print
	bl iterate_storage_num           	// call interate_storage_num to iterate through storage_num
	pop {lr}            			
	bx lr               			// exit with lr
// Function iterates through elements of storage_num
iterate_storage_num:
	fsts s0, [r1]       			// *r1 <- s0 
	add r1, r1, #4      			// Increments r1 

// Section iterates through storage_operator until the null character at the end is reached
loop:
	ldrb r4, [r2]       			// r4 <- &r2 
	strb r4, [r3]       			// *r3 <- r4 
	add r2, r2, #1      			// Iterator reading storage_operator is incremented 
	add r3, r3, #1      			// Iterator storing in storage_operator is incremented  
	cmp r4, #41		    		// If a right parenthese is reached, restart loop to increment past 
	beq loop      				 
	cmp r4, #0x00       			// If null charecter is reached, return to lr 
	bxeq lr             			 
	flds s1, [r0, #4]  			// s1 <- storage_num[i+1] 
	add r0, r0, #4     			
	fsts s1, [r1]       			// storage_num[r3] <- s1 
	add r1, r1, #4     			
	b loop
// Section displays result with double precision
display_output:
	ldr r2, addr_storage_num   		// r4 <- &storage_num 
	flds s0, [r2]           		// s0 <- &r2 
	fcvtds d0, s0           		// Changes value from single precision to double precision 
	vmov r2, r3, d0         		// r2,r3 <- d0 
	ldr r0, =printpattern			// Prepare for call to printf by loading r0 with pattern
	bl printf               		// prints output message, the evaluation 
// Section exits out of main using the lr register
exit:
	ldr r1, addr_return  			// r1 <- &return 
	ldr lr, [r1]       			// lr <- return 
	bx lr               			// exit out of main 
// Section prints error message anytime an error is thrown
error_print:
	ldr r0, =error_message
	bl printf
	b exit

/* Functions */
/*
num_of_left_parentheses:
	cmp r1, r2
	bxeq lr                 		 
	ldrb r0, [r2]           		
	cmp r0, #40
	addeq r3, r3, #1        		 
	add r2, r2, #1          		
	b num_of_left_parentheses		 
*/


/* Labels to access data */
addr_return: 		.word return
addr_stack_end: 	.word stack_end
addr_storage_operator:	.word storage_operator
addr_storage_num: 	.word storage_num
addr_check_operator:	.word check_operator

/* External */
.global printf
.global sscanf
