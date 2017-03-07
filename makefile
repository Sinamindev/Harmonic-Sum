runme: harmonic-driver.cpp harmonic.o debug.o
	g++ harmonic-driver.cpp harmonic.o debug.o -o runme

harmonic.o: harmonic.asm 
	nasm -f elf64 harmonic.asm -o harmonic.o


