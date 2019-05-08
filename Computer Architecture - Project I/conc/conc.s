/*conc.s*/

/*Data Section*/
.data

.balign 4
message1: .asciz "Type a string 1: " /* First Prompt */

.balign 4
message2: .asciz "Type string 2: " /*Second Prompt */

.balign 4
errmessage: .asciz "Your string is too long\n"

.balign 4
scanpattern: .asciz " %[^\n]s" /* Scan pattern for scanf */

.balign 4
userin: .skip 100 /* space for all inputs from user */

.balign 4
fmessage: .asciz "The result is : %s\n" /*Final message to show output */

.balign 4
output: .skip 21 /* space holding the final string. 10 chars each per word plus \0 */

.balign 4
return: .word 0 /* holds original value of lr to be able to return from main */

.balign 4
error1: .word 21 /*variable with 21 */

.balign 4
error2: .word 22 /*variable with 22 */
.text

.global main
main:
	/* Storing original value of lr */
	ldr r1, addr_return		/* r1 <- &return */
	str lr, [r1]			/* return <- *lr */

	/* Prompting first word from user */
	ldr r0, addr_message1		/* r0 <- &message1 */
	bl printf			/* call to printf with r0 parameter */

	/* Getting first word from user */
	ldr r0, addr_scanpattern	/* r0 <- &scanp */
	ldr r1, addr_userin		/* r1 <- &userin */
	bl scanf			/* call to scanf with r0, r1 parameters */

	/* Set up for conditional checks */
	ldr r0, addr_userin		/* r0 <- &userin. Puts address of inputted word in r0 */
	ldr r4, addr_output		/* r4 <- &output */
	mov r5, #0			/* Total number of char */
	mov r6, #0			/* Index for inputted words */
 	b loop1				/* branches to loop1 */

loop1:
	ldrb r2,[r0,r5]			/* Takes the char at the r5 offset from r0 */
	cmp r5, #11			/* If r5 is 10, string is invalid. Char loaded into r2 is void */
	beq err1			/* branch to err1 */
	cmp r2, #0x00			/* looking for the null charecter */
	/* All strings end with null charecter */
	beq prompt2			/* Branch to prompt2 if they are the same */
	str r2, [r4, r5]		/* storing the char into the output. Using r5 as index since it
					is the total number of char */
	add r5, r5, #1			/* Increments the index */

	b loop1				/* Unconditional branching to allow every char in the first string
					to be interated through */

prompt2:
	ldr r0, addr_message2		/* r0 <- &message2 */
	bl printf			/* call to printf with r0 parameter */

	ldr r0, addr_scanpattern	/* r0 <- &scanpattern */
	ldr r1, addr_userin		/* r1 <- &userin */
	bl scanf			/* call to scanf with r0, r1 parameters */

	ldr r0, addr_userin		/*r0 <- &userin. Puts address of inputted word in r0 */
	mov r1, #0			/* Another index for inputted words. r5 now total chars */
	b loop2				/* branches to loop2 */

loop2:
	ldrb r2, [r0, r1]		/* Takes the char at the r1 offset from r0 */
	cmp r1, #11			/* If r1 is 10, string is invalid, Char loaded into r2 is void */
	beq err2			/* branch to err2 */
	cmp r2, #0x00			/* looking for null charecter */
	beq end				/* If null char then both strings have been collected */
	str r2, [r4, r5]		/* storing the char into the outpit. Using r5 as index since it
					is the total number of char */
	add r5, r5, #1			/* incrementing the total char count */
	add r1, r1, #1			/* incrementing the index */
	b loop2				/* Unconditional branching to allow ever char in the 2nd string
					to be interated through */
err1:
	ldr r0, addr_errmessage		/* r0 <- &errmessage */
	bl printf			/* call to printf with r0 parameter */

	/* Making error code 21 */
	ldr r0, addr_error1		/* r0 <- &error1 */
	ldr r0, [r0]			/* r0 <- *error1 */

	/* Loading original value of lr into lr */
	ldr r1, addr_return		/* r1 <- &return */
	ldr lr, [r1]			/* lr <- *r1 */
	bx lr				/* return out of main */

err2:
	ldr r0, addr_errmessage		/* r0 <- &errmessage */
	bl printf			/* call to printf with r0 parameter */

        /* Making error code 22 */
        ldr r0, addr_error2             /* r0 <- &error2 */
        ldr r0, [r0]                    /* r0 <- *error2 */

        /* Loading original value of lr into lr */
        ldr r1, addr_return             /* r1 <- &return */
        ldr lr, [r1]                    /* lr <- *r1 */
        bx lr				/* return out of main */

end:
	mov r2, #0x00			/* storing null char to put at the end of output */
	str r2, [r4, r5]		/* stores null char at end of output */
	ldr r0, addr_fmessage		/* r0 <- &fmessage */
	ldr r1, addr_output		/* r1 <- &output */
	bl printf 			/* call to printf with parameters r0, r1 */

	mov r0, r5			/* final char count */
	/* Loading original value of lr into lr */
	ldr r1, addr_return		/* r1 <- &return */
	ldr lr, [r1]			/* lr <- *return */
	bx lr				/* return out of main */

/* labels to access data */
addr_scanpattern: .word scanpattern
addr_message1: .word message1
addr_message2: .word message2
addr_fmessage: .word fmessage
addr_userin: .word userin
addr_output: .word output
addr_return: .word return
addr_error1: .word error1
addr_error2: .word error2
addr_errmessage: .word errmessage
/*Externals*/
.global printf
.global scanf
