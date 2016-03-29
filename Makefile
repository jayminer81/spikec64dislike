spike: spikec64like.asm
	ca65 -o spikec64like.o -t c64 spikec64like.asm
	ld65 -o spikec64like.prg -C c64.cfg spikec64like.o

clean:
	rm *.o *.prg
