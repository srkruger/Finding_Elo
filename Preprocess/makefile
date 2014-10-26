
all : ../Processed/move_count.csv ../Processed/elo.csv

../Processed/move_count.csv : count_moves.py
	python count_moves.py > ../Processed/move_count.csv

../Processed/elo.csv : extract_elo.py
	python extract_elo.py

clean :
	-rm -f ../Processed/move_count.csv
	-rm -f ../Processed/elo.csv

