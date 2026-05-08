// Copyright 2026 Fondazione Chips-IT / ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// idma.h – Software driver for the iDMA engine (idma_reg32_3d frontend)
//
// Register layout is derived from:
//   hw/ip/crypto_sram_wrap/rtl/idma_wrap.sv
//   src/frontend/reg/tpl/idma_reg.hjson.tpl  (reg32, 3D, 1 stream)
//   src/idma_pkg.sv
//
// AXI address / data widths and base addresses are SoC-specific; adjust
// IDMA_BASE and IDMA_TCDM_BASE to match your memory map.

#ifndef IDMA_H_
#define IDMA_H_

#include <stdint.h>

// ---------------------------------------------------------------------------
// Base addresses (override with -DIDMA_BASE=0x... if needed)
// ---------------------------------------------------------------------------
#ifndef IDMA_BASE
#define IDMA_BASE        (0xfef00000u)   // iDMA control registers
#endif
#ifndef IDMA_TCDM_BASE
#define IDMA_TCDM_BASE   (0xfff00000u)   // TCDM window (read source)
#endif
#ifndef IDMA_TCDM_END
#define IDMA_TCDM_END    (0xfff08000u)   // TCDM window end (exclusive)
#endif

// ---------------------------------------------------------------------------
// Register offsets  (idma_reg32_3d, single stream, NumStreams=1)
// ---------------------------------------------------------------------------

// ---- Control / status (fixed layout) ------------------------------------
#define IDMA_CONF_REG_OFFSET          0x000u  // RW: configuration
#define IDMA_STATUS_0_REG_OFFSET      0x004u  // RO: busy flags (stream 0)
#define IDMA_STATUS_1_REG_OFFSET      0x008u  // RO: busy flags (stream 1, if present)
#define IDMA_NEXT_ID_0_REG_OFFSET     0x00Cu  // RO: read triggers launch, returns tx id
#define IDMA_NEXT_ID_1_REG_OFFSET     0x010u  // RO: stream-1 version
#define IDMA_DONE_ID_0_REG_OFFSET     0x014u  // RO: last completed tx id (stream 0)
#define IDMA_DONE_ID_1_REG_OFFSET     0x018u  // RO: last completed tx id (stream 1)

// ---- 1D transfer registers ----------------------------------------------
#define IDMA_DST_ADDR_LOW_REG_OFFSET  0x0D0u  // RW: destination address (low 32 bits)
#define IDMA_SRC_ADDR_LOW_REG_OFFSET  0x0D8u  // RW: source address (low 32 bits)
#define IDMA_LENGTH_LOW_REG_OFFSET    0x0E0u  // RW: transfer length in bytes

// ---- 2D extension -------------------------------------------------------
#define IDMA_DST_STRIDE_2_LOW_REG_OFFSET  0x0E8u  // RW: dst stride for dim-2
#define IDMA_SRC_STRIDE_2_LOW_REG_OFFSET  0x0F0u  // RW: src stride for dim-2
#define IDMA_REPS_2_LOW_REG_OFFSET        0x0F8u  // RW: repetitions for dim-2

// ---- 3D extension -------------------------------------------------------
#define IDMA_DST_STRIDE_3_LOW_REG_OFFSET  0x100u  // RW: dst stride for dim-3
#define IDMA_SRC_STRIDE_3_LOW_REG_OFFSET  0x108u  // RW: src stride for dim-3
#define IDMA_REPS_3_LOW_REG_OFFSET        0x110u  // RW: repetitions for dim-3

// ---------------------------------------------------------------------------
// CONF register bitfields
// ---------------------------------------------------------------------------
// [0]     decouple_aw  – decouple AW from R (improves unaligned / boundary-crossing)
// [1]     decouple_rw  – fully decouple R and W channels
// [2]     src_reduce_len – force smaller source bursts
// [3]     dst_reduce_len – force smaller destination bursts
// [6:4]   src_max_llen – max log2 burst length on source  (0 = uncapped)
// [9:7]   dst_max_llen – max log2 burst length on destination
// [11:10] enable_nd    – 0=1D, 1=2D, 2=3D  (bits set by the front-end template)
// [14:12] src_protocol – source bus protocol (see IDMA_PROT_*)
// [17:15] dst_protocol – destination bus protocol

#define IDMA_CONF_DECOUPLE_AW_BIT         0u
#define IDMA_CONF_DECOUPLE_RW_BIT         1u
#define IDMA_CONF_SRC_REDUCE_LEN_BIT      2u
#define IDMA_CONF_DST_REDUCE_LEN_BIT      3u

#define IDMA_CONF_SRC_MAX_LLEN_SHIFT      4u
#define IDMA_CONF_SRC_MAX_LLEN_MASK       (0x7u << IDMA_CONF_SRC_MAX_LLEN_SHIFT)
#define IDMA_CONF_DST_MAX_LLEN_SHIFT      7u
#define IDMA_CONF_DST_MAX_LLEN_MASK       (0x7u << IDMA_CONF_DST_MAX_LLEN_SHIFT)

#define IDMA_CONF_ENABLE_ND_SHIFT         10u
#define IDMA_CONF_ENABLE_ND_MASK          (0x3u << IDMA_CONF_ENABLE_ND_SHIFT)

#define IDMA_CONF_SRC_PROTOCOL_SHIFT      12u
#define IDMA_CONF_SRC_PROTOCOL_MASK       (0x7u << IDMA_CONF_SRC_PROTOCOL_SHIFT)
#define IDMA_CONF_DST_PROTOCOL_SHIFT      15u
#define IDMA_CONF_DST_PROTOCOL_MASK       (0x7u << IDMA_CONF_DST_PROTOCOL_SHIFT)

// STATUS register bitfields  [9:0] = 10-bit busy vector
#define IDMA_STATUS_BUSY_MASK             0x3FFu

// Individual busy bits inside STATUS (from idma_pkg::idma_busy_t)
// The status register stores {midend_busy, idma_busy_t} packed into 10 bits:
//   bit 9: midend_busy
//   bit 8: buffer_busy
//   bit 7: r_dp_busy
//   bit 6: w_dp_busy
//   bit 5: r_leg_busy
//   bit 4: w_leg_busy
//   bit 3: eh_fsm_busy
//   bit 2: eh_cnt_busy
//   bit 1: raw_coupler_busy
//   bit 0: (LSB; currently unused)
#define IDMA_STATUS_MIDEND_BUSY_BIT       9u
#define IDMA_STATUS_BUFFER_BUSY_BIT       8u
#define IDMA_STATUS_R_DP_BUSY_BIT         7u
#define IDMA_STATUS_W_DP_BUSY_BIT         6u
#define IDMA_STATUS_R_LEG_BUSY_BIT        5u
#define IDMA_STATUS_W_LEG_BUSY_BIT        4u

// ---------------------------------------------------------------------------
// Protocol enum  (idma_pkg::protocol_e)
// ---------------------------------------------------------------------------
#define IDMA_PROT_AXI        0u   // Full AXI4  (L2 / SoC memory)
#define IDMA_PROT_OBI        1u   // OBI        (L1 / TCDM)
#define IDMA_PROT_AXILITE    2u   // AXI-Lite
#define IDMA_PROT_TILELINK   3u   // TileLink-UH
#define IDMA_PROT_INIT       4u   // INIT: reads=0, writes=/dev/null

// ---------------------------------------------------------------------------
// Ready-made CONF values for common use cases
// ---------------------------------------------------------------------------
// 1D AXI→AXI (plain memcpy between two AXI-attached memories)
#define IDMA_CONF_1D_AXI_TO_AXI  \
    ((IDMA_PROT_AXI << IDMA_CONF_SRC_PROTOCOL_SHIFT) | \
     (IDMA_PROT_AXI << IDMA_CONF_DST_PROTOCOL_SHIFT))

// 1D AXI→AXI + full decoupling (best for unaligned / boundary-crossing)
#define IDMA_CONF_1D_AXI_TO_AXI_DECOUPLE  \
    (IDMA_CONF_1D_AXI_TO_AXI | \
     (1u << IDMA_CONF_DECOUPLE_AW_BIT) | \
     (1u << IDMA_CONF_DECOUPLE_RW_BIT))

// 1D OBI(TCDM)→AXI (L1 to L2)
#define IDMA_CONF_1D_OBI_TO_AXI  \
    ((IDMA_PROT_OBI << IDMA_CONF_SRC_PROTOCOL_SHIFT) | \
     (IDMA_PROT_AXI << IDMA_CONF_DST_PROTOCOL_SHIFT))

// 1D AXI→OBI (L2 to L1/TCDM)
#define IDMA_CONF_1D_AXI_TO_OBI  \
    ((IDMA_PROT_AXI << IDMA_CONF_SRC_PROTOCOL_SHIFT) | \
     (IDMA_PROT_OBI << IDMA_CONF_DST_PROTOCOL_SHIFT))

// 2D AXI→AXI  (enable_nd=1)
#define IDMA_CONF_2D_AXI_TO_AXI  \
    (IDMA_CONF_1D_AXI_TO_AXI | (1u << IDMA_CONF_ENABLE_ND_SHIFT))

// 3D AXI→AXI  (enable_nd=2)
#define IDMA_CONF_3D_AXI_TO_AXI  \
    (IDMA_CONF_1D_AXI_TO_AXI | (2u << IDMA_CONF_ENABLE_ND_SHIFT))

// Zero-fill destination (INIT→AXI), src bytes come from /dev/zero
#define IDMA_CONF_1D_ZERO_TO_AXI  \
    ((IDMA_PROT_INIT << IDMA_CONF_SRC_PROTOCOL_SHIFT) | \
     (IDMA_PROT_AXI  << IDMA_CONF_DST_PROTOCOL_SHIFT))

// ---------------------------------------------------------------------------
// Return codes
// ---------------------------------------------------------------------------
#define IDMA_OK                0
#define IDMA_ERR_ZERO_LEN     -1   // zero-length transfer rejected by HW
#define IDMA_ERR_NULL_ID      -2   // NEXT_ID returned 0 (HW refused request)

// ---------------------------------------------------------------------------
// Transaction ID type
// ---------------------------------------------------------------------------
typedef uint32_t idma_txn_id_t;
#define IDMA_INVALID_ID  0u

// ---------------------------------------------------------------------------
// Inline register accessor (matches the reg32() macro used across the repo)
// ---------------------------------------------------------------------------
static inline volatile uint32_t *idma_reg32(uint32_t base, uint32_t offset) {
    return (volatile uint32_t *)((uintptr_t)base + offset);
}

// ---------------------------------------------------------------------------
// Low-level register helpers
// ---------------------------------------------------------------------------

/** Read a 32-bit iDMA register. */
static inline uint32_t idma_reg_read(uint32_t base, uint32_t offset) {
    return *idma_reg32(base, offset);
}

/** Write a 32-bit iDMA register. */
static inline void idma_reg_write(uint32_t base, uint32_t offset, uint32_t val) {
    *idma_reg32(base, offset) = val;
}

// ---------------------------------------------------------------------------
// CONF helpers
// ---------------------------------------------------------------------------

/** Build a CONF value from individual fields.
 *
 *  @param src_prot   IDMA_PROT_AXI / IDMA_PROT_OBI / IDMA_PROT_INIT / ...
 *  @param dst_prot   IDMA_PROT_AXI / IDMA_PROT_OBI / IDMA_PROT_INIT / ...
 *  @param enable_nd  0=1D, 1=2D, 2=3D
 *  @param decouple   1 = enable decouple_aw | decouple_rw (use for unaligned)
 *  @param src_max_llen  3-bit log2 burst cap on source  (0 = uncapped)
 *  @param dst_max_llen  3-bit log2 burst cap on destination
 *  @param src_reduce_len  1 = reduce source burst lengths
 *  @param dst_reduce_len  1 = reduce destination burst lengths
 */
static inline uint32_t idma_build_conf(uint32_t src_prot,
                                       uint32_t dst_prot,
                                       uint32_t enable_nd,
                                       uint32_t decouple,
                                       uint32_t src_max_llen,
                                       uint32_t dst_max_llen,
                                       uint32_t src_reduce_len,
                                       uint32_t dst_reduce_len) {
    return ((src_prot      & 0x7u) << IDMA_CONF_SRC_PROTOCOL_SHIFT)  |
           ((dst_prot      & 0x7u) << IDMA_CONF_DST_PROTOCOL_SHIFT)  |
           ((enable_nd     & 0x3u) << IDMA_CONF_ENABLE_ND_SHIFT)     |
           ((src_max_llen  & 0x7u) << IDMA_CONF_SRC_MAX_LLEN_SHIFT)  |
           ((dst_max_llen  & 0x7u) << IDMA_CONF_DST_MAX_LLEN_SHIFT)  |
           ((src_reduce_len & 1u)  << IDMA_CONF_SRC_REDUCE_LEN_BIT)  |
           ((dst_reduce_len & 1u)  << IDMA_CONF_DST_REDUCE_LEN_BIT)  |
           (decouple ? ((1u << IDMA_CONF_DECOUPLE_AW_BIT) |
                        (1u << IDMA_CONF_DECOUPLE_RW_BIT)) : 0u);
}

/** Write the CONF register. */
static inline void idma_set_conf(uint32_t base, uint32_t conf) {
    idma_reg_write(base, IDMA_CONF_REG_OFFSET, conf);
}

// ---------------------------------------------------------------------------
// STATUS helpers
// ---------------------------------------------------------------------------

/** Read the raw STATUS[0] busy vector. Non-zero = engine is busy. */
static inline uint32_t idma_status(uint32_t base) {
    return idma_reg_read(base, IDMA_STATUS_0_REG_OFFSET) & IDMA_STATUS_BUSY_MASK;
}

/** Returns non-zero if any sub-unit is still busy. */
static inline int idma_busy(uint32_t base) {
    return (idma_status(base) != 0u);
}

// ---------------------------------------------------------------------------
// Transfer submission
// ---------------------------------------------------------------------------

/** Program source, destination and byte length for a 1D transfer.
 *  Caller must write CONF before calling this (or use idma_issue_1d).
 */
static inline void idma_set_addrs(uint32_t base,
                                  uint32_t src,
                                  uint32_t dst,
                                  uint32_t len) {
    idma_reg_write(base, IDMA_SRC_ADDR_LOW_REG_OFFSET, src);
    idma_reg_write(base, IDMA_DST_ADDR_LOW_REG_OFFSET, dst);
    idma_reg_write(base, IDMA_LENGTH_LOW_REG_OFFSET,   len);
}

/** Program dim-2 ND parameters (stride and repetition count). */
static inline void idma_set_2d(uint32_t base,
                                uint32_t src_stride,
                                uint32_t dst_stride,
                                uint32_t reps) {
    idma_reg_write(base, IDMA_SRC_STRIDE_2_LOW_REG_OFFSET, src_stride);
    idma_reg_write(base, IDMA_DST_STRIDE_2_LOW_REG_OFFSET, dst_stride);
    idma_reg_write(base, IDMA_REPS_2_LOW_REG_OFFSET,       reps);
}

/** Program dim-3 ND parameters. */
static inline void idma_set_3d(uint32_t base,
                                uint32_t src_stride,
                                uint32_t dst_stride,
                                uint32_t reps) {
    idma_reg_write(base, IDMA_SRC_STRIDE_3_LOW_REG_OFFSET, src_stride);
    idma_reg_write(base, IDMA_DST_STRIDE_3_LOW_REG_OFFSET, dst_stride);
    idma_reg_write(base, IDMA_REPS_3_LOW_REG_OFFSET,       reps);
}

/** Launch a transfer by reading NEXT_ID; returns the transaction id.
 *  Returns IDMA_INVALID_ID if the hardware refused (misconfigured transfer).
 */
static inline idma_txn_id_t idma_launch(uint32_t base) {
    return idma_reg_read(base, IDMA_NEXT_ID_0_REG_OFFSET);
}

/** Poll until the given transaction id has been retired.
 *  Uses >= so pipelined transfers that advance DONE_ID past `id` still
 *  complete correctly (same logic as idma_wait in snooper_fetch_test).
 */
static inline void idma_wait(uint32_t base, idma_txn_id_t id) {
    while ((int32_t)idma_reg_read(base, IDMA_DONE_ID_0_REG_OFFSET) < (int32_t)id)
        __asm__ volatile("nop");
}

/** Poll until the engine is fully idle (all status bits clear). */
static inline void idma_wait_idle(uint32_t base) {
    while (idma_busy(base))
        __asm__ volatile("nop");
}

// ---------------------------------------------------------------------------
// High-level convenience wrappers
// ---------------------------------------------------------------------------

/** Issue a 1D transfer and return the transaction id.
 *  @param base    IDMA_BASE
 *  @param src     source byte address
 *  @param dst     destination byte address
 *  @param len     number of bytes to copy
 *  @param conf    CONF value (use IDMA_CONF_1D_AXI_TO_AXI or idma_build_conf())
 *  @return        transaction id (IDMA_INVALID_ID on hw error)
 */
static inline idma_txn_id_t idma_issue_1d(uint32_t base,
                                           uint32_t src,
                                           uint32_t dst,
                                           uint32_t len,
                                           uint32_t conf) {
    idma_set_conf(base, conf);
    idma_reg_write(base, IDMA_REPS_2_LOW_REG_OFFSET, 1u);  // disable 2D/3D
    idma_set_addrs(base, src, dst, len);
    return idma_launch(base);
}

/** Issue a 2D transfer and return the transaction id.
 *  @param base        IDMA_BASE
 *  @param src         source base address
 *  @param dst         destination base address
 *  @param len         bytes per 1D slice
 *  @param src_stride  byte stride between consecutive source rows
 *  @param dst_stride  byte stride between consecutive destination rows
 *  @param reps        number of 1D repetitions (rows)
 *  @param conf        CONF value (must have enable_nd=1; use IDMA_CONF_2D_AXI_TO_AXI)
 */
static inline idma_txn_id_t idma_issue_2d(uint32_t base,
                                           uint32_t src,
                                           uint32_t dst,
                                           uint32_t len,
                                           uint32_t src_stride,
                                           uint32_t dst_stride,
                                           uint32_t reps,
                                           uint32_t conf) {
    idma_set_conf(base, conf);
    idma_set_addrs(base, src, dst, len);
    idma_set_2d(base, src_stride, dst_stride, reps);
    idma_reg_write(base, IDMA_REPS_3_LOW_REG_OFFSET, 1u);  // disable dim-3
    return idma_launch(base);
}

/** Issue a 3D transfer and return the transaction id.
 *  @param base          IDMA_BASE
 *  @param src           source base address
 *  @param dst           destination base address
 *  @param len           bytes per innermost 1D slice
 *  @param src_stride_2  stride between rows in source (dim-2)
 *  @param dst_stride_2  stride between rows in destination (dim-2)
 *  @param reps_2        number of rows per page (dim-2 repetitions)
 *  @param src_stride_3  stride between pages in source (dim-3)
 *  @param dst_stride_3  stride between pages in destination (dim-3)
 *  @param reps_3        number of pages (dim-3 repetitions)
 *  @param conf          CONF value (enable_nd=2; use IDMA_CONF_3D_AXI_TO_AXI)
 */
static inline idma_txn_id_t idma_issue_3d(uint32_t base,
                                           uint32_t src,
                                           uint32_t dst,
                                           uint32_t len,
                                           uint32_t src_stride_2,
                                           uint32_t dst_stride_2,
                                           uint32_t reps_2,
                                           uint32_t src_stride_3,
                                           uint32_t dst_stride_3,
                                           uint32_t reps_3,
                                           uint32_t conf) {
    idma_set_conf(base, conf);
    idma_set_addrs(base, src, dst, len);
    idma_set_2d(base, src_stride_2, dst_stride_2, reps_2);
    idma_set_3d(base, src_stride_3, dst_stride_3, reps_3);
    return idma_launch(base);
}

/** Blocking 1D memcpy.  Returns IDMA_OK, or IDMA_ERR_ZERO_LEN / IDMA_ERR_NULL_ID. */
static inline int idma_memcpy(uint32_t base,
                               uint32_t src,
                               uint32_t dst,
                               uint32_t len,
                               uint32_t conf) {
    if (len == 0u) return IDMA_ERR_ZERO_LEN;
    idma_txn_id_t id = idma_issue_1d(base, src, dst, len, conf);
    if (id == IDMA_INVALID_ID) return IDMA_ERR_NULL_ID;
    idma_wait(base, id);
    return IDMA_OK;
}

/** Blocking zero-fill of `len` bytes at `dst` (AXI-attached). */
static inline int idma_zeromem(uint32_t base, uint32_t dst, uint32_t len) {
    return idma_memcpy(base, 0u, dst, len, IDMA_CONF_1D_ZERO_TO_AXI);
}

// ---------------------------------------------------------------------------
// 32-bit granularity transfers
//
// The iDMA backend's AXI beat width is FIXED at compile-time via AxiDataWidth
// (ARSIZE/AWSIZE is hardwired to $clog2(AxiDataWidth/8) in the legalizer).
// There is no runtime register to change the beat width.
//
// If AxiDataWidth=64 (8-byte beats), a 1D transfer of N bytes still works
// correctly for any N — the backend uses AXI byte strobes (WSTRB/RSTRB) to
// mask unused bytes in the first/last partial beats.
//
// To truly force 32-bit AXI beats: set AxiDataWidth=32 in the RTL parameter.
//
// The closest runtime approximation is a 2D transfer with len=4 bytes per
// slice so the engine issues N/4 independent 4-byte transactions (each maps
// to one 64-bit beat with 4 strobe bits active).  This is useful when the
// target peripheral only accepts word-sized (32-bit) accesses.
//
// Constraints: src, dst and len must all be 4-byte aligned.
// ---------------------------------------------------------------------------

/**
 * Issue a word-granular copy: N bytes in 4-byte-at-a-time chunks.
 *
 * Useful when the target only accepts 32-bit accesses.  Uses 2D mode with
 * len=4 and stride=4 so each DMA slice maps to a single 32-bit word.
 *
 * @param base  IDMA_BASE
 * @param src   source address (must be 4-byte aligned)
 * @param dst   destination address (must be 4-byte aligned)
 * @param len   total bytes to copy (must be a multiple of 4)
 * @param conf  base CONF; enable_nd will be forced to 2D (1) internally
 * @return      transaction id, or IDMA_INVALID_ID on error
 */
static inline idma_txn_id_t idma_issue_word_granular(uint32_t base,
                                                      uint32_t src,
                                                      uint32_t dst,
                                                      uint32_t len,
                                                      uint32_t conf) {
    /* Force enable_nd = 1 (2D), clear any existing enable_nd bits */
    uint32_t conf2d = (conf & ~IDMA_CONF_ENABLE_ND_MASK) |
                      (1u << IDMA_CONF_ENABLE_ND_SHIFT);
    uint32_t reps = len >> 2;  /* len / 4 */
    return idma_issue_2d(base, src, dst,
                         4u,    /* bytes per slice  = 1 word */
                         4u,    /* src stride       = 1 word */
                         4u,    /* dst stride       = 1 word */
                         reps,
                         conf2d);
}

/**
 * Blocking word-granular memcpy.
 *
 * @return IDMA_OK, IDMA_ERR_ZERO_LEN, or IDMA_ERR_NULL_ID
 */
static inline int idma_memcpy_word(uint32_t base,
                                   uint32_t src,
                                   uint32_t dst,
                                   uint32_t len,
                                   uint32_t conf) {
    if (len == 0u) return IDMA_ERR_ZERO_LEN;
    idma_txn_id_t id = idma_issue_word_granular(base, src, dst, len, conf);
    if (id == IDMA_INVALID_ID) return IDMA_ERR_NULL_ID;
    idma_wait(base, id);
    return IDMA_OK;
}

#endif  // IDMA_H_
