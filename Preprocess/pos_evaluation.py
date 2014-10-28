# This program computes for each game a set of features
# based on the evaluation of the sequence of positions 
# in the game.
#
# This script requires: python-chess==0.5.0

import chess
import re

n = 0
with open("../Raw/data_uci.pgn", "r") as f:
    for line in f:
        line = line.strip()
        m = re.match("[a-h1-8]{4}", line)
        if m:
            n += 1
            moves = line.split()
            moves.pop() # We don't want the score.
            board = chess.Bitboard()
            for move in moves:
                board.push(chess.Move.from_uci(move))
                print("---------------------")
                print(board)


        # Limit (for now) the number of games that are explored.
        if n == 1:
            break


