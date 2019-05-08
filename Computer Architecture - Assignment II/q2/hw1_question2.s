/* homework1_q2.s */
/* Fibonacci Seqeunce */

.text
.global main

main:
	mov r1, #10	/* r1 <-- 10, r1 is our number, n, for which we are computing the Fibonacci Sequence */
	mov r2, #2	/* r2 <-- 0, r0 represents the Fibonacci number we have computed thus far, start at 2 as Fib(1) and Fib(2) are just 1 and we will preset them */
			/* Fib(0) is 0, but we can ignore that */
	mov r3, #1	/* r3 <-- 1, r3 represents the first number of the Fibonacci Sequence, Fib(1) is  1 */
	mov r4, #1	/* r4 <-- 1, r4 represents the second number of the Fibonacci Sequence, Fib(2) is  1 */
			/* from here we can compute the rest of the sequence, we will overwrite r3 and r4 later as it is not necessary to access Fib(1) and Fib(2) outside of main */
	cmp r1, #1	/* if r1 = 1, we are done as Fib(1) is just 1 */
	beq end

	cmp r1, #1	/* if r1 = 2, we are done as Fib(2) is just 1 */
	beq end

fib_loop:
	cmp r1, r2	/* check our end condition, if r1 = r2 */
	beq end

	mov r5, r4	/* r5 <-- r4, temp save */
	add r4, r4, r3  /* r4 <-- r4 + r3, compute the next number is the Fibonacci Sequence */
	mov r3, r5	/* r3 <-- r5, the previous r4 */
			/* Notice that r4 represents our most recently computed Fibonacci number, while r3 represents the number right before that one in the sequence */
	add r2, r2, #1	/* r2 <-- r2 + 1, we have just cmputed another number in the Fibonacci Sequence */
	b fib_loop 	/* branch to fib_loop */

end:
	mov r0,r4	/* r0 <-- r4 */
	bx lr 		/*  end program */

/* Fib(10) = 55 */
