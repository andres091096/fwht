################################################################################
##
## Filename: Makefile
##
## Project: Veilog tutorial - fwht
##
## Creator: Andrés Manjarrés
################################################################################
VINC = /usr/share/verilator/include
RTL_DIR := ./rtl

VFLAGS  := -Wall --trace -y $(RTL_DIR) -GWIDTH=32 -GL_WIDTH=12 -cc

.PHONY: all
all: fwht
	./fwht
obj_dir/Vfwht.cpp: $(RTL_DIR)/fwht.v
	verilator $(VFLAGS) $^

obj_dir/Vfwht__ALL.a: obj_dir/Vfwht.cpp
	make -C obj_dir -f Vfwht.mk

# Build a simulation
fwht: bench/fwht_tb.cpp obj_dir/Vfwht__ALL.a
	@echo "Building a Verilator-based simulation of fwht"

	g++ -I$(VINC)  -I obj_dir     \
		$(VINC)/verilated.cpp \
		$(VINC)/verilated_vcd_c.cpp \
		bench/fwht_tb.cpp obj_dir/Vfwht__ALL.a      \
		-o fwht

.PHONY: clean

clean:
	rm -rf obj_dir/
