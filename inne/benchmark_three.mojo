from std.time import perf_counter_ns


comptime Repeat = 5


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

        var byte: UInt64 = 0

        byte |= UInt64(chunk[0]) << 0
        byte |= UInt64(chunk[1]) << 1
        byte |= UInt64(chunk[2]) << 2
        byte |= UInt64(chunk[3]) << 3
        byte |= UInt64(chunk[4]) << 4
        byte |= UInt64(chunk[5]) << 5
        byte |= UInt64(chunk[6]) << 6
        byte |= UInt64(chunk[7]) << 7


        result |= byte << UInt64(block*8)


    return result



# ============================================================
# V3
# ręczne rozwinięcie
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



# ============================================================
# Generator
# ============================================================

def GenerateMask(seed:Int)->SIMD[DType.uint8,64]:

    var mask = SIMD[DType.uint8,64](0)


    for i in range(64):

        if ((i*seed+seed)%5)==0:
            mask[i]=1

        elif ((i+seed)%7)==0:
            mask[i]=1


    return mask



# ============================================================
# Benchmark V2
# ============================================================

def RunV2(mask_in: SIMD[DType.uint8,64], iterations: UInt64) -> UInt64:

    var mask = mask_in
    var checksum: UInt64 = 0

    var start = perf_counter_ns()


    for i in range(iterations):

        var index = Int(i & 63)

        mask[index] ^= UInt8(1)

        checksum ^= PackMask_V2(mask)


    var end = perf_counter_ns()


    print("checksum V2:", checksum)

    return UInt64(end-start)



def RunV3(mask_in: SIMD[DType.uint8,64], iterations: UInt64) -> UInt64:

    var mask = mask_in
    var checksum: UInt64 = 0

    var start = perf_counter_ns()


    for i in range(iterations):

        var index = Int(i & 63)

        mask[index] ^= UInt8(1)

        checksum ^= PackMask_V3(mask)


    var end = perf_counter_ns()


    print("checksum V3:", checksum)

    return UInt64(end-start)

# ============================================================
# Średnia
# ============================================================

def AverageV2(mask:SIMD[DType.uint8,64],n:UInt64)->UInt64:


    var total:UInt64=0


    for i in range(Repeat):

        total += RunV2(mask,n)


    return total / UInt64(Repeat)




def AverageV3(mask:SIMD[DType.uint8,64],n:UInt64)->UInt64:


    var total:UInt64=0


    for i in range(Repeat):

        total += RunV3(mask,n)


    return total / UInt64(Repeat)




# ============================================================
# Analiza matematyczna
# ============================================================

def Analyze(ratios:SIMD[DType.float64,8]):


    var minimum = ratios[0]
    var maximum = ratios[0]


    for i in range(8):

        if ratios[i] < minimum:
            minimum = ratios[i]


        if ratios[i] > maximum:
            maximum = ratios[i]



    print("")
    print("==============================")
    print("ASYMPTOTIC ANALYSIS")
    print("==============================")


    print("Minimum ratio:")
    print(minimum)


    print("Maximum ratio:")
    print(maximum)



    print("")
    print("BIG O")
    print("----------------")
    print("V2 = O(64)")
    print("V3 = O(64)")


    print("")
    print("BIG OMEGA")
    print("----------------")
    print("V2 = Omega(64)")
    print("V3 = Omega(64)")


    print("")
    print("BIG THETA")
    print("----------------")


    if maximum/minimum < 1.2:

        print("T2(n)=Theta(T3(n))")

    else:

        print("constant factor variation detected")



    print("")
    print("SMALL o")
    print("----------------")


    if maximum < 0.1:

        print("V2=o(V3)")

    elif minimum > 10:

        print("V3=o(V2)")

    else:

        print("No small-o relation")



    print("")
    print("SMALL omega")
    print("----------------")


    if maximum < 0.1:

        print("V3=omega(V2)")

    elif minimum > 10:

        print("V2=omega(V3)")

    else:

        print("No omega relation")



# ============================================================
# MAIN
# ============================================================

def main():


    print("==============================")
    print(" PACKMASK ASYMPTOTIC BENCHMARK")
    print(" V2 VS V3")
    print("==============================")


    var mask = GenerateMask(17)


    var sizes = SIMD[DType.uint64,8](
        1000,
        10000,
        100000,
        1000000,
        10000000,
        100000000,
        500000000,
        1000000000
    )


    var ratios = SIMD[DType.float64,8](0)


    print("")
    print("N        V2 ns/op        V3 ns/op        Ratio")


    for i in range(8):

        var n = sizes[i]


        var t2 = AverageV2(mask,n)

        var t3 = AverageV3(mask,n)



        var ns2 = Float64(t2) / Float64(n)

        var ns3 = Float64(t3) / Float64(n)


        var ratio = ns2 / ns3


        ratios[i]=ratio


        print(n)
        print(ns2)
        print(ns3)
        print(ratio)



    Analyze(ratios)