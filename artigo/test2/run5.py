import matplotlib.pyplot as plt
import numpy

run=5
#csv output format: Type rate:
#unix timestamp;iface_name;bytes_out/s;bytes_in/s;bytes_total/s;bytes_in;bytes_out;packets_out/s;packets_in/s;packets_total/s;packets_in;packets_out;errors_out/s;errors_in/s;errors_in;errors_out\n

for taxa in [40]:
	x = []
	y = []
	for sample in range(1, 21):
		arq=f'data/run{run}/{taxa}/a{sample}.csv'
		print(arq)
		f=open(arq)
		linhas=f.readlines()
		f.close()

		cont=1
		for dado in linhas:
			if sample == 1:
				x.append(cont)
				y.append([])
			b=dado.split(',')[2]
			fb=float(b)/1024/1024*8
			y[cont-1].append(fb)
			cont=cont+1
			if cont > 177:
				break
	m=[]
	for cont in range(0,len(y)):
		m.append(numpy.mean(y[cont]))
	plt.plot(x, m)
	print(f'a{sample}: OK')
	plt.xlabel('Tempo (s)') 
	plt.ylabel('Vazão (Mbps)') 
	plt.title(f'Reação a falhas com migração de túnel')
	#current_values = plt.gca().get_yticks().tolist()
	#plt.gca().set_yticklabels(['{:.0f}'.format(x) for x in current_values])
	plt.savefig(f'results/run{run}/{taxa}.png')
	plt.clf()

