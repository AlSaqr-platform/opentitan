PULP_RUNTIME := ../../../pulp-runtime/
COMMON       := ../../common
PULP_NN      := ../../../pulp-nn-mixed
# PULP_SDK     := ../../../pulp-sdk

#PULP_EXT_LIBS += -I$(PULP_RUNTIME)/include
#-I$(PULP_RUNTIME)/include/chips/pulp -I$(PULP_RUNTIME)/include/archi
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp_hal/include/hal
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp_archi/include/archi
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp_archi/include/archi/chips/pulp
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include/pos/data
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include/pos/implem
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/kernel
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp/include/pos/chips/pulp
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp/drivers/cluster
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/cluster
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/cluster/cluster_sync
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/cluster/cluster_team
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/cluster/dma
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/drivers
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/rtos
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/rtos/event_kernel
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/rtos/malloc
#PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include/pmsis/rtos/os_fronted_api
# PULP_APP_CFLAGS += -I$(PULP_SDK)/../cluster/common/
# PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/pulp/include
# PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include/pos/data/
# PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include/pos/implem/
# PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pmsis/pmsis_api/include
PULP_APP_CFLAGS += -I$(PULP_SDK)/rtos/pulpos/common/include/
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/include

PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/Add
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/Convolution
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/Depthwise
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/LinearQuant
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/LinearNoQuant
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/MatrixMultiplication
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/Pointwise
PULP_APP_CFLAGS += -I$(PULP_NN)/XpulpV2/32bit/src/Pooling

#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Add/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Convolution/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Depthwise/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/LinearQuant/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/LinearNoQuant/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/MatrixMultiplication/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Pointwise/*.c
#PULP_SRCS += $(PULP_NN)/XpulpV2/32bit/src/Pooling/*/*.c

#include $(PULP_SDK_HOME)/rtos/pulpos/pulp/rules/pulpos/targets/pulp.mk

include $(PULP_SDK_HOME)/install/rules/pulp.mk

dump_header:
	riscv32-unknown-elf-objcopy -R .l1cluster_g -R .bss_l1 --pad-to 0x0 -O binary $(TARGET_BUILD_DIR)/$(PULP_APP)/$(PULP_APP) cluster.bin
	../../common_pulp/elf_to_header.py --binary=$(TARGET_BUILD_DIR)/$(PULP_APP)/$(PULP_APP) --vectors=../cluster_code.h

override disopt += -hDzts

