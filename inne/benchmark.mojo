from std.time import perf_counter_ns


comptime Iterations = 10_000_000


# ============================================================
# V1 - zwykła pętla runtime
# ============================================================

@always_inline
def PackMask_V1(mask: SIMD[DType.uint8,64]) -> UInt64:

    var result: UInt64 = 0

    for i in range(64):
        result |= (UInt64(mask[i]) & 1) << UInt64(i)

    return result



# ============================================================
# V2 - comptime unroll 8x8
# ============================================================



# ============================================================
# Generator masek
# ============================================================

def GenerateMask(seed:Int) -> SIMD[DType.uint8,64]:

    var mask = SIMD[DType.uint8,64](0)


    for i in range(64):

        if ((i + seed) % 3) == 0:
            mask[i] = 1

        elif ((i * seed) % 7) == 0:
            mask[i] = 1


    return mask



# ============================================================
# Benchmark helper
# ============================================================


def RunBenchmark(
    name:String,
    version:Int,
    mask:SIMD[DType.uint8,64],
    dynamic:Bool
) -> UInt64:


    var checksum:UInt64 = 0


    var start = perf_counter_ns()


    for i in range(Iterations):


        var local_mask = mask


        if dynamic:

            var idx = Int(i & 63)

            local_mask[idx] = local_mask[idx] ^ UInt8(1)



        if version == 1:

            checksum ^= PackMask_V1(local_mask)


        elif version == 2:

            checksum ^= PackMask_V2(local_mask)


        else:

            checksum ^= PackMask_V3(local_mask)



    var end = perf_counter_ns()



    var total:UInt64 = UInt64(end-start)

    var avg:UInt64 = total / UInt64(Iterations)



    print("")
    print("==============================")
    print(name)
    print("==============================")

    print("time ns:", total)

    print("ns/op:", avg)

    print("checksum:", checksum)



    return total



# ============================================================
# Main
# ============================================================


def main():


    print("==============================")
    print(" PACKMASK BENCHMARK MOJO")
    print("==============================")

    print("Iterations:", Iterations)



    var masks = SIMD[DType.uint8,64](0)



    # kilka różnych masek

    var mask1 = GenerateMask(1)
    var mask2 = GenerateMask(17)
    var mask3 = GenerateMask(31)



    print("")
    print("========== STATIC MASK TEST ==========")



    var a1 = RunBenchmark(
        "V1 static",
        1,
        mask1,
        False
    )


    var a2 = RunBenchmark(
        "V2 static",
        2,
        mask2,
        False
    )


    var a3 = RunBenchmark(
        "V3 static",
        3,
        mask3,
        False
    )



    print("")
    print("========== DYNAMIC MASK TEST ==========")



    var b1 = RunBenchmark(
        "V1 dynamic",
        1,
        mask1,
        True
    )


    var b2 = RunBenchmark(
        "V2 dynamic",
        2,
        mask2,
        True
    )


    var b3 = RunBenchmark(
        "V3 dynamic",
        3,
        mask3,
        True
    )



    print("")
    print("==============================")
    print(" SPEEDUP")
    print("==============================")


    print("Static V2/V1:")
    print(Float64(a1) / Float64(a2))


    print("Static V3/V1:")
    print(Float64(a1) / Float64(a3))


    print("Dynamic V2/V1:")
    print(Float64(b1) / Float64(b2))


    print("Dynamic V3/V1:")
    print(Float64(b1) / Float64(b3))



    print("")
    print("==============================")
    print(" BIG-O")
    print("==============================")


    print("V1:")
    print("O(64)")
    print("runtime loop")


    print("")

    print("V2:")
    print("O(64)")
    print("comptime unrolled")


    print("")

    print("V3:")
    print("O(64)")
    print("fully expanded operations")