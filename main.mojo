from src.constants import *
from src.MoveGen import *



def main():
    
    var Plank = DynamicBoardContainer()
    var PawnMemorandum = InitPawnTables()
    var InstanceOne = GameState(Plank.DynamicBoard)
    
    WhitePiecesMovesGen( 
    InstanceOne.WhiteMoves.WhiteMoves,
    InstanceOne.WhiteCount,
    InstanceOne.WhiteOccup,
    InstanceOne.BlackOccup,
    InstanceOne.Occupancy,
    InstanceOne.Board,
    PawnMemorandum.WhitePawnTable
)

    BlackPiecesMovesGen(
    InstanceOne.BlackMoves.BlackMoves,
    InstanceOne.BlackCount,
    InstanceOne.WhiteOccup,
    InstanceOne.BlackOccup,
    InstanceOne.Occupancy,
    InstanceOne.Board,
    PawnMemorandum.BlackPawnTable

)