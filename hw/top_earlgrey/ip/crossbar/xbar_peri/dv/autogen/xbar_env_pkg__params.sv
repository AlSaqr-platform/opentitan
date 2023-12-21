// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `tlgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"uart0", '{
        '{32'hc0000000, 32'hc0000fff}
    }},
    '{"uart1", '{
        '{32'hc0010000, 32'hc0010fff}
    }},
    '{"uart2", '{
        '{32'hc0020000, 32'hc0020fff}
    }},
    '{"uart3", '{
        '{32'hc0030000, 32'hc0030fff}
    }},
    '{"i2c0", '{
        '{32'hc0080000, 32'hc0080fff}
    }},
    '{"i2c1", '{
        '{32'hc0090000, 32'hc0090fff}
    }},
    '{"i2c2", '{
        '{32'hc00a0000, 32'hc00a0fff}
    }},
    '{"pattgen", '{
        '{32'hc00e0000, 32'hc00e0fff}
    }},
    '{"pwm_aon", '{
        '{32'hc0450000, 32'hc0450fff}
    }},
    '{"gpio", '{
        '{32'hc0040000, 32'hc0040fff}
    }},
    '{"spi_device", '{
        '{32'hc0050000, 32'hc0051fff}
    }},
    '{"rv_timer", '{
        '{32'hc0100000, 32'hc0100fff}
    }},
    '{"sensor_ctrl", '{
        '{32'hc0490000, 32'hc049003f}
    }},
    '{"pwrmgr_aon", '{
        '{32'hc0400000, 32'hc0400fff}
    }},
    '{"rstmgr_aon", '{
        '{32'hc0410000, 32'hc0410fff}
    }},
    '{"clkmgr_aon", '{
        '{32'hc0420000, 32'hc0420fff}
    }},
    '{"pinmux_aon", '{
        '{32'hc0460000, 32'hc0460fff}
    }},
    '{"otp_ctrl__core", '{
        '{32'hc0130000, 32'hc0131fff}
    }},
    '{"otp_ctrl__prim", '{
        '{32'hc0132000, 32'hc0132fff}
    }},
    '{"lc_ctrl", '{
        '{32'hc0140000, 32'hc0140fff}
    }},
    '{"alert_handler", '{
        '{32'hc0150000, 32'hc0150fff}
    }},
    '{"sram_ctrl_ret_aon__regs", '{
        '{32'hc0500000, 32'hc0500fff}
    }},
    '{"sram_ctrl_ret_aon__ram", '{
        '{32'hc0600000, 32'hc0600fff}
    }},
    '{"aon_timer_aon", '{
        '{32'hc0470000, 32'hc0470fff}
    }},
    '{"sysrst_ctrl_aon", '{
        '{32'hc0430000, 32'hc0430fff}
    }},
    '{"adc_ctrl_aon", '{
        '{32'hc0440000, 32'hc0440fff}
    }},
    '{"ast", '{
        '{32'hc0480000, 32'hc0480fff}
}}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"main", 0, '{
        "uart0",
        "uart1",
        "uart2",
        "sensor_ctrl",
        "uart3",
        "i2c0",
        "i2c1",
        "i2c2",
        "pattgen",
        "gpio",
        "spi_device",
        "rv_timer",
        "pwrmgr_aon",
        "rstmgr_aon",
        "clkmgr_aon",
        "pinmux_aon",
        "otp_ctrl__core",
        "otp_ctrl__prim",
        "lc_ctrl",
        "alert_handler",
        "ast",
        "sram_ctrl_ret_aon__ram",
        "sram_ctrl_ret_aon__regs",
        "aon_timer_aon",
        "adc_ctrl_aon",
        "sysrst_ctrl_aon",
        "pwm_aon"}}
};
