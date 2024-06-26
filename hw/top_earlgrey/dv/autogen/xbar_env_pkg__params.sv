// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `topgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"rv_dm__regs", '{
        '{32'hc1200000, 32'hc1200003}
    }},
    '{"rv_dm__mem", '{
        '{32'h00000000, 32'h00000fff}
    }},
    '{"rom_ctrl__rom", '{
        '{32'hd0008000, 32'hd000ffff}
    }},
    '{"rom_ctrl__regs", '{
        '{32'hc11e0000, 32'hc11e007f}
    }},
    '{"spi_host0", '{
        '{32'hc0300000, 32'hc030003f}
    }},
    '{"spi_host1", '{
        '{32'hc0310000, 32'hc031003f}
    }},
    '{"usbdev", '{
        '{32'hc0320000, 32'hc0320fff}
    }},
    '{"flash_ctrl__core", '{
        '{32'hc1000000, 32'hc10001ff}
    }},
    '{"flash_ctrl__prim", '{
        '{32'hc1008000, 32'hc100807f}
    }},
    '{"flash_ctrl__mem", '{
        '{32'hf0000000, 32'hf000ffff}
    }},
    '{"hmac", '{
        '{32'hc1110000, 32'hc1110fff}
    }},
    '{"kmac", '{
        '{32'hc1120000, 32'hc1120fff}
    }},
    '{"aes", '{
        '{32'hc1100000, 32'hc11000ff}
    }},
    '{"entropy_src", '{
        '{32'hc1160000, 32'hc11600ff}
    }},
    '{"csrng", '{
        '{32'hc1150000, 32'hc115007f}
    }},
    '{"edn0", '{
        '{32'hc1170000, 32'hc117007f}
    }},
    '{"edn1", '{
        '{32'hc1180000, 32'hc118007f}
    }},
    '{"rv_plic", '{
        '{32'hc8000000, 32'hcfffffff}
    }},
    '{"otbn", '{
        '{32'hc1130000, 32'hc113ffff}
    }},
    '{"keymgr", '{
        '{32'hc1140000, 32'hc11400ff}
    }},
    '{"rv_core_ibex__cfg", '{
        '{32'hc11f0000, 32'hc11f00ff}
    }},
    '{"sram_ctrl_main__regs", '{
        '{32'hc11c0000, 32'hc11c001f}
    }},
    '{"sram_ctrl_main__ram", '{
        '{32'he0000000, 32'he001ffff}
    }},
    '{"tlul2axi", '{
        '{32'h00010000, 32'h0001000f}
    }},
    '{"uart0", '{
        '{32'hc0000000, 32'hc000003f}
    }},
    '{"uart1", '{
        '{32'hc0010000, 32'hc001003f}
    }},
    '{"uart2", '{
        '{32'hc0020000, 32'hc002003f}
    }},
    '{"uart3", '{
        '{32'hc0030000, 32'hc003003f}
    }},
    '{"i2c0", '{
        '{32'hc0080000, 32'hc008007f}
    }},
    '{"i2c1", '{
        '{32'hc0090000, 32'hc009007f}
    }},
    '{"i2c2", '{
        '{32'hc00a0000, 32'hc00a007f}
    }},
    '{"pattgen", '{
        '{32'hc00e0000, 32'hc00e003f}
    }},
    '{"pwm_aon", '{
        '{32'hc0450000, 32'hc045007f}
    }},
    '{"gpio", '{
        '{32'hc0040000, 32'hc004003f}
    }},
    '{"spi_device", '{
        '{32'hc0050000, 32'hc0051fff}
    }},
    '{"rv_timer", '{
        '{32'hc0100000, 32'hc01001ff}
    }},
    '{"pwrmgr_aon", '{
        '{32'hc0400000, 32'hc040007f}
    }},
    '{"rstmgr_aon", '{
        '{32'hc0410000, 32'hc041007f}
    }},
    '{"clkmgr_aon", '{
        '{32'hc0420000, 32'hc042007f}
    }},
    '{"pinmux_aon", '{
        '{32'hc0460000, 32'hc0460fff}
    }},
    '{"otp_ctrl__core", '{
        '{32'hc0130000, 32'hc0131fff}
    }},
    '{"otp_ctrl__prim", '{
        '{32'hc0132000, 32'hc013201f}
    }},
    '{"lc_ctrl", '{
        '{32'hc0140000, 32'hc01400ff}
    }},
    '{"sensor_ctrl", '{
        '{32'hc0490000, 32'hc049003f}
    }},
    '{"alert_handler", '{
        '{32'hc0150000, 32'hc01507ff}
    }},
    '{"sram_ctrl_ret_aon__regs", '{
        '{32'hc0500000, 32'hc050001f}
    }},
    '{"sram_ctrl_ret_aon__ram", '{
        '{32'hc0600000, 32'hc0600fff}
    }},
    '{"aon_timer_aon", '{
        '{32'hc0470000, 32'hc047003f}
    }},
    '{"sysrst_ctrl_aon", '{
        '{32'hc0430000, 32'hc04300ff}
    }},
    '{"adc_ctrl_aon", '{
        '{32'hc0440000, 32'hc044007f}
    }},
    '{"ast", '{
        '{32'hc0480000, 32'hc04803ff}
    }}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"rv_core_ibex__corei", 0, '{
        "rom_ctrl__rom",
        "rv_dm__mem",
        "sram_ctrl_main__ram",
        "flash_ctrl__mem"}}
    ,
    '{"rv_core_ibex__cored", 1, '{
        "rom_ctrl__rom",
        "rom_ctrl__regs",
        "rv_dm__mem",
        "rv_dm__regs",
        "sram_ctrl_main__ram",
        "uart0",
        "uart1",
        "uart2",
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
        "sensor_ctrl",
        "alert_handler",
        "ast",
        "sram_ctrl_ret_aon__ram",
        "sram_ctrl_ret_aon__regs",
        "aon_timer_aon",
        "adc_ctrl_aon",
        "sysrst_ctrl_aon",
        "pwm_aon",
        "spi_host0",
        "spi_host1",
        "usbdev",
        "tlul2axi",
        "flash_ctrl__core",
        "flash_ctrl__prim",
        "flash_ctrl__mem",
        "aes",
        "entropy_src",
        "csrng",
        "edn0",
        "edn1",
        "hmac",
        "rv_plic",
        "otbn",
        "keymgr",
        "kmac",
        "sram_ctrl_main__regs",
        "rv_core_ibex__cfg"}}
    ,
    '{"rv_dm__sba", 2, '{
        "rom_ctrl__rom",
        "rom_ctrl__regs",
        "rv_dm__mem",
        "rv_dm__regs",
        "sram_ctrl_main__ram",
        "uart0",
        "uart1",
        "uart2",
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
        "sensor_ctrl",
        "alert_handler",
        "ast",
        "sram_ctrl_ret_aon__ram",
        "sram_ctrl_ret_aon__regs",
        "aon_timer_aon",
        "adc_ctrl_aon",
        "sysrst_ctrl_aon",
        "pwm_aon",
        "spi_host0",
        "spi_host1",
        "usbdev",
        "tlul2axi",
        "flash_ctrl__core",
        "flash_ctrl__prim",
        "flash_ctrl__mem",
        "aes",
        "entropy_src",
        "csrng",
        "edn0",
        "edn1",
        "hmac",
        "rv_plic",
        "otbn",
        "keymgr",
        "kmac",
        "sram_ctrl_main__regs",
        "rv_core_ibex__cfg"}}
};
