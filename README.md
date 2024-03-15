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

## Dependencies
To install the dependencies required by OpenTitan and to build the doc, run:
```
git clone https://www.github.com/alsaqr-platform/opentitan.git
cd opentitan/
sed '/^#/d' ./apt-requirements.txt | xargs sudo apt install -y
pip3 install --user -r python-requirements.txt
```
## Documentation

The detailed documentation can be built within this repository. The following commands configures and runs
a local server, accessible by the browser. This server basically represent the official opentitan.org website
including the customization we implemented, particularly, concerning the memory map.

To build the doc and run the server:
```
make -C hw/ top
python3 util/build_docs.py --preview
```
## How to contribute

Have a look at [CONTRIBUTING](https://github.com/lowRISC/opentitan/blob/master/CONTRIBUTING.md) and our [documentation on
project organization and processes](https://docs.opentitan.org/doc/project/)
for guidelines on how to contribute code to this repository.

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see [LICENSE](https://github.com/lowRISC/opentitan/blob/master/LICENSE) for full text).
