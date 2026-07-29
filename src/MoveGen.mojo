from src.constants import *
from src.Attacks import *

def PushMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    from_sq: UInt8,
    targets: UInt64,
    flags: UInt8
):

    var bits = targets

    while bits != 0:

        var to = UInt8(count_trailing_zeros(bits))

        roll[count_move] = Move(
            From=from_sq,
            To=to,
            Flags=flags
        )

        count_move += 1

        bits &= bits - 1

@always_inline
def PushPawnMove(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    pawn: PawnData,
    occupancy: UInt64,
    enemyOcc: UInt64,
    from_sq: UInt8
):

    # ======================
    # QUIET MOVE
    # ======================

    var quiet = pawn.move_one & ~occupancy

    if quiet != 0:

        roll[count_move] = Move(
            From=from_sq,
            To=UInt8(count_trailing_zeros(quiet)),
            Flags=QUIET
        )

        count_move += 1


    # ======================
    # DOUBLE PUSH
    # ======================

    if quiet != 0:

        var double =
            pawn.move_two & ~occupancy

        if double != 0:

            roll[count_move] = Move(
                From=from_sq,
                To=UInt8(count_trailing_zeros(double)),
                Flags=DOUBLE_PUSH
            )

            count_move += 1


    # ======================
    # CAPTURE LEFT
    # ======================

    var left =
        pawn.capture_left &
        enemyOcc

    if left != 0:

        roll[count_move] = Move(
            From=from_sq,
            To=UInt8(count_trailing_zeros(left)),
            Flags=CAPTURE
        )

        count_move += 1


    # ======================
    # CAPTURE RIGHT
    # ======================

    var right =
        pawn.capture_right &
        enemyOcc

    if right != 0:

        roll[count_move] = Move(
            From=from_sq,
            To=UInt8(count_trailing_zeros(right)),
            Flags=CAPTURE
        )

        count_move += 1

def WhitePiecesMovesGen(
    mut roll: InlineArray[Move,128],
    mut  count_move: Int,
    whiteOcc: UInt64,
    blackOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64],
    ref pawnTabl: InlineArray[PawnData,48]
):

    WhiteRookLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    WhiteRookRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )

    WhiteBishopLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    WhiteBishopRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    WhiteQueenMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    WhiteKnightLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    WhiteKnightRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    WhiteKingMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    WhitePawnMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board,
        pawnTabl

)


def BlackPiecesMovesGen(
    mut  roll: InlineArray[Move,128],
    mut count_move: Int,
    whiteOcc: UInt64,
    blackOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64],
    ref pawnTabl: InlineArray[PawnData,48]
):
    BlackRookLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    BlackRookRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    BlackBishopLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    BlackBishopRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    BlackQueenMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board
    )
    BlackKnightLeftMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    BlackKnightRightMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    BlackKingMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        board
    )
    BlackPawnMoves(
        roll,
        count_move,
        blackOcc,
        whiteOcc,
        occupancy,
        board,
        pawnTabl
    )


def WhitePawnMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64],
    ref pawnTabl: InlineArray[PawnData,48]

):

    var result = PawnGeometry[WPawn](board, pawnTabl)

    ref pawnData = result[0]
    ref squares = result[1]
    var count = result[2]

    for i in range(count):

        ref pawn = pawnData[i]

        PushPawnMove(
            roll,
            count_move,
            pawn,
            occupancy,
            blackOcc,
            UInt8(squares[i])
    )

def BlackPawnMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64],
    ref pawnTabl: InlineArray[PawnData,48]

):
    var result = PawnGeometry[BPawn](board, pawnTabl)

    ref pawnData = result[0]
    ref squares = result[1]
    var count = result[2]

    for i in range(count):

        ref pawn = pawnData[i]

        PushPawnMove(
            roll,
            count_move,
            pawn,
            occupancy,
            blackOcc,
            UInt8(squares[i])
    )

     






def WhiteRookLeftMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]

):

    var attacks, index = WhiteRookLeftAttacks(board,occupancy)

    var WRLeftMoves = QuietFilter(attacks, whiteOcc)
    var WRLeftCaps  = CaptureFilter(attacks, blackOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRLeftMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRLeftCaps,
        CAPTURE
    )


    
def WhiteRookRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks, index = WhiteRookRightAttacks(board,occupancy)

    var WRRightMoves = QuietFilter(attacks, whiteOcc)
    var WRRightCaps  = CaptureFilter(attacks, blackOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRRightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRRightCaps,
        CAPTURE
    )



def BlackRookLeftMoves(
    mut roll: InlineArray[Move,128],
    mut  count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackRookLeftAttacks(board,occupancy)

    var BRLeftMoves = QuietFilter(attacks, blackOcc)
    var BRLeftCaps  = CaptureFilter(attacks, whiteOcc)
    
    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRLeftMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRLeftCaps,
        CAPTURE
    )



def BlackRookRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackRookRightAttacks(board,occupancy)

    var BRRightMoves = QuietFilter(attacks, blackOcc)
    var BRRightCaps  = CaptureFilter(attacks, whiteOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRRightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRRightCaps,
        CAPTURE
    )



def WhiteBishopLeftMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteBishopLeftAttacks(board,occupancy)

    var WBLeftMoves = QuietFilter(attacks, whiteOcc)
    var WBLeftCaps =  CaptureFilter(attacks, blackOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WBLeftMoves ,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WBLeftCaps,
        CAPTURE
    )


def WhiteBishopRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteBishopRightAttacks(board,occupancy)


    var WBRightMoves = QuietFilter(attacks, whiteOcc)
    var WBRightCaps =  CaptureFilter(attacks, blackOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WBRightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WBRightCaps,
        CAPTURE
    )


def BlackBishopLeftMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackBishopLeftAttacks(board,occupancy)

    var BBLeftMoves = QuietFilter(attacks, blackOcc)
    var BBLeftCaps = CaptureFilter(attacks, whiteOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BBLeftMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BBLeftCaps,
        CAPTURE
    )


def BlackBishopRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackBishopRightAttacks(board,occupancy)

    var BBRightMoves = QuietFilter(attacks, blackOcc)
    var BBRightCaps = CaptureFilter(attacks, whiteOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BBRightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BBRightCaps,
        CAPTURE
    )



def WhiteQueenMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteQueen(board,occupancy)

    var WQMoves = QuietFilter(attacks,whiteOcc)
    var WQCaps = CaptureFilter(attacks, blackOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WQMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WQCaps,
        CAPTURE
    )

def BlackQueenMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    occupancy: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackQueen(board,occupancy)

    var BQMoves = QuietFilter(attacks, blackOcc)
    var BQCaps = CaptureFilter(attacks, whiteOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BQMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BQCaps,
        CAPTURE
    )



def WhiteKnightLeftMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteLeftKnight(board)

    var WLKnightMoves = QuietFilter(attacks, whiteOcc)
    var WLKnightCaps = CaptureFilter(attacks, blackOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WLKnightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WLKnightCaps,
        CAPTURE
    )

def WhiteKnightRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteRightKnight(board)


    var WRKnightMoves = QuietFilter(attacks,whiteOcc)
    var WRKnightCaps = CaptureFilter(attacks,blackOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRKnightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WRKnightCaps,
        CAPTURE
    )

def BlackKnightLeftMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackLeftKnight(board)

    var BLKnightMoves = QuietFilter(attacks,blackOcc)
    var BLKnightCaps = CaptureFilter(attacks,whiteOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BLKnightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BLKnightCaps,
        CAPTURE
    )


def BlackKnightRightMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackRightKnight(board)

    var BRKnightMoves = QuietFilter(attacks,blackOcc)
    var BRKnightCaps = CaptureFilter(attacks,whiteOcc)


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRKnightMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BRKnightCaps,
        CAPTURE
    )

    

def WhiteKingMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = WhiteKing(board)

    var WKingMoves = QuietFilter(attacks,whiteOcc)
    var WKingCaps = CaptureFilter(attacks,blackOcc)
    
    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WKingMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        WKingCaps,
        CAPTURE
    )

def BlackKingMoves(
    mut roll: InlineArray[Move,128],
    mut count_move: Int,
    blackOcc: UInt64,
    whiteOcc: UInt64,
    board: SIMD[DType.uint8,64]
):
    var attacks,index = BlackKing(board)


    var BKingMoves = QuietFilter(attacks,blackOcc)
    var BKingCaps = CaptureFilter(attacks,whiteOcc)

    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BKingMoves,
        QUIET
    )


    PushMoves(
        roll,
        count_move,
        UInt8(index),
        BKingCaps,
        CAPTURE
    )