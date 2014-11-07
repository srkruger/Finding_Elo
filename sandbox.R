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

#Remove Id, result and targets
train <- train[,-c(1, 2, 5, 6)]
test <- test[,-c(1, 2)]

#First move
#levels = 107 in train
REDUCE_FIRST_MOVE_LEVELS = 8 #Reduce FirstMove factor. Must be > 0
FIRST_MOVE_ONE_HOT = FALSE #One-hot encode FirstMove factor?

if(REDUCE_FIRST_MOVE_LEVELS > 0)
{
    #Create new levels
    fmReducedLevels <- names(summary(train$FirstMove, maxsum=(REDUCE_FIRST_MOVE_LEVELS + 1)))[1:REDUCE_FIRST_MOVE_LEVELS]    
    #Create a new factor using created levels, add "Other" as a level
    train$FirstMove <- factor(x=train$FirstMove, levels=c(fmReducedLevels, "Other"))
    #Turn NA's into "Other"
    train$FirstMove[is.na(train$FirstMove)] <- "Other"
    
    #Use same levels for the factor in test
    test$FirstMove <- factor(x=test$FirstMove, levels=levels(train$FirstMove))    
    test$FirstMove[is.na(test$FirstMove)] <- "Other"
}

#One-hot encode
if(FIRST_MOVE_ONE_HOT)
{    
    #TODO : figure out how this code works
    train <- cbind(train, with(train,
                               data.frame(model.matrix(~FirstMove-1,train))))
    test <- cbind(test, with(test,
                             data.frame(model.matrix(~FirstMove-1,test))))
    #Remove FirstMove
    train <- train[, -2]
    test <- test[, -2]
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

############################################################################################################
#Build a model to predict WhiteElo for White Wins
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=300, interaction.depth=5:7, shrinkage=0.02)
modelW_W <- train(x=train[trainResult=="W",], y=trainWhiteElo[trainResult=="W"], method="gbm", trControl=fc, 
                tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelW_W

#Build a model to predict WhiteElo for draws
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=200, interaction.depth=5:7, shrinkage=0.02)
modelW_D <- train(x=train[trainResult=="D",], y=trainWhiteElo[trainResult=="D"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelW_D

#Build a model to predict WhiteElo for Black wins
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=200, interaction.depth=5:7, shrinkage=0.02)
modelW_B <- train(x=train[trainResult=="B",], y=trainWhiteElo[trainResult=="B"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelW_B
############################################################################################################

############################################################################################################
#Build a model to predict BlackElo for White Wins
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=300, interaction.depth=5:7, shrinkage=0.02)
modelB_W <- train(x=train[trainResult=="W",], y=trainBlackElo[trainResult=="W"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelB_W

#Build a model to predict BlackElo for draws
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=200, interaction.depth=5:7, shrinkage=0.02)
modelB_D <- train(x=train[trainResult=="D",], y=trainBlackElo[trainResult=="D"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelB_D

#Build a model to predict BlackElo for Black wins
set.seed(63951)
#Set up tuning grid
tGrid <- expand.grid(n.trees=200, interaction.depth=5:7, shrinkage=0.02)
modelB_B <- train(x=train[trainResult=="B",], y=trainBlackElo[trainResult=="B"], method="gbm", trControl=fc, 
                  tuneGrid=tGrid, metric="MAE", maximize=FALSE)
modelB_B
############################################################################################################

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
