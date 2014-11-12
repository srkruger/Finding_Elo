require(caret)

#trainControl function used by caret 2 score a fold
MAE <- function (data, lev = NULL, model = NULL) 
{    
    out <- c(mean(abs(data$pred - data$obs)))
    names(out) <- c("MAE")
    out
}

#Read data
train <- read.csv("Processed/train.csv")
sf <- read.csv("Processed/stockfish_converted.csv")
sf_train <- sf[1:25000,]
sf_train <- sf_train[,-1]
test <- read.csv("Processed/test.csv")
sf_test <- sf[25001:50000,]
sf_test <- sf_test[,-1]

#Save targets and result
trainWhiteElo <- train$WhiteElo
trainBlackElo <- train$BlackElo
trainResult <- train$Result
testResult <- test$Result

#Generate Opening and NumMoves feature from Moves
OPENING_NB_MOVES = 3 #The number of moves(half?) that constitutes an opening
Opening <- gsub(" ", "", substr(as.character(train$Moves), 1, (OPENING_NB_MOVES * 4 + (OPENING_NB_MOVES - 1))))
NumMoves <- sapply(strsplit(as.character(train$Moves), split=c(" ")), FUN=length)
train <- cbind(train, Opening)
train <- cbind(train, NumMoves)
Opening <- gsub(" ", "", substr(as.character(test$Moves), 1, (OPENING_NB_MOVES * 4 + (OPENING_NB_MOVES - 1))))
NumMoves <- sapply(strsplit(as.character(test$Moves), split=c(" ")), FUN=length)
test <- cbind(test, Opening)
test <- cbind(test, NumMoves)

#Remove Event, Result, Moves and targets
train <- train[, -(1:5)]
test <- test[, -(1:3)]

#Opening
NB_OPENINGS = 25 #Number of different openings to consider(includes Other). Must be > 0
OPENING_ONE_HOT = FALSE #One-hot encode Opening factor?

if(NB_OPENINGS > 0)
{
    #Create new levels
    fmReducedLevels <- names(summary(train$Opening, maxsum=(NB_OPENINGS + 1)))[1:NB_OPENINGS]    
    #Create a new factor using created levels, add "Other" as a level
    train$Opening <- factor(x=train$Opening, levels=c(fmReducedLevels, "Other"))
    #Turn NA's into "Other"
    train$Opening[is.na(train$Opening)] <- "Other"
    
    #Use same levels for the factor in test
    test$Opening <- factor(x=test$Opening, levels=levels(train$Opening))    
    test$Opening[is.na(test$Opening)] <- "Other"
}

#One-hot encode
if(OPENING_ONE_HOT)
{    
    #TODO : figure out how this code works
    train <- cbind(train, with(train,
                               data.frame(model.matrix(~Opening-1,train))))
    test <- cbind(test, with(test,
                             data.frame(model.matrix(~Opening-1,test))))
    #Remove Opening
    train <- train[, -1]
    test <- test[, -1]
}

#Add stockfish features
train <- cbind(train, sf_train)
test <- cbind(test, sf_test)

#Add material balance and count features
mbcData <- read.csv("Processed/eval.csv")
train <- cbind(train, mbcData[1:25000,])
test <- cbind(test, mbcData[25001:50000,])

#Set up train control for 3-Fold CV
fc <- trainControl(method = "repeatedCV", summaryFunction=MAE,
                   number = 3, repeats = 1, verboseIter=TRUE, 
                   returnResamp="all")

#Set up tuning grid
tGrid <- expand.grid(n.trees=350, interaction.depth=7, shrinkage=0.02)

############################################################################################################
#Build a model to predict WhiteElo for White Wins
set.seed(63951)
modelW_W <- train(x=train[trainResult=="W",], y=trainWhiteElo[trainResult=="W"], method="gbm", trControl=fc, 
                tuneGrid=tGrid, metric="MAE", maximize=FALSE, distribution="laplace")
modelW_W

#Build a model to predict WhiteElo for draws
set.seed(63951)
modelW_D <- train(x=train[trainResult=="D",], y=trainWhiteElo[trainResult=="D"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE, , distribution="laplace")
modelW_D

#Build a model to predict WhiteElo for Black wins
set.seed(63951)
modelW_B <- train(x=train[trainResult=="B",], y=trainWhiteElo[trainResult=="B"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE, distribution="laplace")
modelW_B
############################################################################################################

############################################################################################################
#Build a model to predict BlackElo for White Wins
set.seed(63951)
modelB_W <- train(x=train[trainResult=="W",], y=trainBlackElo[trainResult=="W"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE, distribution="laplace")
modelB_W

#Build a model to predict BlackElo for draws
set.seed(63951)
modelB_D <- train(x=train[trainResult=="D",], y=trainBlackElo[trainResult=="D"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE, distribution="laplace")
modelB_D

#Build a model to predict BlackElo for Black wins
set.seed(63951)
modelB_B <- train(x=train[trainResult=="B",], y=trainBlackElo[trainResult=="B"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE, distribution="laplace")
modelB_B
############################################################################################################

#TODO - Find a good way to calc CV for all models

#Make predictions and create submission file
predsWhiteWins <- data.frame(Event=(25001:50000)[testResult=="W"], 
                    WhiteElo=predict(modelW_W, test[testResult=="W",]),
                    BlackElo=predict(modelB_W, test[testResult=="W",]))

predsDraws <- data.frame(Event=(25001:50000)[testResult=="D"], 
                            WhiteElo=predict(modelW_D, test[testResult=="D",]),
                            BlackElo=predict(modelB_D, test[testResult=="D",]))

predsBlackWins <- data.frame(Event=(25001:50000)[testResult=="B"], 
                        WhiteElo=predict(modelW_B, test[testResult=="B",]),
                        BlackElo=predict(modelB_B, test[testResult=="B",]))

submit <- rbind(predsWhiteWins, predsDraws, predsBlackWins)
write.csv(submit, file="submit.csv", row.names=FALSE)
