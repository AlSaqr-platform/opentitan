# OpenTitan

![OpenTitan logo](https://docs.opentitan.org/doc/opentitan-logo.png)

## About the project

[OpenTitan](https://opentitan.org) is an open source silicon Root of Trust
(RoT) project.  OpenTitan will make the silicon RoT design and implementation
more transparent, trustworthy, and secure for enterprises, platform providers,
and chip manufacturers.  OpenTitan is administered by [lowRISC
CIC](https://www.lowrisc.org) as a collaborative project to produce high
quality, open IP for instantiation as a full-featured product. See the
[OpenTitan site](https://opentitan.org/) and [OpenTitan
docs](https://docs.opentitan.org) for more information about the project.

## About this repository

This repository contains hardware, software and utilities written as part of the
OpenTitan project. It is structured as monolithic repository, or "monorepo",
where all components live in one repository. It exists to enable collaboration
across partners participating in the OpenTitan project.

## Documentation

The project contains comprehensive documentation of all IPs and tools. You can
access it [online at docs.opentitan.org](https://docs.opentitan.org/).

## How to contribute

Have a look at [CONTRIBUTING](https://github.com/lowRISC/opentitan/blob/master/CONTRIBUTING.md) and our [documentation on
project organization and processes](https://docs.opentitan.org/doc/project/)
for guidelines on how to contribute code to this repository.

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see [LICENSE](https://github.com/lowRISC/opentitan/blob/master/LICENSE) for full text).

## Repository how-to

The repository contains a systemverilog top module which wraps the top_earlgrey architecture (revisioned with out extensions). They are found under [hw/top_earlgrey/top](https://github.com/AlSaqr-platform/opentitan/tree/alsaqr-2/hw/top_earlgrey/top).
The top module is [secure_subsystem_asynch_synth_wrap_astral.sv](https://github.com/AlSaqr-platform/opentitan/blob/alsaqr-2/hw/top_earlgrey/top/secure_subsystem_asynch_synth_wrap_astral.sv), while under [hw/tb/](https://github.com/AlSaqr-platform/opentitan/tree/alsaqr-2/hw/tb/testbench_asynch_astral.sv) a testbench can be found for stand-alone simulations.

The architecture we modified differs with respect to the original one in terms of:
* The OTP memory have been replaced with a ROM, which implements this [OTP](https://github.com/AlSaqr-platform/opentitan/blob/alsaqr-2/hw/ip/otp_ctrl/data/otp_ctrl_img_test_unlocked0.hjson) image, in TEST_UNLOCKED0 lifecycle state.
* The embedded Flash memory have been replaced with a SRAM which must be preloaded before the secure boot (or during the secure boot if via JTAG).
* The analog sensor top have been forfeited: no tampering detection (but simplier architecture).
* Introduced two bootmodes, affecting ROM code execution: 1)Debug: core waits for debug requests 2)Secure: ROM start executing secure boot and preloading the emulated flash).
* Top module includes a PULP cluster for security policies based on ML algorithms.
* Defined scripts and Makefiles to allow for stand alone simulation.
* Defined scripts to manipulate the output VMEMs from bazel (for flash VIP, bootrom generation, otp generation).

### Repo Init
Run the following command to inizialize the repo:
```
make init
```
### Software requirements
To be able to run bazel, you must install the python requirements under python_requirements.txt and apt requirements as well.
To compile with makefile, you just need the RISV toolchain.

### Software build
Two different methods are supported, depending on whether APIs from OpenTitan are needed:
* 1) Makefile (no APIs)
* 2) Bazel

All the tests used in this repo are found under sw/tests/<target>. The targets are different SoC architectures. Under each target, the following nomenclature is used:
* sram_ or flash_ are generated with bazel: they use a BUILD file to import the various deps and unses the main Makefile of the root dir.
* titanssl_ tests are related to crypto accelrators and must be compiled with bazel framework (only SRAM version is available).
* flash_preload_ are tests which are compiled with Makefile, but imports bazel-generated (after pre-processing) images as C headers (they include crypto signature for being secure booted).
* the others can be compiled with Makefile under each test dir (are compiled for SRAM).

The tests which are supposed to be run in FLASH, must be generated with bazel and must be converted in C header to be preloaded, in case we run the secure boot via JTAG, by the Ibex core using the alternative datapath for preload (which is driven via SW).
For each test generated for flash, it is needed a flash_prelaod_ binary which essentialy moves the C header into the emulated flash exploiting the alternative datapath. In case the secure boot is emulated with an external flash VIP, pythons scripts convert the VMEM from bazel
into a suitable format for the specific VIP we use.

To compile with bazel, run:

```
make compile-bazel-sram test_name=<dir-name-under-target-dir> target=<target-arch>

```
Example:
```
make compile-bazel-sram test_name=sram_hello_world target=opentitan

```
By default it will compile for "opentitan" target.


To compile for flash instead run:
```
make flash-all test_name=<dir-name-under-target-dir target=<target-arch>

```
Example:
```
make flash-all test_name=flash_alsaqr_boot target=alsaqr

```

To recompile the bootrom, run:

```
make compile-bazel-rom

```

To compile the tests which do not need bazel, move under the test directory and run:
```
make clean all

```

### Cluster
It is possible to offload to cluster the execution of some task. OpenTitan can set/unset the fetch enable of the cluster, and is capable of polling a EOC register connected to the corresponding signal of the cluster. The testbench is configured to automatially preload via JTAG the cluster binary (including eventual sections within the L1 as OpenTitan has access to the L1 and cluster control unit) when specified by "cl-bin" argument. The fetch enable and EOC registers are mapped as follows:
|   | Address  | ResVal  |
|---|---|---|
| Fetch enable  | 0xff000020  |  0x0 |
| EOC  |  0xff000024 |  0x0 |

Cluster binary, through the pulp-runtime, automatically returns 0x1 to the EOC after main() execution.
An example is provided with the Addressability Test, where the cluster writes some data into the tb sram, and while Ibex polls the EOC register waiting the cluster to complete the execution.

The tests which uses the cluster are found under "OpenTitan/sw/tests/cluster". Undear each test-name dir, a test-name.c (Ibex binary) and a stimuli/ directory (for cluster binary) are found. The two binary are compiled separately. For Ibex binary, RISC-V Toolchain is required, while for cluster binary PULP RISC-V Toolchain is required.

As first, fetch the git modules (if not cloned via make init from ot repo or alsaqr repo):

```
git submodule update --init --recursive

```
Then, source the config file of the cluster under pulp-runtime:

```
cd sw/tests/pulp-runtime/configs
source pulp_cluster.sh

```

Under each test-name dir (for instance addressability test), to compile Ibex image run:
```
cd sw/tests/cluster/addressability
make clean all

```
And under test-name/stimuli compile cluster image:
```
cd sw/tests/cluster/addressability/stimuli
make clean all

```

The outputs are found under test-name/test-name.elf for Ibex and test-name/stimuli/build/stimuli/stimuli for cluster.

### Scripts
Under scripts/, there are scripts for:
* Generating the OTP ROM starting from an image.
* Generating the bootrom starting from bazel outputs (both .sv and .coe).
* Recasting the VMEMs for different formats/targets.

### Run simulations

To run simulation, you can run the following command providing the biniary to SRAM variable (use nogui=1 to run in batch mode):

```
make clean sim SRAM=path-to-binary

```
One can also use the flash images running the secure boot as follows:
```
make secure_boot_jtag SRAM=path-to-<flash_preload>-binary

or

make secure_boot_spi
```
The SPI secure boot will preload external flash with [this default test](https://github.com/AlSaqr-platform/opentitan/blob/alsaqr-2/hw/tb/testbench_asynch_astral.sv#L187).

Concerning simulations involving the cluster, its code must be preloaded at t=0 via JTAG together with Ibex image, providing the path to the binary with "cl-bin". To run a simulation preloading also the cluster code, for instance the Addressability Test:

```
make clean sim SRAM=sw/tests/cluster/addressability/addressability.elf cl-bin=sw/tests/cluster/addressability/stimuli/build/stimuli/stimuli

```

## Publications
If you use this version of OpenTitan in your work or research, you can cite us:

```
@article{10.1145/3690823,
author = {Ciani, Maicol and Parisi, Emanuele and Musa, Alberto and Barchi, Francesco and Bartolini, Andrea and Kulmala, Ari and Psiakis, Rafail and Garofalo, Angelo and Acquaviva, Andrea and Davide, Rossi},
title = {Unleashing OpenTitan's Potential: a Silicon-Ready Embedded Secure Element for Root of Trust and Cryptographic Offloading},
year = {2024},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
issn = {1539-9087},
url = {https://doi.org/10.1145/3690823},
doi = {10.1145/3690823},
abstract = {The rapid advancement and exploration of open-hardware RISC-V platforms are catalyzing substantial changes across critical sectors, including autonomous vehicles, smart-city infrastructure, and medical devices. Within this technological evolution, OpenTitan emerges as a groundbreaking open-source RISC-V design, renowned for its comprehensive security toolkit and role as a standalone system-on-chip (SoC). OpenTitan encompasses different SoC implementations such as Earl Grey, fully implemented and silicon proven, and Darjeeling, announced but not yet fully implemented. The former targets a stand-alone system-on-chip implementation, the latter oriented towards an integrable implementation. Therefore, the literature currently lacks of a silicon-ready embedded implementation of an open-source Root of Trust, despite the effort put by lowRISC on the Darjeeling implementation of OpenTitan. We address the limitations of existing implementations, focusing on optimizing data transfer latency between memory and cryptographic accelerators to prevent under-utilization and ensure efficient task acceleration. Our contributions include a comprehensive methodology for integrating custom extensions and IPs into the Earl Grey architecture, architectural enhancements for system-level integration, support for varied boot modes, and improved data movement across the platform. These advancements facilitate the deployment of OpenTitan in broader SoCs, even in scenarios lacking specific technology-dependent IPs, providing a deployment-ready research vehicle for the community. We integrated the extended Earl Grey architecture into a reference architecture in 22nm FDX technology node, and then we benchmarked the enhanced architecture’s performance analyzing the latency introduced by the external memory hierarchic levels, presenting significant improvements in cryptographic processing speed, achieving up to 2.7x speedup for SHA-256/HMAC and 1.6x for AES accelerators, compared to baseline Earl Grey architecture.},
note = {Just Accepted},
journal = {ACM Trans. Embed. Comput. Syst.},
month = sep,
keywords = {RISC-V, OpenTitan, Embedded System Security, Secure System-on-Chips}
}

```
