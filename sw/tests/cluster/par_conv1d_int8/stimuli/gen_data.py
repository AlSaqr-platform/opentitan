#!/usr/bin/env python3
import argparse
import numpy as np
from math import floor

# Random range for int8 (inclusive)
RAND_LOW = -128
RAND_HIGH = 127

# Quantization helper

def quant_i8(value, mult, shift, relu=False):
    res = (value * mult) >> shift
    if relu:
        res = max(0, res)
    # clamp to int8
    return np.int8(np.clip(res, -128, 127))

# 1D convolution reference implementation

def conv1d_int8(input, weight, bias, stride, dilation, padding, out_mult, out_shift, relu):
    # input: (dim_in_x, ch_in)
    dim_in_x, ch_in = input.shape
    ch_out, ch_in_w, dim_k_x = weight.shape
    assert ch_in == ch_in_w
    pad_left, pad_right = padding
    # effective kernel length
    eff_k = dilation * (dim_k_x - 1) + 1
    # output length
    dim_out_x = floor((dim_in_x + pad_left + pad_right - eff_k) / stride) + 1

    out = np.zeros((dim_out_x, ch_out), dtype=np.int8)
    # pad input
    inp_padded = np.zeros((dim_in_x + pad_left + pad_right, ch_in), dtype=np.int8)
    inp_padded[pad_left:pad_left+dim_in_x, :] = input

    for x in range(dim_out_x):
        for oc in range(ch_out):
            acc = 0
            for k in range(dim_k_x):
                in_x = x * stride + k * dilation
                for ic in range(ch_in):
                    acc += int(inp_padded[in_x, ic]) * int(weight[oc, ic, k])
            acc += int(bias[oc])
            out[x, oc] = quant_i8(acc, out_mult, out_shift, relu)
    return out

# format array: one element per line with index comment

def format_array(name, arr, c_type):
    lines = []
    flat = arr.ravel()
    for idx, v in enumerate(flat):
        lines.append(f"    {int(v)}, // index {idx}")
    body = "\n".join(lines)
    return f"static const {c_type} {name}[] = {{\n{body}\n}};\n\n"

if __name__ == '__main__':
    p = argparse.ArgumentParser(description="Generate data.h for 1D convolution i8 test")
    # dims and channels
    p.add_argument('--dim_in_x', type=int, required=True)
    p.add_argument('--ch_in', type=int, required=True)
    p.add_argument('--ch_out', type=int, required=True)
    p.add_argument('--kern_x', type=int, required=True)
    # stride, dilation, padding
    p.add_argument('--stride', type=int, default=1)
    p.add_argument('--dilation', type=int, default=1)
    p.add_argument('--pad_left', type=int, default=0)
    p.add_argument('--pad_right', type=int, default=0)
    # quant params
    p.add_argument('--out_mult', type=int, default=1)
    p.add_argument('--out_shift', type=int, default=0)
    # flags
    p.add_argument('--relu', action='store_true')
    p.add_argument('--batch_norm', action='store_true')  # kept for header consistency
    p.add_argument('-o', '--output', default='stimuli/data_conv1d.h')
    args = p.parse_args()

    # compute output length
    eff_k = args.dilation * (args.kern_x - 1) + 1
    dim_out_x = floor((args.dim_in_x + args.pad_left + args.pad_right - eff_k) / args.stride) + 1

    # random data
    input = np.random.randint(RAND_LOW, RAND_HIGH+1,
                               size=(args.dim_in_x, args.ch_in), dtype=np.int8)
    weight = np.random.randint(RAND_LOW, RAND_HIGH+1,
                               size=(args.ch_out, args.ch_in, args.kern_x), dtype=np.int8)
    bias = np.random.randint(RAND_LOW, RAND_HIGH+1, size=(args.ch_out,), dtype=np.int8)

    # compute reference
    ref = conv1d_int8(
        input, weight, bias,
        stride=args.stride,
        dilation=args.dilation,
        padding=(args.pad_left, args.pad_right),
        out_mult=args.out_mult,
        out_shift=args.out_shift,
        relu=args.relu
    )

    # flatten for header
    inp_flat = input.ravel()
    w_flat = weight.ravel(order='C')
    b_flat = bias.ravel()
    r_flat = ref.ravel()

    # write header
    with open(args.output, 'w') as f:
        f.write('#ifndef DATA_CONV1D_H\n#define DATA_CONV1D_H\n\n')
        # specs
        f.write(f'#define DIM_IN_X {args.dim_in_x}\n')
        f.write(f'#define CH_IN {args.ch_in}\n')
        f.write(f'#define CH_OUT {args.ch_out}\n')
        f.write(f'#define KERN_X {args.kern_x}\n')
        f.write(f'#define STRIDE {args.stride}\n')
        f.write(f'#define DILATION {args.dilation}\n')
        f.write(f'#define PAD_LEFT {args.pad_left}\n')
        f.write(f'#define PAD_RIGHT {args.pad_right}\n')
        f.write(f'#define DIM_OUT_X {dim_out_x}\n')
        f.write(f'#define OUT_MULT {args.out_mult}\n')
        f.write(f'#define OUT_SHIFT {args.out_shift}\n')
        f.write(f'#define FLAG_RELU {int(args.relu)}\n')
        f.write(f'#define FLAG_BATCH_NORM {int(args.batch_norm)}\n\n')

        # arrays
        f.write(format_array('pIn', inp_flat, 'int8_t'))
        f.write(format_array('pWeight', w_flat, 'int8_t'))
        f.write(format_array('pBias', b_flat, 'int8_t'))
        f.write(format_array('ref', r_flat, 'int8_t'))

        f.write('#endif // DATA_CONV1D_H\n')

    print(f"Wrote {args.output} with 1D convolution test data")
