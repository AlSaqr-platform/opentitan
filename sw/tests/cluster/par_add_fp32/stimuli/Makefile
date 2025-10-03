PULP_APP = stimuli

PULP_APP_FC_SRCS = stimuli.c typedefs.h
PULP_APP_SRCS =  $(PULP_NN)/XpulpV2/32bit/src/Add/pulp_nn_add_i8_i8_i8.c add.c support_func.c

#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Add/pulp_nn_add_i8_i8_i8.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Convolution/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Depthwise/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/LinearQuant/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/LinearNoQuant/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/MatrixMultiplication/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Pointwise/*.c
#PULP_APP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Pooling/*/*.c


PULP_CFLAGS += -O3 -g3
PULP_CFLAGS += -mno-memcpy

XLEN:=32

PULP_CFLAGS += -DNUM_CORES=8 -DUSE_INTRINSICS -DTHR=0.004f -DFIXED -DFP32 -DCHECK

PULP_CFLAGS += -fno-tree-vectorize

ifdef print_results
PULP_CFLAGS += -DPRINT_RESULTS
endif

ifdef verbose
PULP_CFLAGS += -DVERBOSE
endif

ifdef stats
PULP_CFLAGS += -DSTATS
endif

include ../../common_pulp/common_pulp.mk



