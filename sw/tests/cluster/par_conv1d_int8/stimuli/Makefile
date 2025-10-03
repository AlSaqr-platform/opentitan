PULP_APP = stimuli

PULP_APP_FC_SRCS = stimuli.c typedefs.h
PULP_APP_SRCS =  conv.c support_func.c

PULP_APP_SRCS +=  $(PULP_NN)/XpulpV2/32bit/src/Add/*.c
PULP_APP_SRCS +=  $(PULP_NN)/XpulpNN/32bit/src/Convolution/xpulp_nn_conv1d_i8_i8_i8.c
PULP_APP_SRCS +=  $(PULP_NN)/XpulpNN/32bit/src/MatrixMultiplication/xpulp_nn_matmul_i8_i8_i8.c
PULP_APP_SRCS +=  $(PULP_NN)/XpulpNN/32bit/src/MatrixMultiplication/xpulp_nn_matmul_i4_i4_i4_4x4.c
PULP_APP_SRCS +=  $(PULP_NN)/../cluster/common/utils.c

PULP_CFLAGS += -O3 -g3
PULP_CFLAGS += -mno-memcpy

XLEN:=32

PULP_CFLAGS += -DNUM_CORES=8 -DUSE_INTRINSICS  -DINT8 -DCHECKu

PULP_CFLAGS += -fno-tree-vectorize

ifdef print_results
PULP_CFLAGS += -DPRINT_RESULTS
endif

ifdef verbose2
PULP_CFLAGS += -DVERBOSE
endif

ifdef stats
PULP_CFLAGS += -DSTATS
endif


gen_args:
	python3 gen_data.py  --dim_in_x 128  --ch_in 1 --ch_out 64 --kern_x 3 --stride 1 --pad_left 1 --pad_right 1 --out_mult 1 --out_shift 0 -o data.h

include ../../common_pulp/common_pulp.mk



