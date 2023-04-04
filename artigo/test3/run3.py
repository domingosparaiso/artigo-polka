import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

run=3
#csv output format: Type rate:
#  0 unix timestamp
#  1 interface
#  2 bytes_out/s
#  3 bytes_in/s
#  4 bytes_total/s
#  5 bytes_in
#  6 bytes_out
#  7 packets_out/s
#  8 packets_in/s
#  9 packets_total/s
# 10 packets_in
# 11 packets_out
# 12 errors_out/s
# 13 errors_in/s
# 14 errors_in
# 15 errors_out 

linkname=['MIA-SAO','CHI-AMS','MIA-CHI','MIA-CAL','','AMS-AMS_edge']
for taxa in [ 80 ]:
	print(f'Taxa: {taxa}mb')
	for sample in range(1, 6):
		for router in [ 2, 3, 4, 5, 7]:
			arq=f'data/run{run}/{taxa}/{sample}/a{router}.csv'
			f=open(arq)
			linhas=f.readlines()
			f.close()

			y=[]
			x=[]
			cont=1
			for dado in linhas:
				x.append(cont)
				cont=cont+1
				b=dado.split(',')[3]
				fb=float(b)
				y.append(float(b))
			plt.yscale('linear')
			plt.plot(x, y, label=linkname[router-2])
			plt.xlabel('time')
		plt.ylabel('bytes total') 
		plt.legend(title='Link:', loc='lower left')
		plt.title('Redirecionamento de fluxo')
		current_values = plt.gca().get_yticks().tolist()
		plt.gca().set_yticklabels(['{:.0f}'.format(x) for x in current_values])
		print(f'Sample {sample}: OK')
		plt.savefig(f'results/run{run}/{taxa}-{sample}.png')
		plt.clf()

