all: hw1_question1

hw1_question1: hw1_question1.o
	gcc -o hw1_question1 hw1_question1.o

hw1_question1.o: hw1_question1.s
	as -o hw1_question1.o hw1_question1.s

clean:
	rm -vf hw1_question1 *.o
