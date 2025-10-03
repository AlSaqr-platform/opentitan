#!/usr/bin/env python3
import argparse
import numpy as np

# Random range
RAND_MIN = -3.0
RAND_MAX = 3.0

def format_array(name, arr, c_type, per_line=8, precision=16):
    vals = [f"{v:.{precision}f}" for v in arr]
    lines = []
    for i in range(0, len(vals), per_line):
        chunk = vals[i:i+per_line]
        lines.append("  " + ", ".join(chunk))
    body = ",\n".join(lines)
    return f"PI_L2 {c_type} {name}[] = {{\n{body},\n}};\n\n"

def main():
    p = argparse.ArgumentParser(
        description="Generate data.h for elementwise A+B"
    )
    p.add_argument("-M", type=int, required=True, help="Number of rows")
    p.add_argument("-N", type=int, required=True, help="Number of columns")
    p.add_argument("-o", "--output", default="stimuli/data.h", help="Output filename")
    args = p.parse_args()

    M, N = args.M, args.N

    # 1) build random matrices A and B
    A = np.random.uniform(RAND_MIN, RAND_MAX, size=(M, N)).astype(np.float32)
    B = np.random.uniform(RAND_MIN, RAND_MAX, size=(M, N)).astype(np.float32)

    # 2) compute elementwise sum
    R = (A + B).astype(np.float32)

    # flatten in row-major order
    A_flat = A.ravel()
    B_flat = B.ravel()
    R_flat = R.ravel()

    # emit data.h
    with open(args.output, "w") as f:
        f.write("#ifndef DATA_H\n#define DATA_H\n\n")
        f.write(f"#define M {M}\n")
        f.write(f"#define N {N}\n\n")
        f.write(format_array("A_mat", A_flat, "MA_TYPE"))
        f.write(format_array("B_mat", B_flat, "MB_TYPE"))
        f.write(format_array("ref",   R_flat, "OUT_TYPE"))
        f.write("#endif // DATA_H\n")

    print(f"Wrote {args.output} with M={M}, N={N} (ref = A + B)")

if __name__ == "__main__":
    main()
