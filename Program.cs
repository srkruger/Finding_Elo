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

            //Create training data...
            for (int i = 0; i < 25000; i++)
            {
                for (int j = 0; j < 6; j++)
                    sr.ReadLine();

                string resultTag = sr.ReadLine().Split('"')[1];
                string result = resultTag == "1/2-1/2" ? "D" :
                    resultTag == "1-0" ? "W" : "B";

                int whilteElo = int.Parse(sr.ReadLine().Split('"')[1]);
                int blackElo = int.Parse(sr.ReadLine().Split('"')[1]);
                sr.ReadLine();

                string SAN = sr.ReadLine();
                while ((line = sr.ReadLine()).Length != 0)
                    SAN += " " + line;

                string[] firstMoveTokens = SAN.Split('.');
                firstMoveTokens = firstMoveTokens[1].Split(' ');
                string firstMove = string.Empty;
                for (int j = 1; j < firstMoveTokens.Length - 1; j++)
                    firstMove += firstMoveTokens[j];

                int nbMoves = SAN.Split('.').Length - 1;

                swTrain.Write(eventId);
                swTrain.Write(',');
                swTrain.Write(result);
                swTrain.Write(',');
                swTrain.Write(firstMove);
                swTrain.Write(',');
                swTrain.Write(nbMoves);
                swTrain.Write(',');
                swTrain.Write(whilteElo);
                swTrain.Write(',');
                swTrain.WriteLine(blackElo);

                eventId++;
            }
            swTrain.Close();

            //...and test data
            for (int i = 0; i < 25000; i++)
            {
                for (int j = 0; j < 6; j++)
                    sr.ReadLine();

                string resultTag = sr.ReadLine().Split('"')[1];
                string result = resultTag == "1/2-1/2" ? "D" :
                    resultTag == "1-0" ? "W" : "B";

                sr.ReadLine();

                string SAN = sr.ReadLine();
                while ((line = sr.ReadLine()).Length != 0)
                    SAN += " " + line;

                string[] firstMoveTokens = SAN.Split('.');
                firstMoveTokens = firstMoveTokens[1].Split(' ');
                string firstMove = string.Empty;
                for (int j = 1; j < firstMoveTokens.Length - 1; j++)
                    firstMove += firstMoveTokens[j];

                int nbMoves = SAN.Split('.').Length - 1;

                swTest.Write(eventId);
                swTest.Write(',');
                swTest.Write(result);
                swTest.Write(',');
                swTest.Write(firstMove);
                swTest.Write(',');
                swTest.WriteLine(nbMoves);

                eventId++;
            }

            sr.Close();
            swTest.Close();
        }
    }
}
