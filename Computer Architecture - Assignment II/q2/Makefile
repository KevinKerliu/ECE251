all: hw1_question2

hw1_question2: hw1_question2.o
	gcc -o hw1_question2 hw1_question2.o

hw1_question2.o: hw1_question2.s
	as -o hw1_question2.o hw1_question2.s

clean:
	rm -vf hw1_question2 *.o


