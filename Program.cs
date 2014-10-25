using System;
using System.Text;
using System.IO;

namespace DodoVanOranje.Net
{
    class Program
    {
        private static void Main(string[] args)
        {
            //ConvertKagglePGN(@"C:\Documents and Settings\rudi\ML\kaggle\Elo\data.pgn");

            ConvertKaggleStockfishData(@"C:\Documents and Settings\rudi\ML\kaggle\Elo\stockfish.csv");
        }

        /// <summary>
        /// Converts the kaggle stockfish data
        /// (in stockfish.csv) to sf_train.csv
        /// and sf_test.csv dataset files (in same 
        /// directory as input file). Features :
        /// Event,AvgScore,MinScore,MaxScore,
        /// AvgDelta,MinDelta,MaxDelta
        /// </summary>
        /// <param name="p"></param>
        private static void ConvertKaggleStockfishData(string stockfish_csv_path)
        {
            string header = "Event,AvgScore,MinScore,MaxScore,AvgDelta,MinDelta,MaxDelta";
            StreamReader sr = File.OpenText(stockfish_csv_path);
            string path = Path.GetDirectoryName(stockfish_csv_path) + Path.DirectorySeparatorChar;
            StreamWriter swTrain = File.CreateText(path + "sf_train.csv");
            swTrain.WriteLine(header);
            StreamWriter swTest = File.CreateText(path + "sf_test.csv");
            swTest.WriteLine(header);
            int eventId = 1;
            //Swallow header
            string line = sr.ReadLine();

            //For each line in input file
            for (int i = 0; i < 50000; i++)
            {
                //First 25k games belong to train
                bool training = i < 25000;

                //Parse the score strings
                string[] scoreTokens = sr.ReadLine().Split(',')[1].Split(' ');
                double minScore = double.MaxValue;
                double maxScore = double.MinValue;
                double totalScore = 0;
                double minDelta = double.MaxValue;
                double maxDelta = double.MinValue;
                double totalDelta = 0;
                //Proces each score string(beware of NA's)
                int nbScores = 0;
                int nbDeltas = 0;
                for (int j = 0; j < scoreTokens.Length; j++)
                {
                    double score = 0;
                    if(!double.TryParse(scoreTokens[j], out score))
                        continue;
                    minScore = Math.Min(minScore, score);
                    maxScore = Math.Max(maxScore, score);
                    totalScore += score;
                    if (j > 0)
                    {
                        if (scoreTokens[j - 1] != "NA")
                        {
                            double delta = 0;
                            if (!double.TryParse(scoreTokens[j - 1], out delta))
                                continue;
                            delta -= score;
                            minDelta = Math.Min(minDelta, delta);
                            maxDelta = Math.Max(maxDelta, delta);
                            totalDelta += delta;
                            nbDeltas++;
                        }
                    }
                    nbScores++;
                }
                double avgScore = totalScore == 0 || nbScores == 0 ? 0 : totalScore / nbScores;
                double avgDelta = totalDelta == 0 || nbDeltas == 0 ? 0 : totalDelta / nbDeltas;

                //If no(or only one) scores are present, 
                //zero min and max vars
                if (nbScores == 0)
                {
                    minScore = 0;
                    maxScore = 0;
                }
                if (nbDeltas == 0)
                {
                    minDelta = 0;
                    maxDelta = 0;
                }

                StreamWriter outputDataset = training ? swTrain : swTest;
                //Write a line to data set
                outputDataset.Write(eventId);
                outputDataset.Write(',');
                outputDataset.Write(avgScore);
                outputDataset.Write(',');
                outputDataset.Write(minScore);
                outputDataset.Write(',');
                outputDataset.Write(maxScore);
                outputDataset.Write(',');
                outputDataset.Write(avgDelta);
                outputDataset.Write(',');
                outputDataset.Write(minDelta);
                outputDataset.Write(',');
                outputDataset.WriteLine(maxDelta);

                eventId++;
            }

            sr.Close();
            swTrain.Close();
            swTest.Close();
        }

        /// <summary>
        /// Converts the kaggle data in data.pgn
        /// to train.csv and test.csv dataset 
        /// files(in same directory as input file). 
        /// Features included :
        /// Event, Result(W - White wins, B - Black Wins, D - Draw),
        /// FirstMove(first move in the SAN data),
        /// NumberOfMoves(move pairs?),WhiteElo(not in test),
        /// BlackElo(not in test)
        /// </summary>
        /// <param name="data_pgn_path">The path to data.pgn from kaggle</param>
        private static void ConvertKagglePGN(string data_pgn_path)
        {
            StreamReader sr = File.OpenText(data_pgn_path);
            string path = Path.GetDirectoryName(data_pgn_path) + Path.DirectorySeparatorChar;
            StreamWriter swTrain = File.CreateText(path + "train.csv");
            swTrain.WriteLine("Event,Result,FirstMove,NumberOfMoves,WhiteElo,BlackElo");
            StreamWriter swTest = File.CreateText(path + "test.csv");
            swTest.WriteLine("Event,Result,FirstMove,NumberOfMoves");
            int eventId = 1;
            string line = string.Empty;

            //For each line in input file
            for (int i = 0; i < 50000; i++)
            {
                //First 25k games belong to train
                bool training = i < 25000;

                //Skip unused tags
                for (int j = 0; j < 6; j++)
                    sr.ReadLine();

                //Parse the result tag into W,B or D
                string resultTag = sr.ReadLine().Split('"')[1];
                string result = resultTag == "1/2-1/2" ? "D" :
                    resultTag == "1-0" ? "W" : "B";

                //Parse elo ratings(only for training games)
                int whilteElo = 0;
                int blackElo = 0;
                if (training)
                {
                    whilteElo = int.Parse(sr.ReadLine().Split('"')[1]);
                    blackElo = int.Parse(sr.ReadLine().Split('"')[1]);
                }
                sr.ReadLine();

                //Parse the SAN text line by line
                string SAN = sr.ReadLine();
                while ((line = sr.ReadLine()).Length != 0)
                    SAN += " " + line;

                //Extract the first move, ex "1. e4 e5"
                //Convert to "e4e5"
                string[] firstMoveTokens = SAN.Split('.');
                firstMoveTokens = firstMoveTokens[1].Split(' ');
                string firstMove = string.Empty;
                for (int j = 1; j < firstMoveTokens.Length - 1; j++)
                    firstMove += firstMoveTokens[j];

                //Count number of move pairs
                int nbMoves = SAN.Split('.').Length - 1;

                StreamWriter outputDataset = training ? swTrain : swTest;
                //Write a line to data set
                outputDataset.Write(eventId);
                outputDataset.Write(',');
                outputDataset.Write(result);
                outputDataset.Write(',');
                outputDataset.Write(firstMove);
                outputDataset.Write(',');
                outputDataset.Write(nbMoves);
                if (training)
                {
                    outputDataset.Write(',');
                    outputDataset.Write(whilteElo);
                    outputDataset.Write(',');
                    outputDataset.WriteLine(blackElo);
                }
                else
                    outputDataset.WriteLine();

                eventId++;
            }

            sr.Close();
            swTrain.Close();
            swTest.Close();
        }
    }
}
