using System;
using System.Text;
using System.IO;

namespace DodoVanOranje.Net
{
    class Program
    {
        private static void Main(string[] args)
        {
            EloConvert(@"C:\Documents and Settings\rudi\ML\kaggle\Elo\data.pgn");
        }

        /// <summary>
        /// Converts the kaggle data in data.pgn
        /// to train.csv and test.csv dataset 
        /// file(in same directory as input file). 
        /// Features included :
        /// Event, Result(W - White wins, B - Black Wins, D - Draw),
        /// FirstMove(first move in the SAN data),
        /// NumberOfMoves(move pairs?),WhiteElo(not in test),
        /// BlackElo(not in test)
        /// </summary>
        /// <param name="data_pgn_path">The path to data.pgn from kaggle</param>
        private static void EloConvert(string data_pgn_path)
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
