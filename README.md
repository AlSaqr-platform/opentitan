# OpenTitan

![OpenTitan logo](https://docs.opentitan.org/doc/opentitan-logo.png)

## About this branch

This branch has the purpose to integrate OT into the AlSaqr SoC. In order to do so, it is needed to modify the way OT is compiled according to the flow used for AlSaqr, to guarantee the correct integration.
The tool used in AlSaqr is bender, which uses as input a manifest in .yml format. Such manifest specifies which are the depdendencies and the source files for the module to which the .yml file is associated. Dependencies
can be provided as relative/absolute paths or even as github repositories.These dependencies point either to a git repo containing in the root dir a Bender.yml or even a relative path to a dir containing another
Bender.yml in the same repository. For OT all the dependencies are relative, not git. This unfortunately generates some problem with bender in AlSaqr (where , which is not able to add them to the compile.tcl, a solution for this
could be to write a unique main Bender.yml, so without including other .yml files. Instead all the .sv have to be included in such Bender.yml, in the correct order (the hierarchy between module must be kept, that's why
bender is powerful. Once you write the .yml respecting for it the hierachy for an ip, then you don't have to care about the order in which dependencies are fetched from the main Bender.yml which has as dep that ip. This semplifies a lot the work
with respect writing one unique Bender.yml. For this reason we will try to fix this "bug" trynig to avoid to use the one-main-bender approach. Currently, to dribble this issue, the opentitan dependency in alsaqr is overidden and cloned to local, by
this way the compile.tcl includes correctly all the dependencies. Anyway, this is not an issue for the AlSaqr branch. The simulation within this report is correctly working as it should.

## Current Architecture

The architecture under test actually is not the complete earlgray architecture. The ip instantiated in the top module are the only ones neede for the secure boot, removing ips like padframes and so on.
Moreover, the ips are not actually instantiated as they are in the ref arch, they are just instantiated, provided of clk and rst, provided of a connection to the Tile Link Crossbar (autogenerate by .py script starting form a hjson file.
So a TO DO surely is: implement completely the earlgrey arch with only the useful ips, so making all the intermodule connections and eventual multiple instantiation like uart0 uart1 and so on.
Below a block scheme of the current architecture is shown.

## Test setup

The top module implements the above architecture. The purpose is to test wether the building of the architecture works properly by using the tool
bender and to test wether the communication between the Ibex Core and all the ips through the TL crossbar works as well.  