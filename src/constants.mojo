from std.collections import InlineArray

comptime BoardSize: Int = 64
comptime Wfield: UInt8 = 1  
comptime Bfield: UInt8 = 0  

comptime QUIET: UInt8   = 137
comptime CAPTURE: UInt8 = 53
comptime DOUBLE_PUSH: UInt8 = 48

#ID Pieces
comptime WRookLeft = 0x5C
comptime WRookRight = 0x4A
comptime WBishopLeft = 0x38 
comptime WBishopRight = 0x26 
comptime WQueen = 0x6E
comptime WKing = 0x80 
comptime WKnightLeft = 0x14 
comptime WKnightRight = 0x02 

comptime BRookLeft = 0x56 
comptime BRookRight = 0x44 
comptime BBishopLeft = 0x3E 
comptime BBishopRight = 0x2C
comptime BQueen = 0x68  
comptime BKing =  0x7A  
comptime BKnightLeft = 0x1A 
comptime BKnightRight = 0x08 

comptime WPawn = 0x32
comptime BPawn = 0x36

comptime notFileA   = UInt64(0xFEFEFEFEFEFEFEFE)
comptime notFileAB  = UInt64(0xFCFCFCFCFCFCFCFC)
comptime notFileGH  = UInt64(0x3F3F3F3F3F3F3F3F)
comptime notFileH   = UInt64(0x7F7F7F7F7F7F7F7F)




def _generate_diagonal_mask(index: Int) -> UInt64:
    var mask: UInt64 = 0

    var r = index // 8
    var f = index % 8

    for i in range(64):
        if (i // 8 - i % 8) == (r - f):
            mask |= UInt64(1) << UInt64(i)

    return mask


def _generate_antidiag_mask(index: Int) -> UInt64:
    var mask: UInt64 = 0

    var r = index // 8
    var f = index % 8

    for i in range(64):
        if (i // 8 + i % 8) == (r + f):
            mask |= UInt64(1) << UInt64(i)

    return mask


def _generate_rank_mask(index: Int) -> UInt64:

    var mask: UInt64 = 0

    var rank = index // 8

    for i in range(64):

        if (i // 8) == rank:
            mask |= UInt64(1) << UInt64(i)

    return mask



def _generate_file_mask(index: Int) -> UInt64:

    var mask: UInt64 = 0

    var file = index % 8

    for i in range(64):

        if (i % 8) == file:
            mask |= UInt64(1) << UInt64(i)

    return mask

@always_inline
def _generate_pawn_data(square: Int, direction: Int,double_move_rank: Int,en_passant_rank: Int) -> PawnData:
    var rank = square // 8
    var file = square % 8

    var move_one: UInt64 = 0
    var move_two: UInt64 = 0
    var capture_left: UInt64 = 0
    var capture_right: UInt64 = 0
    var ep_left: UInt64 = 0
    var ep_right: UInt64 = 0

    # Ruch o jedno pole
    var target_rank = rank + direction
    if 0 <= target_rank <= 7:
        move_one = SetBit(Square(target_rank, file))

    # Ruch o dwa pola (tylko z pozycji startowej)
    if rank == double_move_rank:
        var double_target = rank + direction * 2
        move_two = SetBit(Square(double_target, file))

    # Bicie w lewo
    if 0 <= target_rank <= 7 and file > 0:
        capture_left = SetBit(Square(target_rank, file - 1))

    # Bicie w prawo
    if 0 <= target_rank <= 7 and file < 7:
        capture_right = SetBit(Square(target_rank, file + 1))

    # En passant (tylko z odpowiedniego ranku)
    if rank == en_passant_rank:
        if file > 0:
            ep_left = SetBit(Square(target_rank, file - 1))
        if file < 7:
            ep_right = SetBit(Square(target_rank, file + 1))

    return PawnData(
        move_one,
        move_two,
        capture_left,
        capture_right,
        ep_left,
        ep_right
    )




@always_inline
def _generate_white_pawn_data(square: Int) -> PawnData:
    return _generate_pawn_data(
        square = square,
        direction = -1,
        double_move_rank = 6,
        en_passant_rank = 3
    )


@always_inline
def _generate_black_pawn_data(square: Int) -> PawnData:
    return _generate_pawn_data(
        square = square,
        direction = 1,
        double_move_rank = 1,
        en_passant_rank = 4
    )


@always_inline
def _generate_king_mask(square: Int) -> UInt64:
    var bb = UInt64(1) << UInt64(square)
    var attacks = UInt64(0)

    # pion
    attacks |= bb << 8
    attacks |= bb >> 8

    # poziom
    attacks |= (bb << 1) & notFileA
    attacks |= (bb >> 1) & notFileH

    # przekątne
    attacks |= (bb << 9) & notFileA
    attacks |= (bb << 7) & notFileH
    attacks |= (bb >> 7) & notFileA
    attacks |= (bb >> 9) & notFileH

    return attacks


@always_inline
def _KnightAttacksBitboard(square: Int) -> UInt64:

    var knight = UInt64(1) << UInt64(square)
    var attacks = UInt64(0)
    # góra
    attacks |= (knight << 17) & notFileA
    attacks |= (knight << 15) & notFileH
    attacks |= (knight << 10) & notFileAB
    attacks |= (knight << 6)  & notFileGH

    # dół
    attacks |= (knight >> 17) & notFileH
    attacks |= (knight >> 15) & notFileA
    attacks |= (knight >> 10) & notFileGH
    attacks |= (knight >> 6)  & notFileAB

    return attacks



comptime BISHOP_DIAGONALS = SIMD[DType.uint64, 64](
    _generate_diagonal_mask(0),  _generate_diagonal_mask(1),  _generate_diagonal_mask(2),  _generate_diagonal_mask(3),
    _generate_diagonal_mask(4),  _generate_diagonal_mask(5),  _generate_diagonal_mask(6),  _generate_diagonal_mask(7),
    _generate_diagonal_mask(8),  _generate_diagonal_mask(9),  _generate_diagonal_mask(10), _generate_diagonal_mask(11),
    _generate_diagonal_mask(12), _generate_diagonal_mask(13), _generate_diagonal_mask(14), _generate_diagonal_mask(15),
    _generate_diagonal_mask(16), _generate_diagonal_mask(17), _generate_diagonal_mask(18), _generate_diagonal_mask(19),
    _generate_diagonal_mask(20), _generate_diagonal_mask(21), _generate_diagonal_mask(22), _generate_diagonal_mask(23),
    _generate_diagonal_mask(24), _generate_diagonal_mask(25), _generate_diagonal_mask(26), _generate_diagonal_mask(27),
    _generate_diagonal_mask(28), _generate_diagonal_mask(29), _generate_diagonal_mask(30), _generate_diagonal_mask(31),
    _generate_diagonal_mask(32), _generate_diagonal_mask(33), _generate_diagonal_mask(34), _generate_diagonal_mask(35),
    _generate_diagonal_mask(36), _generate_diagonal_mask(37), _generate_diagonal_mask(38), _generate_diagonal_mask(39),
    _generate_diagonal_mask(40), _generate_diagonal_mask(41), _generate_diagonal_mask(42), _generate_diagonal_mask(43),
    _generate_diagonal_mask(44), _generate_diagonal_mask(45), _generate_diagonal_mask(46), _generate_diagonal_mask(47),
    _generate_diagonal_mask(48), _generate_diagonal_mask(49), _generate_diagonal_mask(50), _generate_diagonal_mask(51),
    _generate_diagonal_mask(52), _generate_diagonal_mask(53), _generate_diagonal_mask(54), _generate_diagonal_mask(55),
    _generate_diagonal_mask(56), _generate_diagonal_mask(57), _generate_diagonal_mask(58), _generate_diagonal_mask(59),
    _generate_diagonal_mask(60), _generate_diagonal_mask(61), _generate_diagonal_mask(62), _generate_diagonal_mask(63)
)

comptime BISHOP_ANTIDIAGONALS = SIMD[DType.uint64,64](
    _generate_antidiag_mask(0),  _generate_antidiag_mask(1),  _generate_antidiag_mask(2),  _generate_antidiag_mask(3),
    _generate_antidiag_mask(4),  _generate_antidiag_mask(5),  _generate_antidiag_mask(6),  _generate_antidiag_mask(7),            
    _generate_antidiag_mask(8),  _generate_antidiag_mask(9),  _generate_antidiag_mask(10), _generate_antidiag_mask(11),
    _generate_antidiag_mask(12), _generate_antidiag_mask(13), _generate_antidiag_mask(14), _generate_antidiag_mask(15),
    _generate_antidiag_mask(16), _generate_antidiag_mask(17), _generate_antidiag_mask(18), _generate_antidiag_mask(19),
    _generate_antidiag_mask(20), _generate_antidiag_mask(21), _generate_antidiag_mask(22), _generate_antidiag_mask(23),
    _generate_antidiag_mask(24), _generate_antidiag_mask(25), _generate_antidiag_mask(26), _generate_antidiag_mask(27),
    _generate_antidiag_mask(28),  _generate_antidiag_mask(29),  _generate_antidiag_mask(30),  _generate_antidiag_mask(31),
    _generate_antidiag_mask(32),  _generate_antidiag_mask(33),  _generate_antidiag_mask(34),  _generate_antidiag_mask(35),           
    _generate_antidiag_mask(36),  _generate_antidiag_mask(37),  _generate_antidiag_mask(38), _generate_antidiag_mask(39),
    _generate_antidiag_mask(40), _generate_antidiag_mask(41), _generate_antidiag_mask(42), _generate_antidiag_mask(43),
    _generate_antidiag_mask(44), _generate_antidiag_mask(45), _generate_antidiag_mask(46), _generate_antidiag_mask(47),
    _generate_antidiag_mask(48), _generate_antidiag_mask(49), _generate_antidiag_mask(50), _generate_antidiag_mask(51),
    _generate_antidiag_mask(52), _generate_antidiag_mask(53), _generate_antidiag_mask(54), _generate_antidiag_mask(55),
    _generate_antidiag_mask(56), _generate_antidiag_mask(57), _generate_antidiag_mask(58), _generate_antidiag_mask(59),
    _generate_antidiag_mask(60), _generate_antidiag_mask(61), _generate_antidiag_mask(62), _generate_antidiag_mask(63),
)


comptime ROOK_RANKS = SIMD[DType.uint64,64](
    _generate_rank_mask(0),  _generate_rank_mask(1),  _generate_rank_mask(2),  _generate_rank_mask(3),
    _generate_rank_mask(4),  _generate_rank_mask(5),  _generate_rank_mask(6),  _generate_rank_mask(7),
    _generate_rank_mask(8),  _generate_rank_mask(9),  _generate_rank_mask(10),  _generate_rank_mask(11),
    _generate_rank_mask(12),  _generate_rank_mask(13),  _generate_rank_mask(14),  _generate_rank_mask(15),
    _generate_rank_mask(16),  _generate_rank_mask(17),  _generate_rank_mask(18),  _generate_rank_mask(19),
    _generate_rank_mask(20),  _generate_rank_mask(21),  _generate_rank_mask(22),  _generate_rank_mask(23),
    _generate_rank_mask(24),  _generate_rank_mask(25),  _generate_rank_mask(26),  _generate_rank_mask(27),
    _generate_rank_mask(28),  _generate_rank_mask(29),  _generate_rank_mask(30),  _generate_rank_mask(31),
    _generate_rank_mask(32),  _generate_rank_mask(33),  _generate_rank_mask(34),  _generate_rank_mask(35),
    _generate_rank_mask(36),  _generate_rank_mask(37),  _generate_rank_mask(38),  _generate_rank_mask(39),
    _generate_rank_mask(40),  _generate_rank_mask(41),  _generate_rank_mask(42),  _generate_rank_mask(43),
    _generate_rank_mask(44),  _generate_rank_mask(45),  _generate_rank_mask(46),  _generate_rank_mask(47),
    _generate_rank_mask(48),  _generate_rank_mask(49),  _generate_rank_mask(50),  _generate_rank_mask(51),
    _generate_rank_mask(52),  _generate_rank_mask(53),  _generate_rank_mask(54),  _generate_rank_mask(55),
    _generate_rank_mask(56),  _generate_rank_mask(57),  _generate_rank_mask(58),  _generate_rank_mask(59),
    _generate_rank_mask(60),  _generate_rank_mask(61),  _generate_rank_mask(62),  _generate_rank_mask(63)
)


comptime ROOK_FILES = SIMD[DType.uint64,64](
      _generate_file_mask(0),  _generate_file_mask(1),  _generate_file_mask(2),  _generate_file_mask(3),
      _generate_file_mask(4),  _generate_file_mask(5),  _generate_file_mask(6),  _generate_file_mask(7),
      _generate_file_mask(8),  _generate_file_mask(9),  _generate_file_mask(10),  _generate_file_mask(11),
      _generate_file_mask(12),  _generate_file_mask(13),  _generate_file_mask(14),  _generate_file_mask(15),
      _generate_file_mask(16),  _generate_file_mask(17),  _generate_file_mask(18),  _generate_file_mask(19),
      _generate_file_mask(20),  _generate_file_mask(21),  _generate_file_mask(22),  _generate_file_mask(23),
      _generate_file_mask(24),  _generate_file_mask(25),  _generate_file_mask(26),  _generate_file_mask(27),
      _generate_file_mask(28),  _generate_file_mask(29),  _generate_file_mask(30),  _generate_file_mask(31),
      _generate_file_mask(32),  _generate_file_mask(33),  _generate_file_mask(34),  _generate_file_mask(35),
      _generate_file_mask(36),  _generate_file_mask(37),  _generate_file_mask(38),  _generate_file_mask(39),
      _generate_file_mask(40),  _generate_file_mask(41),  _generate_file_mask(42),  _generate_file_mask(43),
      _generate_file_mask(44),  _generate_file_mask(45),  _generate_file_mask(46),  _generate_file_mask(47),
      _generate_file_mask(48),  _generate_file_mask(49),  _generate_file_mask(50),  _generate_file_mask(51),
      _generate_file_mask(52),  _generate_file_mask(53),  _generate_file_mask(54),  _generate_file_mask(55),
      _generate_file_mask(56),  _generate_file_mask(57),  _generate_file_mask(58),  _generate_file_mask(59),
      _generate_file_mask(60),  _generate_file_mask(61),  _generate_file_mask(62),  _generate_file_mask(63)
)

comptime KNIGHT_ATTACKS = SIMD[DType.uint64,64](
    _KnightAttacksBitboard(0),_KnightAttacksBitboard(1),_KnightAttacksBitboard(2),_KnightAttacksBitboard(3),
    _KnightAttacksBitboard(4),_KnightAttacksBitboard(5),_KnightAttacksBitboard(6),_KnightAttacksBitboard(7),
    _KnightAttacksBitboard(8),_KnightAttacksBitboard(9),_KnightAttacksBitboard(10),_KnightAttacksBitboard(11),
    _KnightAttacksBitboard(12),_KnightAttacksBitboard(13),_KnightAttacksBitboard(14),_KnightAttacksBitboard(15),
    _KnightAttacksBitboard(16),_KnightAttacksBitboard(17),_KnightAttacksBitboard(18),_KnightAttacksBitboard(19),
    _KnightAttacksBitboard(20),_KnightAttacksBitboard(21),_KnightAttacksBitboard(22),_KnightAttacksBitboard(23),
    _KnightAttacksBitboard(24),_KnightAttacksBitboard(25),_KnightAttacksBitboard(26),_KnightAttacksBitboard(27),
    _KnightAttacksBitboard(28),_KnightAttacksBitboard(29),_KnightAttacksBitboard(30),_KnightAttacksBitboard(31),
    _KnightAttacksBitboard(32),_KnightAttacksBitboard(33),_KnightAttacksBitboard(34),_KnightAttacksBitboard(35),
    _KnightAttacksBitboard(36),_KnightAttacksBitboard(37),_KnightAttacksBitboard(38),_KnightAttacksBitboard(39),
    _KnightAttacksBitboard(40),_KnightAttacksBitboard(41),_KnightAttacksBitboard(42),_KnightAttacksBitboard(43),
    _KnightAttacksBitboard(44),_KnightAttacksBitboard(45),_KnightAttacksBitboard(46),_KnightAttacksBitboard(47),
    _KnightAttacksBitboard(48),_KnightAttacksBitboard(49),_KnightAttacksBitboard(50),_KnightAttacksBitboard(51),
    _KnightAttacksBitboard(52),_KnightAttacksBitboard(53),_KnightAttacksBitboard(54),_KnightAttacksBitboard(55),
    _KnightAttacksBitboard(56),_KnightAttacksBitboard(57),_KnightAttacksBitboard(58),_KnightAttacksBitboard(59),
    _KnightAttacksBitboard(60),_KnightAttacksBitboard(61),_KnightAttacksBitboard(62),_KnightAttacksBitboard(63),
)



comptime KING_ATTACKS = SIMD[DType.uint64, 64](
    _generate_king_mask(0),  _generate_king_mask(1),  _generate_king_mask(2),  _generate_king_mask(3),
    _generate_king_mask(4),  _generate_king_mask(5),  _generate_king_mask(6),  _generate_king_mask(7),
    _generate_king_mask(8),  _generate_king_mask(9),  _generate_king_mask(10), _generate_king_mask(11),
    _generate_king_mask(12), _generate_king_mask(13), _generate_king_mask(14), _generate_king_mask(15),
    _generate_king_mask(16), _generate_king_mask(17), _generate_king_mask(18), _generate_king_mask(19),
    _generate_king_mask(20), _generate_king_mask(21), _generate_king_mask(22), _generate_king_mask(23),
    _generate_king_mask(24), _generate_king_mask(25), _generate_king_mask(26), _generate_king_mask(27),
    _generate_king_mask(28), _generate_king_mask(29), _generate_king_mask(30), _generate_king_mask(31),
    _generate_king_mask(32), _generate_king_mask(33), _generate_king_mask(34), _generate_king_mask(35),
    _generate_king_mask(36), _generate_king_mask(37), _generate_king_mask(38), _generate_king_mask(39),
    _generate_king_mask(40), _generate_king_mask(41), _generate_king_mask(42), _generate_king_mask(43),
    _generate_king_mask(44), _generate_king_mask(45), _generate_king_mask(46), _generate_king_mask(47),
    _generate_king_mask(48), _generate_king_mask(49), _generate_king_mask(50), _generate_king_mask(51),
    _generate_king_mask(52), _generate_king_mask(53), _generate_king_mask(54), _generate_king_mask(55),
    _generate_king_mask(56), _generate_king_mask(57), _generate_king_mask(58), _generate_king_mask(59),
    _generate_king_mask(60), _generate_king_mask(61), _generate_king_mask(62), _generate_king_mask(63),
)

comptime WHITE_PAWN_DATA = InlineArray[PawnData,48](
    _generate_white_pawn_data(8),_generate_white_pawn_data(9), _generate_white_pawn_data(10), _generate_white_pawn_data(11),
    _generate_white_pawn_data(12),_generate_white_pawn_data(13),_generate_white_pawn_data(14),_generate_white_pawn_data(15),
    _generate_white_pawn_data(16),_generate_white_pawn_data(17),_generate_white_pawn_data(18),_generate_white_pawn_data(19),
    _generate_white_pawn_data(20),_generate_white_pawn_data(21),_generate_white_pawn_data(22),_generate_white_pawn_data(23),
    _generate_white_pawn_data(24),_generate_white_pawn_data(25),_generate_white_pawn_data(26),_generate_white_pawn_data(27),
    _generate_white_pawn_data(28),_generate_white_pawn_data(29),_generate_white_pawn_data(30),_generate_white_pawn_data(31),
    _generate_white_pawn_data(32),_generate_white_pawn_data(33),_generate_white_pawn_data(34),_generate_white_pawn_data(35),
    _generate_white_pawn_data(36),_generate_white_pawn_data(37),_generate_white_pawn_data(38),_generate_white_pawn_data(39),
    _generate_white_pawn_data(40),_generate_white_pawn_data(41),_generate_white_pawn_data(42),_generate_white_pawn_data(43),
    _generate_white_pawn_data(44),_generate_white_pawn_data(45),_generate_white_pawn_data(46),_generate_white_pawn_data(47),
    _generate_white_pawn_data(48),_generate_white_pawn_data(49),_generate_white_pawn_data(50),_generate_white_pawn_data(51),
    _generate_white_pawn_data(52),_generate_white_pawn_data(53),_generate_white_pawn_data(54),_generate_white_pawn_data(55),
    __list_literal__ = None
)


comptime BLACK_PAWN_DATA = InlineArray[PawnData,48](
    _generate_black_pawn_data(8),_generate_black_pawn_data(9),_generate_black_pawn_data(10),_generate_black_pawn_data(11),
    _generate_black_pawn_data(12),_generate_black_pawn_data(13),_generate_black_pawn_data(14),_generate_black_pawn_data(15),
    _generate_black_pawn_data(16),_generate_black_pawn_data(17),_generate_black_pawn_data(18),_generate_black_pawn_data(19),
    _generate_black_pawn_data(20),_generate_black_pawn_data(21),_generate_black_pawn_data(22), _generate_black_pawn_data(23),
    _generate_black_pawn_data(24),_generate_black_pawn_data(25),_generate_black_pawn_data(26),_generate_black_pawn_data(27),
    _generate_black_pawn_data(28),_generate_black_pawn_data(29),_generate_black_pawn_data(30),_generate_black_pawn_data(31),
    _generate_black_pawn_data(32),_generate_black_pawn_data(33),_generate_black_pawn_data(34),_generate_black_pawn_data(35),
    _generate_black_pawn_data(36),_generate_black_pawn_data(37),_generate_black_pawn_data(38),_generate_black_pawn_data(39),
    _generate_black_pawn_data(40),_generate_black_pawn_data(41),_generate_black_pawn_data(42),_generate_black_pawn_data(43),
    _generate_black_pawn_data(44),_generate_black_pawn_data(45),_generate_black_pawn_data(46),_generate_black_pawn_data(47),
    _generate_black_pawn_data(48),_generate_black_pawn_data(49),_generate_black_pawn_data(50),_generate_black_pawn_data(51),
    _generate_black_pawn_data(52),_generate_black_pawn_data(53),_generate_black_pawn_data(54),_generate_black_pawn_data(55),
    __list_literal__ = None
)


@always_inline
def WhiteOccupancy(board: SIMD[DType.uint8,64]) -> UInt64:

    var result = SIMD[DType.bool,64](fill=False)

    result |= board.eq(WRookLeft)
    result |= board.eq(WRookRight)

    result |= board.eq(WBishopLeft)
    result |= board.eq(WBishopRight)

    result |= board.eq(WQueen)
    result |= board.eq(WKing)

    result |= board.eq(WKnightLeft)
    result |= board.eq(WKnightRight)

    result |= board.eq(WPawn)

    return PackMask(result.cast[DType.uint8]())

@always_inline
def BlackOccupancy(board: SIMD[DType.uint8,64]) -> UInt64:

    var result = SIMD[DType.bool,64](fill=False)

    result |= board.eq(BRookLeft)
    result |= board.eq(BRookRight)

    result |= board.eq(BBishopLeft)
    result |= board.eq(BBishopRight)

    result |= board.eq(BQueen)
    result |= board.eq(BKing)

    result |= board.eq(BKnightLeft)
    result |= board.eq(BKnightRight)

    result |= board.eq(BPawn)

    return PackMask(result.cast[DType.uint8]())

def UpdateOccupancy(Board: SIMD[DType.uint8,64]) -> UInt64:
    WhiteOccup = WhiteOccupancy(Board)
    BlackOccup = BlackOccupancy(Board)
    return WhiteOccup | BlackOccup

def UpdateWhiteOccup(Board: SIMD[DType.uint8,64]) -> UInt64:
    return WhiteOccupancy(Board)

def UpdateBlackOccup(Board: SIMD[DType.uint8,64]) -> UInt64:
    return BlackOccupancy(Board)


@always_inline
def QuietFilter(attacks: UInt64,own: UInt64) -> UInt64:
    return attacks & (~own)


@always_inline
def CaptureFilter(attacks: UInt64,enemy: UInt64) -> UInt64:
    return attacks & enemy


struct DynamicBoardContainer:
    var DynamicBoard: SIMD[DType.uint8, BoardSize]

    def __init__(out self):
        self.DynamicBoard = SIMD[DType.uint8, BoardSize](0)

        self.DynamicBoard[0] = BRookLeft
        self.DynamicBoard[1] = BKnightLeft
        self.DynamicBoard[2] = BBishopLeft
        self.DynamicBoard[3] = BQueen
        self.DynamicBoard[4] = BKing
        self.DynamicBoard[5] = BBishopRight
        self.DynamicBoard[6] = BKnightRight
        self.DynamicBoard[7] = BRookRight

        for i in range(8,16):
            self.DynamicBoard[i] = BPawn

        for i in range(48,56):
            self.DynamicBoard[i] = WPawn



        self.DynamicBoard[56] = WRookLeft
        self.DynamicBoard[57] = WKnightLeft
        self.DynamicBoard[58] = WBishopLeft
        self.DynamicBoard[59] = WQueen
        self.DynamicBoard[60] = WKing
        self.DynamicBoard[61] = WBishopRight
        self.DynamicBoard[62] = WKnightRight
        self.DynamicBoard[63] = WRookRight

struct PawnData(Copyable, Movable):
    var move_one: UInt64
    var move_two: UInt64
    var capture_left: UInt64
    var capture_right: UInt64
    var en_passant_left: UInt64
    var en_passant_right: UInt64

  
    def __init__(
        out self,
        move_one: UInt64 = 0,
        move_two: UInt64 = 0,
        capture_left: UInt64 = 0,
        capture_right: UInt64 = 0,
        en_passant_left: UInt64 = 0,
        en_passant_right: UInt64 = 0,
    ):
        self.move_one = move_one
        self.move_two = move_two
        self.capture_left = capture_left
        self.capture_right = capture_right
        self.en_passant_left = en_passant_left
        self.en_passant_right = en_passant_right


struct InitPawnTables:
    var WhitePawnTable: InlineArray[PawnData,48]
    var BlackPawnTable: InlineArray[PawnData,48]

    def __init__(out self):
        self.WhitePawnTable = materialize[WHITE_PAWN_DATA]()
        self.BlackPawnTable = materialize[BLACK_PAWN_DATA]()


struct Move(Movable):
    var From: UInt8
    var To: UInt8
    var Flags: UInt8

    def __init__(
        out self,
        From: UInt8,
        To: UInt8,
        Flags: UInt8
    ):
        self.From = From
        self.To = To
        self.Flags = Flags


struct MoveListWhite:
    var WhiteMoves: InlineArray[Move,128]

    def __init__(out self):
        self.WhiteMoves = InlineArray[Move,128](uninitialized=True)


struct MoveListBlack:
    var BlackMoves: InlineArray[Move,128]

    def __init__(out self):
        self.BlackMoves = InlineArray[Move,128](uninitialized=True)



struct GameState:
    var Board: SIMD[DType.uint8,64]

    var Occupancy: UInt64
    var WhiteOccup: UInt64
    var BlackOccup: UInt64

    var WhiteMoves: MoveListWhite
    var BlackMoves: MoveListBlack

    var WhiteCount: Int
    var BlackCount: Int

    def __init__(out self, board: SIMD[DType.uint8,64]):
        self.Board = board

        self.WhiteOccup = UpdateWhiteOccup(self.Board)
        self.BlackOccup = UpdateBlackOccup(self.Board)
        self.Occupancy = self.WhiteOccup | self.BlackOccup

        self.WhiteMoves = MoveListWhite()
        self.BlackMoves = MoveListBlack()

        self.WhiteCount = 0
        self.BlackCount = 0
