# This program computes for each game a set of features
# based on the evaluation of the sequence of positions 
# in the game.
#
# This script requires: python-chess==0.5.0
#  <http://python-chess.readthedocs.org/en/latest/>
#
# Running this takes about 5 minutes

import chess
import re


# <http://en.wikipedia.org/wiki/Chess_piece_relative_value>
piece_value = {
    chess.QUEEN  : 9,
    chess.ROOK   : 5,
    chess.KNIGHT : 3,   # These might change during the game
    chess.BISHOP : 3,
    chess.PAWN   : 1,
    chess.KING   : 0
}


def evaluate_position(board):
    """Compute a set of features based on the position on
    the board"""
    score = 0
    number_of_pieces = 0
    # Compute the material balance
    for square in chess.SQUARES:
        piece = board.piece_at(square)
        if piece is not None:
            number_of_pieces += 1
            value = piece_value[piece.piece_type]
            # print(value)
            if piece.color == chess.WHITE:
                score += value
            else:
                score -= value
    return score, number_of_pieces


limit = False # For debugging

def get_position_features():
    n = 0
    print("material_balance1,material_count1,material_balance2,material_count2")
    with open("../Raw/data_uci.pgn", "r") as f:
        for line in f:
            if re.match("[a-h1-8]{4}", line):
                n += 1
                moves = line.strip().split()
                moves.pop() # We don't want the score.
                number_of_moves = len(moves)
                board = chess.Bitboard()
                last_move = moves.pop()
                for move in moves:
                    # This is actually an half move.
                    move=move.lower() # python.chess does not like capitals.
                    board.push(chess.Move.from_uci(move))
                set1 = "{},{}".format(*evaluate_position(board))
                last_move = last_move.lower()
                board.push(chess.Move.from_uci(last_move))
                set2 = "{},{}".format(*evaluate_position(board))
                print(set1 + "," + set2)


            # Limit (for now) the number of games that are explored.
            if limit and n == 1:
                break


if __name__ == '__main__':
    get_position_features()
    #print(chess.SQUARES)

