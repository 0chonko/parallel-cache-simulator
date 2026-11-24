# Makefile for the PSA course
#              
# Author(s): Michiel W. van Tol, Simon Polstra
# Note: This Makefile requires GNU Make 3.81 or newer

# Override these settings for your SystemC installation.
SYSTEMC_PATH ?= /usr/local
SYSTEMC_LIBDIR ?= $(firstword $(wildcard $(SYSTEMC_PATH)/lib-$(if $(filter x86_64,$(shell uname -m)),linux64,linux) $(SYSTEMC_PATH)/lib64 $(SYSTEMC_PATH)/lib) $(SYSTEMC_PATH)/lib)


SYSTEMC_INCLUDE = $(SYSTEMC_PATH)/include

# Path settings
SOURCE_PATH     = src

# lib
FRAMEWORK_LIB_DIR    = lib/
FRAMEWORK_LIB        = $(FRAMEWORK_LIB_DIR)psa.cpp


# Compiler settings
CC              = g++
CFLAGS          = -Wall -O2 -std=c++14
INCLUDES        = -I $(SYSTEMC_INCLUDE) -I $(FRAMEWORK_LIB_DIR)
LIBS            = -lsystemc -pthread
LIBDIR          = -L$(SYSTEMC_LIBDIR) -Wl,-rpath,$(SYSTEMC_LIBDIR)

# debug configuration
#CFLAGS          = -Wall -g3 -O0 -std=c++14 -fsanitize=address
#LIBS            = -lsystemc -pthread -fsanitize=address

# Find all targets
TARGETS         := $(patsubst $(SOURCE_PATH)/%,%,$(shell find $(SOURCE_PATH)/* -type d))

# Find all .cpp and .h files in target, 
# using find so it throws a warning when no .cpp is found
CPP_FILES       = $(shell find $(SOURCE_PATH)/$*/*.cpp)

# Same as above, but for dependency rule for .cpp and .h files
D_CPP_FILES     = $$(wildcard $(SOURCE_PATH)/$$*/*.cpp)
D_H_FILES       = $$(wildcard $(SOURCE_PATH)/$$*/*.h)

.SECONDEXPANSION:
.PHONY: all targets clean $(TARGETS)

all: $(TARGETS)
	
$(TARGETS): $$@.bin

%.bin: $(D_CPP_FILES) $(D_H_FILES) $(FRAMEWORK_LIB) $(FRAMEWORK_LIB_DIR)psa.h Makefile
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $(CPP_FILES) $(FRAMEWORK_LIB) $(LIBDIR) $(LIBS)
	
targets:
	@echo List of found targets:
	@echo $(TARGETS)
	@echo
	@echo List of found cpp files:
	@echo $(foreach sourcedir,$(TARGETS),$(wildcard $(SOURCE_PATH)/$(sourcedir)/*.cpp))
	@echo
	@echo SystemC installation used in:
	@echo $(SYSTEMC_LIBDIR)        

clean:
	rm -f $(TARGETS:%=%.bin)

