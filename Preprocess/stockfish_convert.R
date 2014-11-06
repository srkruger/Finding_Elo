#Read original kaggle stockfish scores
sfData <- read.csv("stockfish.csv", as.is=c(2))

#Extract the stockfish scores into a list of numeric vectors(one for each game)
gameScores <- sapply((sapply(sfData[,2], strsplit, split=c(" "), USE.NAMES=FALSE)), as.numeric)


#Create the result dataframe (takes a while on my "rig", enough time to make a cup of tea)
result <- cbind(Event=1:nrow(sfData),data.frame(t(sapply(gameScores, createStockfishObservation))))

#Save result
write.csv(result, "stockfish_converted.csv", row.names=FALSE)



