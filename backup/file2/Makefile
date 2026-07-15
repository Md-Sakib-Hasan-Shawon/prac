#################################################################
# Vivado Simulation Makefile - Practice Only
#################################################################

TOP := practice

BUILD_DIR := build
LOG_DIR := log

SV_FILE := practice.sv

# Create dirs
$(BUILD_DIR) $(LOG_DIR):
	@mkdir -p $@

.PHONY: clean all run

clean:
	@rm -rf $(BUILD_DIR) $(LOG_DIR) xsim.dir .Xil
	@echo "Clean done"

all: clean run

run: $(BUILD_DIR) $(LOG_DIR)
	@echo "Compiling SystemVerilog..."
	@cd $(BUILD_DIR) && xvlog -sv ../$(SV_FILE) \
		-log ../$(LOG_DIR)/xvlog.log

	@echo "Elaborating..."
	@cd $(BUILD_DIR) && xelab $(TOP) -s $(TOP)_sim \
		-log ../$(LOG_DIR)/xelab.log

	@echo "Running simulation..."
	@cd $(BUILD_DIR) && xsim $(TOP)_sim -runall \
		-log ../$(LOG_DIR)/xsim.log