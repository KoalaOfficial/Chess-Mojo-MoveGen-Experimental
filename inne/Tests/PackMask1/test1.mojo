@always_inline
def PackMask(mask: SIMD[DType.uint8, 64]) -> UInt64:
    var result: UInt64 = 0

    for i in range(64):
        result |= (UInt64(mask[i]) & 1) << UInt64(i)

    return result