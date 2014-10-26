
import re

with open("../Processed/elo.csv", "w") as elo:
    elo.write("Event,WhiteElo,BlackElo,Result\n")
    with open("../Raw/data_uci.pgn", "r") as f:
        gamedata = {}
        for line in f:
            m = re.match('\[(\S+)\s"([^"]+)"', line)
            if m:
                key   = m.group(1)
                value = m.group(2)
                gamedata[key] = value
            m = re.match('^\s*$', line)
            if m:
                if len(gamedata) > 0:
                    if "WhiteElo" in gamedata:
                        elo.write("{},{},{},{}\n".format(
                            gamedata["Event"],
                            gamedata["WhiteElo"],
                            gamedata["BlackElo"],
                            gamedata["Result"]))
                    else:
                        elo.write("{},NA,NA,{}\n".format(
                            gamedata["Event"], gamedata["Result"]))

                    gamedata = {}

