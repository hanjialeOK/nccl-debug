#
# Copyright (c) 2015-2019, NVIDIA CORPORATION. All rights reserved.
#
# See LICENSE.txt for license information
#

# https://github.com/NVIDIA/nccl-tests/blob/7ccda3c97baf6924ff38411e364c0442096fc4be/src/Makefile
# https://makefiletutorial.com/

CUDA_HOME ?= /usr/local/cuda
DEBUG ?= 0

CUDA_LIB ?= $(CUDA_HOME)/lib64
CUDA_INC ?= $(CUDA_HOME)/include
NVCC ?= $(CUDA_HOME)/bin/nvcc
CUDARTLIB ?= cudart

CUDA_VERSION = $(strip $(shell which $(NVCC) >/dev/null && $(NVCC) --version | grep release | sed 's/.*release //' | sed 's/\,.*//'))
CUDA_MAJOR = $(shell echo $(CUDA_VERSION) | cut -d "." -f 1)

# Better define NVCC_GENCODE in your environment to the minimal set
# of archs to reduce compile time.
ifeq ($(shell test "0$(CUDA_MAJOR)" -ge 11; echo $$?),0)
NVCC_GENCODE ?= -gencode=arch=compute_60,code=sm_60 \
                -gencode=arch=compute_61,code=sm_61 \
                -gencode=arch=compute_70,code=sm_70 \
                -gencode=arch=compute_80,code=sm_80 \
                -gencode=arch=compute_80,code=compute_80
else
NVCC_GENCODE ?= -gencode=arch=compute_35,code=sm_35 \
                -gencode=arch=compute_50,code=sm_50 \
                -gencode=arch=compute_60,code=sm_60 \
                -gencode=arch=compute_61,code=sm_61 \
                -gencode=arch=compute_70,code=sm_70 \
                -gencode=arch=compute_70,code=compute_70
endif

NVCUFLAGS  := -ccbin $(CXX) $(NVCC_GENCODE) -std=c++11
NVLDFLAGS  := -L${CUDA_LIB} -l${CUDARTLIB} -lrt

ifeq ($(DEBUG), 0)
NVCUFLAGS += -O3 -g
else
NVCUFLAGS += -O0 -G -g
endif

ifneq ($(NCCL_HOME), "")
NVCUFLAGS += -I$(NCCL_HOME)/include/
NVLDFLAGS += -L$(NCCL_HOME)/lib
endif

MPI_HOME ?= /usr/lib/x86_64-linux-gnu/openmpi
NVCUFLAGS += -DMPI_SUPPORT -I$(MPI_HOME)/include
NVLDFLAGS += -L$(MPI_HOME)/lib -L$(MPI_HOME)/lib64 -lmpi -lmpi_cxx

LIBRARIES += nccl
NVLDFLAGS += $(LIBRARIES:%=-l%)

demo.o: demo.cu
	$(NVCC) -o $@ $(NVCUFLAGS) -c $^

demo: demo.o
	$(NVCC) -o $@ $(NVCUFLAGS) $(NVLDFLAGS) $^

clean:
	rm -f demo demo.o