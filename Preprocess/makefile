
all : ../Processed/move_count.csv \
      ../Processed/elo.csv \
      ../Processed/positional.csv

../Processed/move_count.csv : count_moves.py
	time python count_moves.py > ../Processed/move_count.csv

../Processed/elo.csv : extract_elo.py
	time python extract_elo.py

../Processed/positional.csv : pos_evaluation.py
	time python pos_evaluation.py > ../Processed/positional.csv

clean :
	-rm -f ../Processed/move_count.csv
	-rm -f ../Processed/elo.csv
	-rm -f ../Processed/positional.csv

