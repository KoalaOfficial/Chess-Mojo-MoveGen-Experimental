from std.time import perf_counter_ns


comptime Iterations = 5_000_000


# ============================================================
# V2
# comptime unroll
# ============================================================

@always_inline
def PackMask_V2(mask: SIMD[DType.uint8,64]) -> UInt64:

    var bits = mask & 1
    var result: UInt64 = 0


    comptime for block in range(8):

        var chunk = bits.slice[8, offset=block*8]()


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
# V3
# pełne ręczne rozwinięcie
# ============================================================

@always_inline
def PackMask_V3(mask: SIMD[DType.uint8,64]) -> UInt64:

    var bits = mask & 1

    var result: UInt64 = 0


    result |= UInt64(bits[0]) << 0
    result |= UInt64(bits[1]) << 1
    result |= UInt64(bits[2]) << 2
    result |= UInt64(bits[3]) << 3
    result |= UInt64(bits[4]) << 4
    result |= UInt64(bits[5]) << 5
    result |= UInt64(bits[6]) << 6
    result |= UInt64(bits[7]) << 7

    result |= UInt64(bits[8]) << 8
    result |= UInt64(bits[9]) << 9
    result |= UInt64(bits[10]) << 10
    result |= UInt64(bits[11]) << 11
    result |= UInt64(bits[12]) << 12
    result |= UInt64(bits[13]) << 13
    result |= UInt64(bits[14]) << 14
    result |= UInt64(bits[15]) << 15

    result |= UInt64(bits[16]) << 16
    result |= UInt64(bits[17]) << 17
    result |= UInt64(bits[18]) << 18
    result |= UInt64(bits[19]) << 19
    result |= UInt64(bits[20]) << 20
    result |= UInt64(bits[21]) << 21
    result |= UInt64(bits[22]) << 22
    result |= UInt64(bits[23]) << 23

    result |= UInt64(bits[24]) << 24
    result |= UInt64(bits[25]) << 25
    result |= UInt64(bits[26]) << 26
    result |= UInt64(bits[27]) << 27
    result |= UInt64(bits[28]) << 28
    result |= UInt64(bits[29]) << 29
    result |= UInt64(bits[30]) << 30
    result |= UInt64(bits[31]) << 31


    result |= UInt64(bits[32]) << 32
    result |= UInt64(bits[33]) << 33
    result |= UInt64(bits[34]) << 34
    result |= UInt64(bits[35]) << 35
    result |= UInt64(bits[36]) << 36
    result |= UInt64(bits[37]) << 37
    result |= UInt64(bits[38]) << 38
    result |= UInt64(bits[39]) << 39


    result |= UInt64(bits[40]) << 40
    result |= UInt64(bits[41]) << 41
    result |= UInt64(bits[42]) << 42
    result |= UInt64(bits[43]) << 43
    result |= UInt64(bits[44]) << 44
    result |= UInt64(bits[45]) << 45
    result |= UInt64(bits[46]) << 46
    result |= UInt64(bits[47]) << 47


    result |= UInt64(bits[48]) << 48
    result |= UInt64(bits[49]) << 49
    result |= UInt64(bits[50]) << 50
    result |= UInt64(bits[51]) << 51
    result |= UInt64(bits[52]) << 52
    result |= UInt64(bits[53]) << 53
    result |= UInt64(bits[54]) << 54
    result |= UInt64(bits[55]) << 55


    result |= UInt64(bits[56]) << 56
    result |= UInt64(bits[57]) << 57
    result |= UInt64(bits[58]) << 58
    result |= UInt64(bits[59]) << 59
    result |= UInt64(bits[60]) << 60
    result |= UInt64(bits[61]) << 61
    result |= UInt64(bits[62]) << 62
    result |= UInt64(bits[63]) << 63


    return result



# ============================================================
# generator masek
# ============================================================

def GenerateMask(seed:Int) -> SIMD[DType.uint8,64]:

    var mask = SIMD[DType.uint8,64](0)


    for i in range(64):

        if ((i*seed + seed) % 5) == 0:
            mask[i]=1

        elif ((i+seed)%7)==0:
            mask[i]=1


    return mask



# ============================================================
# benchmark
# ============================================================

def RunV2(mask:SIMD[DType.uint8,64]) -> UInt64:

    var checksum:UInt64 = 0


    var start = perf_counter_ns()


    for i in range(Iterations):

        var m = mask

        m[Int(i & 63)] ^= UInt8(1)

        checksum += PackMask_V2(m)


    var end = perf_counter_ns()


    var total:UInt64 = UInt64(end-start)


    print("V2 time ns:", total)
    print("V2 ns/op:", total / UInt64(Iterations))
    print("checksum:", checksum)


    return total



def RunV3(mask:SIMD[DType.uint8,64]) -> UInt64:

    var checksum:UInt64 = 0


    var start = perf_counter_ns()


    for i in range(Iterations):

        var m = mask

        m[Int(i & 63)] ^= UInt8(1)

        checksum += PackMask_V3(m)


    var end = perf_counter_ns()


    var total:UInt64 = UInt64(end-start)


    print("V3 time ns:", total)
    print("V3 ns/op:", total / UInt64(Iterations))
    print("checksum:", checksum)


    return total

# ============================================================
# ANALIZA MATEMATYCZNA
# ============================================================

def Analyze(t2: UInt64, t3: UInt64):


    var v2 = Float64(t2)
    var v3 = Float64(t3)


    var ratio = v2 / v3


    print("")
    print("==============================")
    print("MATHEMATICAL ANALYSIS")
    print("==============================")


    print("")
    print("V2 time:")
    print(v2)

    print("V3 time:")
    print(v3)


    print("")
    print("T(V2) / T(V3):")
    print(ratio)



    print("")
    print("ASYMPTOTIC COMPLEXITY")
    print("------------------------------")


    print("")
    print("V2:")
    print("O(64)")
    print("Omega(64)")
    print("Theta(64)")


    print("")
    print("V3:")
    print("O(64)")
    print("Omega(64)")
    print("Theta(64)")



    print("")
    print("COMPARISON")
    print("------------------------------")


    if ratio > 1.0:

        print("V3 faster")

    elif ratio < 1.0:

        print("V2 faster")

    else:

        print("equal")



    print("")
    print("SMALL o ANALYSIS")
    print("------------------------------")


    if ratio < 0.5:

        print("V2 = o(V3) candidate")

    elif ratio > 2.0:

        print("V3 = o(V2) candidate")

    else:

        print("No small-o relation observed")



    print("")
    print("SMALL omega ANALYSIS")
    print("------------------------------")


    if ratio > 2.0:

        print("V2 = omega(V3) candidate")

    elif ratio < 0.5:

        print("V3 = omega(V2) candidate")

    else:

        print("No omega relation observed")



    print("")
    print("THETA RELATION")
    print("------------------------------")


    if ratio >= 0.5 and ratio <= 2.0:

        print("V2 = Theta(V3)")
        print("Same asymptotic class")

    else:

        print("Different practical constant factor")

def main():

    print("==============================")
    print(" PACKMASK V2 VS V3 BENCHMARK ")
    print("==============================")


    var mask1 = GenerateMask(1)
    var mask2 = GenerateMask(17)
    var mask3 = GenerateMask(31)


    var v2_1 = RunV2(mask1)
    var v3_1 = RunV3(mask1)

    Analyze(v2_1,v3_1)



    var v2_2 = RunV2(mask2)
    var v3_2 = RunV3(mask2)

    Analyze(v2_2,v3_2)



    var v2_3 = RunV2(mask3)
    var v3_3 = RunV3(mask3)

    Analyze(v2_3,v3_3)