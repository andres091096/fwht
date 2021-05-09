###################################################
# Makefile
# by Andrés Mauricio Manjarrés
# 2020/12/27
###################################################

# Compilers constants
GCC=g++
CP = cp -rf

CFLAGS = -g -c -Wall -O0
LDFLAGS  += -lpthread -lrt -lstdc++

SRC_C = test_fwht.c fwht.c

OBJECTS_PROG =  test_fwht.o fwht.o

EXECUTABLE = fwht

.PHONY: all clean

all: $(EXECUTABLE)
	./$(EXECUTABLE)
	
$(EXECUTABLE): $(OBJECTS_PROG)
	@echo "============================"
	@echo "Compiling the program ..."
	@echo "============================"
	$(GCC) -g -lm $^ -o $@

./%.o: ./%.c
	@echo "============================"
	@echo "Creating  the C  objects..."
	@echo "============================"
	$(GCC) $(CFLAGS) -o $@ $<


RMDIR = rm -rf

clean:
	-$(RMDIR) $(EXECUTABLE)
	-$(RMDIR) $(OBJECTS_PROG)
