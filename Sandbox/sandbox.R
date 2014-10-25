require(caret)

#trainControl function used by caret 2 score a fold
MAE <- function (data, lev = NULL, model = NULL) 
{    
    out <- c(mean(abs(data$pred - data$obs)))
    names(out) <- c("MAE")
    out
}

#Read data
train <- read.csv("train.csv")
sf_train <- read.csv("sf_train.csv")
sf_train <- sf_train[,-1]
test <- read.csv("test.csv")
sf_test <- read.csv("sf_test.csv")
sf_test <- sf_test[,-1]

#Save targets
trainWhiteElo <- train$WhiteElo
trainBlackElo <- train$BlackElo

#Change Result and NumberOfMoves to numeric 
train$Result <- as.numeric(train$Result)
train$NumberOfMoves <- as.numeric(train$NumberOfMoves)
test$Result <- as.numeric(test$Result)
test$NumberOfMoves <- as.numeric(test$NumberOfMoves)

#Remove Id and targets
train <- train[,-c(1, 5, 6)]
test <- test[,-1]

#First move
#levels = 107 in train
REDUCE_FIRST_MOVE_LEVELS = 16 #Reduce FirstMove factor. 0 for no reduction
FIRST_MOVE_ONE_HOT = TRUE #One-hot encode factor

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

#Add stockfish data
train <- cbind(train, sf_train)
test <- cbind(test, sf_test)

#Build a model, CV to predict WhiteElo
set.seed(63951)
fc <- trainControl(method = "repeatedCV", summaryFunction=MAE,
                   number = 3, repeats = 1, verboseIter=TRUE, 
                   returnResamp="all")
tGrid <- expand.grid(mtry=5)
modelW <- train(x=train, y=as.numeric(trainWhiteElo), method="rf", trControl=fc, 
                tuneGrid=tGrid, metric="MAE", maximize=FALSE, ntree=150)
modelW

#Another model, for Black this time
modelB <- train(x=train, y=as.numeric(trainBlackElo), method="rf", trControl=fc, 
                tuneGrid=tGrid, metric="MAE", maximize=FALSE, ntree=150)
modelB

#Make predictions and create submission file
submit <- data.frame(Event=25001:50000, WhiteElo=predict(modelW, test), BlackElo=predict(modelB, test))
write.csv(submit, file="submit_rf.csv", row.names=FALSE)
