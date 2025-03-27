ASM = nasm
CC = g++

ASMFLAGS = -f elf64
CFLAGS = -c
SANITIZE = -fsanitize=address -g
PIE = -no-pie

TARGET = print
OBJ = myprintf.o test_myprintf.o

all: $(TARGET)
$(TARGET): $(OBJ)
	$(CC)  $(OBJ) -o $(TARGET) $(SANITIZE) $(PIE)

myprintf.o: myprintf.asm
	$(ASM) $(ASMFLAGS) -o myprintf.o myprintf.asm

test_myprintf.o: test_myprintf.cpp
	$(CC) $(CFLAGS) -o test_myprintf.o test_myprintf.cpp
