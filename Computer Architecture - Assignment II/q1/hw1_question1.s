/* hw1_question1.s */
/* Collatz Conjecture */

.text
.global main

main:
	mov r1, #123	/* r1 <-- 123, r1 is our number, n, for which we are computing the number of iterations of the Collatz Conjecture to reach 1 */
	mov r2, #0	/* r2 <-- 0, r0 represents the  number of iterations of the Collatz Conjecture */

check_loop:
	cmp r1, #1	/* compare r1 and 1, that is, compute r1 - 1 */
	beq end		/* if r1 and 1 are the same, that is, if r1 = 1 and their difference is 0,  branch to end */
	and r3,r1,#1	/* set r3 to the last bit of r1, if r1 is even then its last bit will be 0, if it is odd then its last bit will be 1 */
	cmp r3,#0	/* check whether r1 is even or odd by comparing its last bit to 0 */
	beq even	/* branch to even */
			/* there is no need to specify a branch if the number is odd as the next branch is odd */

odd:
	add r1,	r1, r1, LSL #1	 /* r1 <-- 2*r1 + r1 = 3*r1 via a  left bit shift and addition */
	add r1, r1, #1	 	 /* r1 <-- r1 + 1 */
	b iterate		 /*  branch to iterate */

even:
	mov r1, r1, ASR #1	/*r1 <-- r1/2 via a right bit shift that preserves sign */
				/* there is no need to specify a branch to go to as the next branch is iterate */

iterate:
	add r2, r2, #1		 /* r2 <-- r2 + 1, we have completed another iteration */
	b check_loop			 /* branch to check_loop */

end:
	mov r0, r2	/* r0 <-- r2, because echo $? returns r0 */
	bx lr		/* end of program */

/* It takes the Collatz Conjecture 46 iterations to reach 1 when n=123 */
