from nonblockingpipe import Pipe
import re

#
#
# uci ->
#    <- [..lots of stuff...] 
#       uciok
# isready ->
#    <- readyok

# position startpos [moves] ->
#
# set the time limit and search for lines only on the given move
# go movetime 1000 searchmoves g7g6 ->
#
#   or
# go movetime 1000 searchmoves ->

chess_engine = "stockfish"

moves = "g1f3 g8f6 c2c4 c7c5 b2b3 g7g6 c1b2 f8g7 e2e3 e8g8 f1e2 b7b6 e1g1 c8b7 b1c3 b8c6 d1c2 a8c8 a1c1 d7d5 c3d5 f6d5 b2g7 d5f4 e3f4 g8g7 c2c3 g7g8 c1d1 d8d6 d2d4 c5d4 f3d4 d6f4 e2f3 f4f6"
# d4b5 f6c3 1/2-1/2"


def new_position(engine_pipe, moves):
    engine_pipe.write("position startpos moves {}\n".format(moves))

def evaluate(engine_pipe, milliseconds, move=None):
    if move is not None:
        engine_pipe.write("go movetime {} searchmoves {}\n".format(
                             milliseconds, move))
    else:
        engine_pipe.write("go movetime {}\n".format(milliseconds))
    lines = expect(engine_pipe, "bestmove")
    return lines

def start_engine():
    engine_pipe = Pipe("stockfish", timeout = 100)
    engine_pipe.write("uci\n")
    expect(engine_pipe, "uciok")
    engine_pipe.write("isready\n")
    expect(engine_pipe, "readyok")
    return engine_pipe


def expect(engine_pipe, regex):
    lines = ""
    while True:
        l = engine_pipe.readlines()
        if l is not None and re.search(regex, l):
            lines = lines + l
            break
    return lines;

if __name__ == "__main__":
    engine_pipe = start_engine()

    new_position(engine_pipe, moves)
    print(evaluate(engine_pipe, 100))

    new_position(engine_pipe, moves)
    print(evaluate(engine_pipe, 60000, "f3c6"))

    new_position(engine_pipe, moves)
    print(evaluate(engine_pipe, 60000))

    engine_pipe.close()
    print("Done")

