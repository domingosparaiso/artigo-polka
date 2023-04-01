import matplotlib.pyplot as plt
import matplotlib.ticker as mticker

run=1
#csv output format: Type rate:
#unix timestamp;iface_name;bytes_out/s;bytes_in/s;bytes_total/s;bytes_in;bytes_out;packets_out/s;packets_in/s;packets_total/s;packets_in;packets_out;errors_out/s;errors_in/s;errors_in;errors_out\n

linkname=['MIA_edge - host1','SAO-AMS','CHI-AMS','MIA-CHI','MIA-CAL']
for taxa in [ 40, 80, 120 ]:
	print(f'Taxa: {taxa}mb')
	for sample in range(1, 6):
		for router in range(1, 6):
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
				b=dado.split(',')[4]
				fb=float(b)
				y.append(float(b))
			plt.yscale('linear')
			plt.plot(x, y, label=linkname[router-1])
			plt.xlabel('time')
		plt.ylabel('bytes total') 
		plt.legend(title='Link:', loc='lower left')
		plt.title('Redirecionamento de fluxo')
		current_values = plt.gca().get_yticks().tolist()
		plt.gca().set_yticklabels(['{:.0f}'.format(x) for x in current_values])
		print(f'Sample {sample}: OK')
		plt.savefig(f'results/run{run}/{taxa}.png')
		plt.clf()

