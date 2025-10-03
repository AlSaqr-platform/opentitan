#!/usr/bin/env python3
import argparse
import numpy as np

# Random range for int8 (inclusive)
RAND_LOW = -128
RAND_HIGH = 127  # np.random.randint upper bound is exclusive, so +1 below


def format_array(name, arr, c_type, per_line=16):
    # Format integer array values
    vals = [str(int(v)) for v in arr]
    lines = []
    for i in range(0, len(vals), per_line):
        chunk = vals[i:i+per_line]
        lines.append("    " + ", ".join(chunk))
    body = ",\n".join(lines)
    return f"static const {c_type} {name}[] = {{\n{body},\n}};\n\n"


def main():
    p = argparse.ArgumentParser(
        description="Generate data.h for elementwise A+B with int8"
    )
    p.add_argument("-M", type=int, required=True, help="Number of rows")
    p.add_argument("-N", type=int, required=True, help="Number of columns")
    p.add_argument("-o", "--output", default="stimuli/data.h", help="Output filename")
    args = p.parse_args()

    M, N = args.M, args.N

    # 1) build random matrices A and B in int8
    A = np.random.randint(RAND_LOW, RAND_HIGH + 1, size=(M, N), dtype=np.int8)
    B = np.random.randint(RAND_LOW, RAND_HIGH + 1, size=(M, N), dtype=np.int8)

    # 2) compute elementwise sum (wrap-around semantics)
    R = (A.astype(np.int16) + B.astype(np.int16)).astype(np.int8)

    # flatten in row-major order
    A_flat = A.ravel()
    B_flat = B.ravel()
    R_flat = R.ravel()

    # emit data.h
    with open(args.output, "w") as f:
        f.write("#ifndef DATA_H\n#define DATA_H\n\n")
        f.write(f"#define M {M}\n")
        f.write(f"#define N {N}\n\n")
        f.write(format_array("A_mat", A_flat, "int8_t"))
        f.write(format_array("B_mat", B_flat, "int8_t"))
        f.write(format_array("ref", R_flat, "int8_t"))
        f.write("#endif // DATA_H\n")

    print(f"Wrote {args.output} with M={M}, N={N} (ref = A + B wrap-around)")


if __name__ == "__main__":
    main()
