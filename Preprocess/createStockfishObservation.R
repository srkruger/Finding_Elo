#Function to create an observation for each game(numeric vector of Stockfish scores)
#Observation returned as a named vector
createStockfishObservation <- function(scores)
{
    #Must have at least 2 scores
    if(length(scores) < 2) {
        c(MeanScore = NA,
          MedianScore = NA,
          MinScore = NA,
          MaxScore = NA,
          StdDevScore = NA,
          FirstQScore = NA,
          ThirdQScore = NA,
          MeanDelta = NA,
          MedianDelta = NA,
          MinDelta = NA,
          MaxDelta = NA,
          StdDevDelta = NA,
          FirstQDelta = NA,
          ThirdQDelta = NA,
          WhiteMeanScore = NA,
          BlackMeanScore = NA,
          WhiteMedianScore = NA,
          BlackMedianScore = NA,
          WhiteMinScore = NA,
          BlackMinScore = NA,
          WhiteMaxScore = NA,
          BlackMaxScore = NA,
          WhiteStdDevScore = NA,
          BlackStdDevScore = NA,
          WhiteFirstQScore = NA,
          BlackFirstQScore = NA,
          WhiteThirdQScore = NA,
          BlackThirdQScore = NA,
          WhiteMeanDelta = NA,
          BlackMeanDelta = NA,
          WhiteMedianDelta = NA,
          BlackMedianDelta = NA,
          WhiteMinDelta = NA,
          BlackMinDelta = NA,
          WhiteMaxDelta = NA,
          BlackMaxDelta = NA,
          WhiteStdDevDelta = NA,
          BlackStdDevDelta = NA,
          WhiteFirstQDelta = NA,
          BlackFirstQDelta = NA,
          WhiteThirdQDelta = NA,
          BlackThirdQDelta = NA)
    }
    else {
        
        #Extract deltas
        deltas <- diag(outer(scores[2:length(scores)], scores[1:(length(scores) - 1)], FUN="-"))
        
        #Extract white & black scores
        whiteScores <- scores[seq(1,length(scores), 2)]
        blackScores <- scores[seq(2,length(scores), 2)]
        
        #Extract white deltas, must have at least 3 scores
        whiteDeltas <- c(0)
        if(length(scores) >= 3) {
            whiteDeltas <- diag(outer(scores[seq(3,length(scores), 2)], scores[seq(1,length(scores)-1, 2)], FUN="-"))
        }
        
        #Extract black deltas, must have at least 4 scores
        blackDeltas <- c(0)
        if(length(scores) >= 4) {
            blackDeltas <- diag(outer(scores[seq(4,length(scores), 2)], scores[seq(2,length(scores)-1, 2)], FUN="-"))
        }
        
        #Create observation
        c(MeanScore = mean(scores, na.rm = TRUE), 
          MedianScore = median(scores, na.rm = TRUE), 
          MinScore = min(scores, na.rm = TRUE), 
          MaxScore = max(scores, na.rm = TRUE),
          StdDevScore = sd(scores, na.rm = TRUE),
          FirstQScore = quantile(scores, 0.25, na.rm = TRUE, names = FALSE)[1],
          ThirdQScore = quantile(scores, 0.75, na.rm = TRUE, names = FALSE)[1],
          MeanDelta = mean(deltas, na.rm = TRUE),
          MedianDelta = median(deltas, na.rm = TRUE),
          MinDelta = min(deltas, na.rm = TRUE),
          MaxDelta = max(deltas, na.rm = TRUE),
          StdDevDelta = sd(deltas, na.rm = TRUE),
          FirstQDelta = quantile(deltas, 0.25, na.rm = TRUE, names = FALSE)[1],
          ThirdQDelta = quantile(deltas, 0.75, na.rm = TRUE, names = FALSE)[1],
          WhiteMeanScore = mean(whiteScores, na.rm = TRUE),
          BlackMeanScore = mean(blackScores, na.rm = TRUE),
          WhiteMedianScore = median(whiteScores, na.rm = TRUE),
          BlackMedianScore = median(blackScores, na.rm = TRUE),
          WhiteMinScore = min(whiteScores, na.rm = TRUE),
          BlackMinScore = min(blackScores, na.rm = TRUE),
          WhiteMaxScore = max(whiteScores, na.rm = TRUE),
          BlackMaxScore = max(blackScores, na.rm = TRUE),
          WhiteStdDevScore = sd(whiteScores, na.rm = TRUE),
          BlackStdDevScore = sd(blackScores, na.rm = TRUE),
          WhiteFirstQScore = quantile(whiteScores, 0.25, na.rm = TRUE, names = FALSE)[1],
          BlackFirstQScore = quantile(blackScores, 0.25, na.rm = TRUE, names = FALSE)[1],
          WhiteThirdQScore = quantile(whiteScores, 0.75, na.rm = TRUE, names = FALSE)[1],
          BlackThirdQScore = quantile(blackScores, 0.75, na.rm = TRUE, names = FALSE)[1],
          WhiteMeanDelta = mean(whiteDeltas, na.rm = TRUE),
          BlackMeanDelta = mean(blackDeltas, na.rm = TRUE),
          WhiteMedianDelta = median(whiteDeltas, na.rm = TRUE),
          BlackMedianDelta = median(blackDeltas, na.rm = TRUE),
          WhiteMinDelta = min(whiteDeltas, na.rm = TRUE),
          BlackMinDelta = min(blackDeltas, na.rm = TRUE),
          WhiteMaxDelta = max(whiteDeltas, na.rm = TRUE),
          BlackMaxDelta = max(blackDeltas, na.rm = TRUE),
          WhiteStdDevDelta = sd(whiteDeltas, na.rm = TRUE),
          BlackStdDevDelta = sd(blackDeltas, na.rm = TRUE),
          WhiteFirstQDelta = quantile(whiteDeltas, 0.25, na.rm = TRUE, names = FALSE)[1],
          BlackFirstQDelta = quantile(blackDeltas, 0.25, na.rm = TRUE, names = FALSE)[1],
          WhiteThirdQDelta = quantile(whiteDeltas, 0.75, na.rm = TRUE, names = FALSE)[1],
          BlackThirdQDelta = quantile(blackDeltas, 0.75, na.rm = TRUE, names = FALSE)[1])
    }
}