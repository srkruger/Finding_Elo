require(caret)

#trainControl function used by caret 2 score a fold
MAE <- function (data, lev = NULL, model = NULL) 
{    
    out <- c(mean(abs(data$pred - data$obs)))
    names(out) <- c("MAE")
    out
}

train <- read.csv("train.csv")

#Targets
trainWhiteElo <- train$WhiteElo
trainBlackElo <- train$BlackElo

#Change Result and NumberOfMoves to numeric 
train$Result <- as.numeric(train$Result)
train$NumberOfMoves <- as.numeric(train$NumberOfMoves)

#Remove Id and targets
train <- train[,-c(1, 5, 6)]

#First move
#levels = 107 in train
REDUCE_FIRST_MOVE_LEVELS = 30 #Reduce FirstMove fator. 0 for no reduction
FIRST_MOVE_ONE_HOT = TRUE #One-hot encode factor

if(REDUCE_FIRST_MOVE_LEVELS > 0)
{
    #Create new levels
    fmReducedLevels <- names(summary(train$FirstMove, maxsum=(REDUCE_FIRST_MOVE_LEVELS + 1)))[1:REDUCE_FIRST_MOVE_LEVELS]    
    #create a new factor, add "Other" as a level
    train$FirstMove <- factor(x=train$FirstMove, levels=c(fmReducedLevels, "Other"))
    #Turn NA's into "Other"
    train$FirstMove[is.na(train$FirstMove)] <- "Other"
}

#One-hot encode
if(FIRST_MOVE_ONE_HOT)
{    
    #TODO : figure out how this code works
    train <- cbind(train, with(train,
                               data.frame(model.matrix(~FirstMove-1,train))))
    #Remove FirstMove
    train <- train[, -2]
}

#Build a model, CV to predict WhiteElo
set.seed(63951)
fc <- trainControl(method = "repeatedCV", summaryFunction=MAE,
                   number = 5, repeats = 1, verboseIter=TRUE, 
                   returnResamp="all")
tGrid <- expand.grid(mtry=5:6)
modelW <- train(x=train, y=as.numeric(trainWhiteElo), method="rf", trControl=fc, 
                tuneGrid=tGrid, metric="MAE", maximize=FALSE, ntree=150)
modelW