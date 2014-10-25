
import re

print("event,move_count")
with open("../Raw/data_uci.pgn") as ucif:
    event = None
    for line in ucif:
        line = line.strip()
        m = re.match("[a-h1-8]{4}", line)
        if m:
            moves = line.split()
            assert(re.match("1-0|0-1|1/2-1/2", moves[-1]))
            print("{},{}".format(event,len(moves)))
        else:
            n = len(line)
            if n > 0:
                m = re.match('\[(\S+)\s"([^"]+)"', line)
                if m:
                    k = m.group(1)
                    v = m.group(2)
                    if k == "Event":
                        event = v
                else:
                    # Just to make sure we don't miss anything.
                    assert(0)

