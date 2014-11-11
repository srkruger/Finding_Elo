SIZE = 25000

#Read all game data
all <- readLines("../Raw/data_uci.pgn", -1)

#########################Build training set ###################################
Result <- character(SIZE)
Moves <- character(SIZE)
WhiteElo <- numeric(SIZE)
BlackElo <- numeric(SIZE)

for(Event in 1:SIZE)
{
    gameOffset <- (Event - 1) * 12
    
    #Parse result as W,D or B
    resultTag <- all[gameOffset + 7]
    result <- unlist(strsplit(resultTag, "\""))[2]
    if(result=="1/2-1/2")
        result <- "D" else if (result=="1-0")
            result <- "W" else result <- "B"
    Result[Event] <- result
    
    #Parse moves. Remove result
    moves <- unlist(strsplit(all[gameOffset + 11], " "))
    moves <- paste(moves[1:(length(moves) - 1)], collapse=" ")
    Moves[Event] <- moves
    
    #Parse white elo
    whiteEloTag <- all[gameOffset + 8]
    WhiteElo[Event] <- as.numeric(unlist(strsplit(whiteEloTag, "\""))[2])
    
    #Parse black elo
    blackEloTag <- all[gameOffset + 9]
    BlackElo[Event] <- as.numeric(unlist(strsplit(blackEloTag, "\""))[2])
}

train <- data.frame(Event = 1:SIZE, Result, Moves, WhiteElo, BlackElo,
                    stringsAsFactors=FALSE)

write.csv(train, "../Processed/train.csv", row.names=FALSE)
#########################Build training set ###################################


#########################Build test set ###################################
Result <- character(SIZE)
Moves <- character(SIZE)

for(Event in (SIZE + 1):(SIZE * 2))
{
    gameOffset <- (SIZE * 12 + 1) + (Event - SIZE - 1) * 10
    
    #Parse result as W,D or B
    resultTag <- all[gameOffset + 6]
    result <- unlist(strsplit(resultTag, "\""))[2]
    if(result=="1/2-1/2")
        result <- "D" else if (result=="1-0")
            result <- "W" else result <- "B"
    Result[Event - SIZE] <- result
    
    #Parse moves. Remove result
    moves <- unlist(strsplit(all[gameOffset + 8], " "))
    Moves[Event - SIZE] <- paste(moves[1:(length(moves) - 1)], collapse=" ")
}

test <- data.frame(Event=(SIZE + 1):(SIZE * 2), Result, Moves, 
                   stringsAsFactors=FALSE)

write.csv(test, "../Processed/test.csv", row.names=FALSE)
#########################Build test set ###################################


