for c in 20 40 80 120; do
	for d in 1 2 3 4 5; do
		for e in 1 2 3 4 5; do
			mv data/run2/${c}/${d}/a${d}-${e}.csv data/run2/$c/$d/a${e}.csv
		done
	done
done
