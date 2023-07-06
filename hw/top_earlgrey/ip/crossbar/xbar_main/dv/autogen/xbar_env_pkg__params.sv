// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `tlgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"rv_dm__regs", '{
        '{32'hc1200000, 32'hc1200003}
    }},
    '{"rv_dm__mem", '{
        '{32'h00000000, 32'h00000fff}
    }},
    '{"peri", '{
        '{32'hc0000000, 32'hc01ffffe},
        '{32'hc0400000, 32'hc07ffffe}
    }},
    '{"tlul2axi", '{
        '{32'h00010000, 32'h9fffffff}
    }},
    '{"rom_ctrl__rom", '{
        '{32'hd0008000, 32'hd000ffff}
    }},
    '{"rom_ctrl__regs", '{
        '{32'hc11e0000, 32'hc11e007f}
    }},
    '{"dbg_mode", '{
        '{32'hff000000, 32'hff00003f}
    }},
    '{"spi_host0", '{
        '{32'hc0300000, 32'hc030003f}
    }},
    '{"spi_host1", '{
        '{32'hc0310000, 32'hc031003f}
    }},
    '{"flash_ctrl__core", '{
        '{32'hc1000000, 32'hc10001ff}
    }},
    '{"flash_ctrl__prim", '{
        '{32'hc1008000, 32'hc100807f}
    }},
    '{"flash_ctrl__mem", '{
        '{32'hf0000000, 32'hf00fffff}
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
    '{"usbdev", '{
        '{32'hc0320000, 32'hc0320fff}
    }},
    '{"sram_ctrl_main__ram", '{
        '{32'he0000000, 32'he001ffff}
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
        "tlul2axi",
        "rv_dm__regs",
        "sram_ctrl_main__ram",
        "peri",
        "spi_host0",
        "spi_host1",
        "flash_ctrl__core",
        "flash_ctrl__prim",
        "flash_ctrl__mem",
        "aes",
        "entropy_src",
        "csrng",
        "dbg_mode",
        "edn0",
        "edn1",
        "hmac",
        "rv_plic",
        "otbn",
        "keymgr",
        "usbdev",
        "kmac",
        "sram_ctrl_main__regs",
        "rv_core_ibex__cfg"}}
    ,
    '{"rv_dm__sba", 2, '{
        "rv_dm__regs",
        "rom_ctrl__rom",
        "rom_ctrl__regs",
        "peri",
        "tlul2axi",
        "spi_host0",
        "usbdev",
        "spi_host1",
        "flash_ctrl__core",
        "flash_ctrl__prim",
        "flash_ctrl__mem",
        "hmac",
        "kmac",
        "aes",
        "entropy_src",
        "csrng",
        "edn0",
        "edn1",
        "rv_plic",
        "otbn",
        "keymgr",
        "rv_core_ibex__cfg",
        "sram_ctrl_main__regs",
        "sram_ctrl_main__ram"}}
};