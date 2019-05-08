all: conc

conc: conc.o
	gcc -o conc conc.o

conc.o: conc.s
	as -o conc.o conc.s

clean:
	rm -vf conc *.o
