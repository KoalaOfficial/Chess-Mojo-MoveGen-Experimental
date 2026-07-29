@always_inline
def PackMask(mask: SIMD[DType.uint8, 64]) -> UInt64:
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
