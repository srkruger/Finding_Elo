
require(ggplot2)

dataset <-read.table("../Processed/move_count.csv", header=TRUE, sep=",") 

p1 <- ggplot(dataset, aes(x=move_count)) + geom_histogram(binwidth=1)
ggsave(plot=p1, file="move_count_distribution.pdf")

dataset <- read.table("../Processed/elo.csv", header=TRUE, sep=",")

p2 <- ggplot(dataset,aes(x=WhiteElo))+geom_histogram(binwidth=10)
ggsave(plot=p2, file="white_elo_distribution.pdf")
