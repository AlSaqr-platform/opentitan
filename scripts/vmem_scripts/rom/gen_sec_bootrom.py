import sys
from string import Template

# Get the input and output file paths from command line arguments
if len(sys.argv) < 3:
    print("Usage: python gen_sec_bootrom.py <input_file_path> <output_file_path>")
    sys.exit(1)
input_file_path = sys.argv[1]
output_file_path = sys.argv[2]

license = """\
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Autogenerated code
"""

module = """\
module secure_boot_rom import prim_rom_pkg::*; #(
  parameter int Width = 39,
  parameter int Depth = $depth,
  parameter int Aw = 11
) (
  input logic clk_i,
  input logic rst_ni,
  input logic req_i,
  input logic [Aw-1:0] addr_i,
  output logic [Width-1:0] rdata_o
);

  const logic [Depth-1:0][Width-1:0] mem = {
$output_contents
    };
  always_ff @(posedge clk_i) begin
    rdata_o <= '0;
    if (req_i) begin
      rdata_o <= mem[addr_i];
    end
  end

endmodule
"""

# Open the input file for reading
with open(input_file_path, 'r') as f:
    # Read the contents of the file into a string
    contents = f.read()

# Split the contents of the file into lines
lines = contents.split('\n')
lines.reverse()
# Create a list to hold the output lines
output_lines = []

# Iterate over the lines in the input file
for line in lines:
    # Skip any lines that don't start with "@"
    if not line.startswith('@'):
        continue
    
    # Otherwise, this line represents a new memory address
    data = line.split()[1:]
    data.reverse()
    
    # Transpose the row to columns
    for i in range(len(data)):
        # Create a new line for each element in the row
        output_line = "        39'h" + data[i]
        if i < len(data):
            output_lines.append(output_line + ',')

# Join the output lines into a string
output_contents = '\n'.join(output_lines)

# Calculate the depth based on the number of 39-bit words
depth = len(output_lines)

# Open the output file for writing
with open(output_file_path, 'w') as f:
    # remove last comma
    output_contents = output_contents[:-1]
    # Write the output string to the file
    f.write(license)
    s = Template(module)
    f.write(s.substitute(depth=depth, output_contents=output_contents))
