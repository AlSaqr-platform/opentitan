#!/usr/bin/env python3
import argparse
import numpy as np

# Random range
RAND_MIN = -3.0
RAND_MAX = 3.0

def format_array(name, arr, c_type, per_line=8, precision=16):
    """
    Build a C array initializer without ever splitting
    a value in half.  Each line will have up to `per_line`
    comma-separated values, all formatted to `precision` decimals.
    """
    # 1) render every float
    vals = [f"{v:.{precision}f}" for v in arr]
    # 2) chunk into fixed-size rows
    lines = []
    for i in range(0, len(vals), per_line):
        chunk = vals[i:i+per_line]
        lines.append("  " + ", ".join(chunk))
    # 3) join lines with commas between them, and a trailing comma
    body = ",\n".join(lines)
    return f"PI_L2 {c_type} {name}[] = {{\n{body},\n}};\n\n"

def main():
    p = argparse.ArgumentParser(
        description="Generate data.h with"
    )
    p.add_argument("-M", type=int, required=True, help="Rows of A")
    p.add_argument("-N", type=int, required=True, help="Cols of A / Rows of B")
    p.add_argument("-P", type=int, required=True, help="Cols of B")
    p.add_argument("-o", "--output", default="data.h", help="Output filename")
    args = p.parse_args()

    M, N, P = args.M, args.N, args.P

    # 1) build random matrices
    A = np.random.uniform(RAND_MIN, RAND_MAX, size=(M, N)).astype(np.float32)
    B = np.random.uniform(RAND_MIN, RAND_MAX, size=(N, P)).astype(np.float32)
    # 2) compute reference product
    R = A.dot(B).astype(np.float32)

    # flatten in row-major order
    A_flat = A.ravel()
    B_flat = B.ravel()
    R_flat = R.ravel()

    # write out
    with open(args.output, "w") as f:
        f.write("#ifndef DATA_H\n#define DATA_H\n\n")
        f.write(f"#define M {M}\n")
        f.write(f"#define N {N}\n")
        f.write(f"#define P {P}\n\n")
        f.write(format_array("A_mat", A_flat, "MA_TYPE"))
        f.write(format_array("B_mat", B_flat, "MB_TYPE"))
        f.write(format_array("ref",   R_flat, "OUT_TYPE"))
        f.write("#endif // DATA_H\n")

    print(f"Wrote {args.output} with M={M}, N={N}, P={P}")

if __name__ == "__main__":
    main()
