from .constants import *
from .Helpers import *
from std.bit import count_trailing_zeros
from std.collections import InlineArray

@always_inline
def QueenAttacksTemplate[PieceID: UInt8](board: SIMD[DType.uint8,64],occupancy: UInt64) -> Tuple[UInt64, Int]:

    var queen_mask = board.eq(PieceID)
    var queen_bitmask = queen_mask.cast[DType.uint8]()

    var packed = PackMask(queen_bitmask)

    if packed == 0:
        return UInt64(0), Int(-1)

    var index = Int(count_trailing_zeros(packed))

    var queen_bit = UInt64(1) << UInt64(index)

    var final_attacks_bitboard = (
    HyperbolaAttacks(occupancy, queen_bit, BISHOP_DIAGONALS[index]) |
    HyperbolaAttacks(occupancy, queen_bit, BISHOP_ANTIDIAGONALS[index]) |
    HyperbolaAttacks(occupancy, queen_bit, ROOK_FILES[index]) |
    HyperbolaAttacks(occupancy, queen_bit, ROOK_RANKS[index])
)
    return final_attacks_bitboard,index


@always_inline
def BishopAttacksTemplate[PieceID: UInt8](board: SIMD[DType.uint8, 64],occupancy: UInt64) -> Tuple[UInt64, Int]:


    var bishop_mask = board.eq(PieceID)
    var bishop_bitmask = bishop_mask.cast[DType.uint8]()

    var packed = PackMask(bishop_bitmask)

    if packed == 0:
        return UInt64(0), Int(-1)

    var index = Int(count_trailing_zeros(packed))

    var bishop_bit = UInt64(1) << UInt64(index)

    var attacks1 = HyperbolaAttacks(occupancy,bishop_bit,BISHOP_DIAGONALS[index])

    var attacks2 = HyperbolaAttacks(occupancy,bishop_bit,BISHOP_ANTIDIAGONALS[index])


    var final_attacks_bitboard = attacks1 | attacks2

    return final_attacks_bitboard,index




@always_inline
def RookAttacksTemplate[PieceID: UInt8](board: SIMD[DType.uint8, 64],occupancy: UInt64) -> Tuple[UInt64, Int]:

   
    var rook_mask = board.eq(PieceID)
    var rook_bitmask = rook_mask.cast[DType.uint8]()

    var packed = PackMask(rook_bitmask)

    if packed == 0:
        return UInt64(0), Int(-1)

    var index = Int(count_trailing_zeros(packed))


    var rook_bit = UInt64(1) << UInt64(index)

    var attacks1 = HyperbolaAttacks(occupancy,rook_bit,ROOK_FILES[index])

    var attacks2 = HyperbolaAttacks(occupancy,rook_bit,ROOK_RANKS[index])


    var final_attacks_bitboard = attacks1 | attacks2

    return final_attacks_bitboard,index

@always_inline
def KnightAttacksTemplate[PieceID: UInt8](board: SIMD[DType.uint8, 64]) -> Tuple[UInt64, Int]:


    var knight_mask = board.eq(PieceID)
    var knight_bitmask = knight_mask.cast[DType.uint8]()

    var packed = PackMask(knight_bitmask)

    if packed == 0:
        return UInt64(0), Int(-1)

    var index = Int(count_trailing_zeros(packed))


    var final_attacks_bitboard = KNIGHT_ATTACKS[index]

    return final_attacks_bitboard,index

@always_inline
def KingAttacksTemplate[PieceID: UInt8](board: SIMD[DType.uint8, 64]) -> Tuple[UInt64, Int]:
    var king_mask = board.eq(PieceID)
    var king_bitmask = king_mask.cast[DType.uint8]()
    var packed = PackMask(king_bitmask)

    if packed == 0:
        return UInt64(0), Int(-1)

    var index = Int(count_trailing_zeros(packed))
    var attacks_bitboard = KING_ATTACKS[index]

    return attacks_bitboard,index

@always_inline
def PawnGeometry[PieceID: UInt8](board: SIMD[DType.uint8, 64],ref table: InlineArray[PawnData, 48]) -> Tuple[InlineArray[PawnData, 8], InlineArray[Int, 8], Int]:

    var result_data = InlineArray[PawnData, 8](fill=PawnData())
    var result_squares = InlineArray[Int, 8](fill=0)
    var packed = PackMask(board.eq(PieceID).cast[DType.uint8]())
    var count = 0

    while packed != 0:
        var square = Int(count_trailing_zeros(packed))
        var index = square - 8

        result_data[count] = table[index].copy()
        result_squares[count] = square          # ← indeks pola

        count += 1
        packed &= packed - UInt64(1)

    return result_data^, result_squares^, count

#Bishop
#-----------------------------------------------------------------------------------------------#
def BlackBishopLeftAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return BishopAttacksTemplate[0x3E](board,occupancy)

def BlackBishopRightAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return BishopAttacksTemplate[0x2C](board,occupancy)

def WhiteBishopLeftAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return BishopAttacksTemplate[0x38](board,occupancy)

def WhiteBishopRightAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return BishopAttacksTemplate[0x26](board,occupancy)

#------------------------------------------------------------------------------------------------#

#Rook
#------------------------------------------------------------------------------------------------#
def WhiteRookLeftAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return RookAttacksTemplate[0x5C](board,occupancy)

def WhiteRookRightAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return RookAttacksTemplate[0x4A](board,occupancy)

def BlackRookLeftAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return RookAttacksTemplate[0x56](board,occupancy)

def BlackRookRightAttacks(board: SIMD[DType.uint8, BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return RookAttacksTemplate[0x44](board,occupancy)

#---------------------------------------------------------------------------------------------------#

#Queen
#------------------------------------------------------------------------------------------------#
def WhiteQueen(board: SIMD[DType.uint8,BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return QueenAttacksTemplate[0x6E](board,occupancy)

def BlackQueen(board: SIMD[DType.uint8,BoardSize],occupancy: UInt64) -> Tuple[UInt64, Int]:
    return QueenAttacksTemplate[0x68](board,occupancy)
#------------------------------------------------------------------------------------------------#

#Knight
#------------------------------------------------------------------------------------------------#
def WhiteLeftKnight(board: SIMD[DType.uint8, BoardSize]) -> Tuple[UInt64, Int]:
    return KnightAttacksTemplate[0x14](board)

def WhiteRightKnight(board: SIMD[DType.uint8, BoardSize]) -> Tuple[UInt64, Int]:
    return KnightAttacksTemplate[0x02](board)

def BlackLeftKnight(board: SIMD[DType.uint8, BoardSize]) -> Tuple[UInt64, Int]:
    return KnightAttacksTemplate[0x1A](board)

def BlackRightKnight(board: SIMD[DType.uint8, BoardSize]) -> Tuple[UInt64, Int]:
    return KnightAttacksTemplate[0x08](board)
#------------------------------------------------------------------------------------------------#

#King
#------------------------------------------------------------------------------------------------#
def WhiteKing(board: SIMD[DType.uint8,BoardSize]) -> Tuple[UInt64, Int]:
    return KingAttacksTemplate[0x80](board)

def BlackKing(board: SIMD[DType.uint8,BoardSize]) -> Tuple[UInt64, Int]:
    return KingAttacksTemplate[0x7A](board)
#------------------------------------------------------------------------------------------------#

