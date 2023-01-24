// Generated register defines for SENSOR_CTRL

// Copyright information found in source file:
// Copyright lowRISC contributors.

// Licensing information found in source file:
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _SENSOR_CTRL_REG_DEFS_
#define _SENSOR_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Number of alert events from ast
#define SENSOR_CTRL_PARAM_NUM_ALERT_EVENTS 11

// Number of local events
#define SENSOR_CTRL_PARAM_NUM_LOCAL_EVENTS 1

// Number of alerts sent from sensor control
#define SENSOR_CTRL_PARAM_NUM_ALERTS 2

// Number of IO rails
#define SENSOR_CTRL_PARAM_NUM_IO_RAILS 2

// Register width
#define SENSOR_CTRL_PARAM_REG_WIDTH 32

// Common Interrupt Offsets
#define SENSOR_CTRL_INTR_COMMON_IO_STATUS_CHANGE_BIT 0
#define SENSOR_CTRL_INTR_COMMON_INIT_STATUS_CHANGE_BIT 1

// Interrupt State Register
#define SENSOR_CTRL_INTR_STATE_REG_OFFSET 0x0
#define SENSOR_CTRL_INTR_STATE_REG_RESVAL 0x0
#define SENSOR_CTRL_INTR_STATE_IO_STATUS_CHANGE_BIT 0
#define SENSOR_CTRL_INTR_STATE_INIT_STATUS_CHANGE_BIT 1

// Interrupt Enable Register
#define SENSOR_CTRL_INTR_ENABLE_REG_OFFSET 0x4
#define SENSOR_CTRL_INTR_ENABLE_REG_RESVAL 0x0
#define SENSOR_CTRL_INTR_ENABLE_IO_STATUS_CHANGE_BIT 0
#define SENSOR_CTRL_INTR_ENABLE_INIT_STATUS_CHANGE_BIT 1

// Interrupt Test Register
#define SENSOR_CTRL_INTR_TEST_REG_OFFSET 0x8
#define SENSOR_CTRL_INTR_TEST_REG_RESVAL 0x0
#define SENSOR_CTRL_INTR_TEST_IO_STATUS_CHANGE_BIT 0
#define SENSOR_CTRL_INTR_TEST_INIT_STATUS_CHANGE_BIT 1

// Alert Test Register
#define SENSOR_CTRL_ALERT_TEST_REG_OFFSET 0xc
#define SENSOR_CTRL_ALERT_TEST_REG_RESVAL 0x0
#define SENSOR_CTRL_ALERT_TEST_RECOV_ALERT_BIT 0
#define SENSOR_CTRL_ALERT_TEST_FATAL_ALERT_BIT 1

// Controls the configurability of !!FATAL_ALERT_EN register.
#define SENSOR_CTRL_CFG_REGWEN_REG_OFFSET 0x10
#define SENSOR_CTRL_CFG_REGWEN_REG_RESVAL 0x1
#define SENSOR_CTRL_CFG_REGWEN_EN_BIT 0

// Alert trigger test (common parameters)
#define SENSOR_CTRL_ALERT_TRIG_VAL_FIELD_WIDTH 1
#define SENSOR_CTRL_ALERT_TRIG_MULTIREG_COUNT 1

// Alert trigger test
#define SENSOR_CTRL_ALERT_TRIG_REG_OFFSET 0x14
#define SENSOR_CTRL_ALERT_TRIG_REG_RESVAL 0x0
#define SENSOR_CTRL_ALERT_TRIG_VAL_0_BIT 0
#define SENSOR_CTRL_ALERT_TRIG_VAL_1_BIT 1
#define SENSOR_CTRL_ALERT_TRIG_VAL_2_BIT 2
#define SENSOR_CTRL_ALERT_TRIG_VAL_3_BIT 3
#define SENSOR_CTRL_ALERT_TRIG_VAL_4_BIT 4
#define SENSOR_CTRL_ALERT_TRIG_VAL_5_BIT 5
#define SENSOR_CTRL_ALERT_TRIG_VAL_6_BIT 6
#define SENSOR_CTRL_ALERT_TRIG_VAL_7_BIT 7
#define SENSOR_CTRL_ALERT_TRIG_VAL_8_BIT 8
#define SENSOR_CTRL_ALERT_TRIG_VAL_9_BIT 9
#define SENSOR_CTRL_ALERT_TRIG_VAL_10_BIT 10

// Each bit marks a corresponding alert as fatal or recoverable. (common
// parameters)
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_FIELD_WIDTH 1
#define SENSOR_CTRL_FATAL_ALERT_EN_MULTIREG_COUNT 1

// Each bit marks a corresponding alert as fatal or recoverable.
#define SENSOR_CTRL_FATAL_ALERT_EN_REG_OFFSET 0x18
#define SENSOR_CTRL_FATAL_ALERT_EN_REG_RESVAL 0x0
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_0_BIT 0
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_1_BIT 1
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_2_BIT 2
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_3_BIT 3
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_4_BIT 4
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_5_BIT 5
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_6_BIT 6
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_7_BIT 7
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_8_BIT 8
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_9_BIT 9
#define SENSOR_CTRL_FATAL_ALERT_EN_VAL_10_BIT 10

// Each bit represents a recoverable alert that has been triggered by AST.
#define SENSOR_CTRL_RECOV_ALERT_VAL_FIELD_WIDTH 1
#define SENSOR_CTRL_RECOV_ALERT_MULTIREG_COUNT 1

// Each bit represents a recoverable alert that has been triggered by AST.
#define SENSOR_CTRL_RECOV_ALERT_REG_OFFSET 0x1c
#define SENSOR_CTRL_RECOV_ALERT_REG_RESVAL 0x0
#define SENSOR_CTRL_RECOV_ALERT_VAL_0_BIT 0
#define SENSOR_CTRL_RECOV_ALERT_VAL_1_BIT 1
#define SENSOR_CTRL_RECOV_ALERT_VAL_2_BIT 2
#define SENSOR_CTRL_RECOV_ALERT_VAL_3_BIT 3
#define SENSOR_CTRL_RECOV_ALERT_VAL_4_BIT 4
#define SENSOR_CTRL_RECOV_ALERT_VAL_5_BIT 5
#define SENSOR_CTRL_RECOV_ALERT_VAL_6_BIT 6
#define SENSOR_CTRL_RECOV_ALERT_VAL_7_BIT 7
#define SENSOR_CTRL_RECOV_ALERT_VAL_8_BIT 8
#define SENSOR_CTRL_RECOV_ALERT_VAL_9_BIT 9
#define SENSOR_CTRL_RECOV_ALERT_VAL_10_BIT 10

// Each bit represents a fatal alert that has been triggered by AST.
#define SENSOR_CTRL_FATAL_ALERT_VAL_FIELD_WIDTH 1
#define SENSOR_CTRL_FATAL_ALERT_MULTIREG_COUNT 1

// Each bit represents a fatal alert that has been triggered by AST.
#define SENSOR_CTRL_FATAL_ALERT_REG_OFFSET 0x20
#define SENSOR_CTRL_FATAL_ALERT_REG_RESVAL 0x0
#define SENSOR_CTRL_FATAL_ALERT_VAL_0_BIT 0
#define SENSOR_CTRL_FATAL_ALERT_VAL_1_BIT 1
#define SENSOR_CTRL_FATAL_ALERT_VAL_2_BIT 2
#define SENSOR_CTRL_FATAL_ALERT_VAL_3_BIT 3
#define SENSOR_CTRL_FATAL_ALERT_VAL_4_BIT 4
#define SENSOR_CTRL_FATAL_ALERT_VAL_5_BIT 5
#define SENSOR_CTRL_FATAL_ALERT_VAL_6_BIT 6
#define SENSOR_CTRL_FATAL_ALERT_VAL_7_BIT 7
#define SENSOR_CTRL_FATAL_ALERT_VAL_8_BIT 8
#define SENSOR_CTRL_FATAL_ALERT_VAL_9_BIT 9
#define SENSOR_CTRL_FATAL_ALERT_VAL_10_BIT 10
#define SENSOR_CTRL_FATAL_ALERT_VAL_11_BIT 11

// Status readback for ast
#define SENSOR_CTRL_STATUS_REG_OFFSET 0x24
#define SENSOR_CTRL_STATUS_REG_RESVAL 0x0
#define SENSOR_CTRL_STATUS_AST_INIT_DONE_BIT 0
#define SENSOR_CTRL_STATUS_IO_POK_MASK 0x3
#define SENSOR_CTRL_STATUS_IO_POK_OFFSET 1
#define SENSOR_CTRL_STATUS_IO_POK_FIELD \
  ((bitfield_field32_t) { .mask = SENSOR_CTRL_STATUS_IO_POK_MASK, .index = SENSOR_CTRL_STATUS_IO_POK_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _SENSOR_CTRL_REG_DEFS_
// End generated register defines for SENSOR_CTRL