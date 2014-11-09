from nonblockingpipe import Pipe

chess_engine = "stockfish"

game = "g1f3 g8f6 c2c4 c7c5 b2b3 g7g6 c1b2 f8g7 e2e3 e8g8 f1e2 b7b6 e1g1 c8b7 b1c3 b8c6 d1c2 a8c8 a1c1 d7d5 c3d5 f6d5 b2g7 d5f4 e3f4 g8g7 c2c3 g7g8 c1d1 d8d6 d2d4 c5d4 f3d4 d6f4 e2f3 f4f6 d4b5 f6c3 1/2-1/2"

print(game)

if __name__ == "__main__":
    # Execute cat
    p = Pipe("cat", timeout = 100)

    # Try to read something. At this stage no data should be ready to be read
    print( 'Reading %s' % p.readlines() )
    # If the execution did not hang, the following line is executed
    p.write("Hello World!")
    # Now some data should be available
    print( 'Reading %s' % p.readlines() )
    p.close()

