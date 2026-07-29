@always_inline
def PackMask(mask: SIMD[DType.uint8, 64]) -> UInt64:

    var bits = mask & 1
    var result: UInt64 = 0

    comptime for i in range(8):

        var chunk = bits.slice[8, offset=i*8]()

        var byte = (
            UInt64(chunk[0]) |
            (UInt64(chunk[1]) << 1) |
            (UInt64(chunk[2]) << 2) |
            (UInt64(chunk[3]) << 3) |
            (UInt64(chunk[4]) << 4) |
            (UInt64(chunk[5]) << 5) |
            (UInt64(chunk[6]) << 6) |
            (UInt64(chunk[7]) << 7)
        )

        result |= byte << (i * 8)

    return result
