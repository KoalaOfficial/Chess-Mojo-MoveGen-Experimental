from std.time import perf_counter_ns
from src.constants import *

comptime Iterations = 100_000_000

# ============================================================
# PACKMASK V2
# ============================================================

@always_inline
def PackMask_V2(mask: SIMD[DType.uint8,64]) -> UInt64:

    var result: UInt64 = 0

    comptime for block in range(8):

        var chunk = mask.slice[8, offset=block*8]()

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

        result |= byte << UInt64(block*8)


    return result



# ============================================================
# PACKMASK V3
# ============================================================

@always_inline
def PackMask_V3(mask: SIMD[DType.uint8, 64]) -> UInt64:
    var bits = mask & 1

    return (
        UInt64(bits[0]) |
        (UInt64(bits[1]) << 1) |
        (UInt64(bits[2]) << 2) |
        (UInt64(bits[3]) << 3) |
        (UInt64(bits[4]) << 4) |
        (UInt64(bits[5]) << 5) |
        (UInt64(bits[6]) << 6) |
        (UInt64(bits[7]) << 7) |

        (UInt64(bits[8]) << 8) |
        (UInt64(bits[9]) << 9) |
        (UInt64(bits[10]) << 10) |
        (UInt64(bits[11]) << 11) |
        (UInt64(bits[12]) << 12) |
        (UInt64(bits[13]) << 13) |
        (UInt64(bits[14]) << 14) |
        (UInt64(bits[15]) << 15) |

        (UInt64(bits[16]) << 16) |
        (UInt64(bits[17]) << 17) |
        (UInt64(bits[18]) << 18) |
        (UInt64(bits[19]) << 19) |
        (UInt64(bits[20]) << 20) |
        (UInt64(bits[21]) << 21) |
        (UInt64(bits[22]) << 22) |
        (UInt64(bits[23]) << 23) |

        (UInt64(bits[24]) << 24) |
        (UInt64(bits[25]) << 25) |
        (UInt64(bits[26]) << 26) |
        (UInt64(bits[27]) << 27) |
        (UInt64(bits[28]) << 28) |
        (UInt64(bits[29]) << 29) |
        (UInt64(bits[30]) << 30) |
        (UInt64(bits[31]) << 31) |

        (UInt64(bits[32]) << 32) |
        (UInt64(bits[33]) << 33) |
        (UInt64(bits[34]) << 34) |
        (UInt64(bits[35]) << 35) |
        (UInt64(bits[36]) << 36) |
        (UInt64(bits[37]) << 37) |
        (UInt64(bits[38]) << 38) |
        (UInt64(bits[39]) << 39) |

        (UInt64(bits[40]) << 40) |
        (UInt64(bits[41]) << 41) |
        (UInt64(bits[42]) << 42) |
        (UInt64(bits[43]) << 43) |
        (UInt64(bits[44]) << 44) |
        (UInt64(bits[45]) << 45) |
        (UInt64(bits[46]) << 46) |
        (UInt64(bits[47]) << 47) |

        (UInt64(bits[48]) << 48) |
        (UInt64(bits[49]) << 49) |
        (UInt64(bits[50]) << 50) |
        (UInt64(bits[51]) << 51) |
        (UInt64(bits[52]) << 52) |
        (UInt64(bits[53]) << 53) |
        (UInt64(bits[54]) << 54) |
        (UInt64(bits[55]) << 55) |

        (UInt64(bits[56]) << 56) |
        (UInt64(bits[57]) << 57) |
        (UInt64(bits[58]) << 58) |
        (UInt64(bits[59]) << 59) |
        (UInt64(bits[60]) << 60) |
        (UInt64(bits[61]) << 61) |
        (UInt64(bits[62]) << 62) |
        (UInt64(bits[63]) << 63)
    )


def BenchmarkV2(input_board: SIMD[DType.uint8,64]) -> UInt64:

    var board = input_board

    var checksum: UInt64 = 0

    var start = perf_counter_ns()


    for i in range(Iterations):

        board[Int(i & 63)] ^= UInt8(1)

        var attacks = WhiteBishopLeftAttacks(board)

        checksum += PackMask_V2(attacks)


    var end = perf_counter_ns()


    print("V2 checksum:")
    print(checksum)


    return UInt64(end-start)





def BenchmarkV3(input_board: SIMD[DType.uint8,64]) -> UInt64:

    var board = input_board

    var checksum: UInt64 = 0

    var start = perf_counter_ns()


    for i in range(Iterations):

        board[Int(i & 63)] ^= UInt8(1)

        var attacks = WhiteBishopLeftAttacks(board)

        checksum += PackMask_V3(attacks)


    var end = perf_counter_ns()


    print("V3 checksum:")
    print(checksum)


    return UInt64(end-start)
def main():

    print("==============================")
    print(" REAL CHESS ENGINE BENCHMARK ")
    print(" Bishop Attack + PackMask")
    print("==============================")

    var board = DynamicBoardContainer()

    var testBoardV2 = board.DynamicBoard
    var testBoardV3 = board.DynamicBoard


    var t2 = BenchmarkV2(testBoardV2)

    var t3 = BenchmarkV3(testBoardV3)



    print("")
    print("==============================")
    print("RESULT")
    print("==============================")


    print("V2 ns:")
    print(t2)


    print("V3 ns:")
    print(t3)


    print("ratio V2/V3:")

    print(Float64(t2)/Float64(t3))