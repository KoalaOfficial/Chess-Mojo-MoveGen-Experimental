
@always_inline
def ReverseBits(x: UInt64) -> UInt64:
    var v = x

    # swap odd/even bits
    v = ((v >> 1) & 0x5555555555555555) | ((v & 0x5555555555555555) << 1)

    # swap consecutive pairs
    v = ((v >> 2) & 0x3333333333333333) | ((v & 0x3333333333333333) << 2)

    # swap nibbles
    v = ((v >> 4) & 0x0F0F0F0F0F0F0F0F) | ((v & 0x0F0F0F0F0F0F0F0F) << 4)

    # swap bytes
    v = ((v >> 8) & 0x00FF00FF00FF00FF) | ((v & 0x00FF00FF00FF00FF) << 8)

    # swap 16-bit words
    v = ((v >> 16) & 0x0000FFFF0000FFFF) | ((v & 0x0000FFFF0000FFFF) << 16)

    # swap 32-bit halves
    v = (v >> 32) | (v << 32)

    return v


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

        result |= byte << UInt64(i * 8)

    return result


@always_inline
def Square(rank: Int, file: Int) -> Int:
    return rank * 8 + file



@always_inline
def SetBit(square: Int) -> UInt64:
    return UInt64(1) << UInt64(square)

@always_inline
def HyperbolaAttacks(occupancy: UInt64,piece_bit: UInt64,line_mask: UInt64) -> UInt64:
    var mask = line_mask & ~piece_bit

    var forward = occupancy & mask
    var reverse = ReverseBits(forward)

    forward -= piece_bit
    reverse -= ReverseBits(piece_bit)

    forward ^= ReverseBits(reverse)

    return forward & mask


