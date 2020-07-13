// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_env_pkg__params generated by `tlgen.py` tool


// List of Xbar device memory map
tl_device_t xbar_devices[$] = '{
    '{"lifecycle", '{
        '{32'h40140000, 32'h40140fff}
    }},
    '{"uart", '{
        '{32'h40000000, 32'h40000fff}
    }},
    '{"uart1", '{
        '{32'h40010000, 32'h40010fff}
    }},
    '{"uart2", '{
        '{32'h40020000, 32'h40020fff}
    }},
    '{"uart3", '{
        '{32'h40030000, 32'h40030fff}
    }},
    '{"gpio", '{
        '{32'h40040000, 32'h40040fff}
    }},
    '{"spi_device", '{
        '{32'h40050000, 32'h40051fff}
    }},
    '{"rv_timer", '{
        '{32'h40100000, 32'h40100fff}
    }},
    '{"i2c0", '{
        '{32'h40080000, 32'h40080fff}
    }},
    '{"i2c1", '{
        '{32'h40090000, 32'h40090fff}
    }},
    '{"i2c2", '{
        '{32'h400a0000, 32'h400a0fff}
    }},
    '{"pattgen", '{
        '{32'h400e0000, 32'h400e0fff}
    }},
    '{"sensor_ctrl", '{
        '{32'h40110000, 32'h4012ffff}
    }},
    '{"otp_ctrl", '{
        '{32'h40130000, 32'h40130fff}
}}};

  // List of Xbar hosts
tl_host_t xbar_hosts[$] = '{
    '{"main", 0, '{
        "uart",
        "uart1",
        "uart2",
        "uart3",
        "gpio",
        "spi_device",
        "rv_timer",
        "i2c0",
        "i2c1",
        "i2c2",
        "pattgen",
        "sensor_ctrl",
        "otp_ctrl",
        "lifecycle"}}
};
