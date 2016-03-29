# Spike C64 Dislike Makefile
# Keeping it simple!

spike: spikec64dislike.asm
	ca65 -o spikec64dislike.o -t c64 spikec64dislike.asm
	ld65 -o spikec64dislike.prg -C c64.cfg spikec64dislike.o

clean:
	-rm *.o
	-rm *.prg
