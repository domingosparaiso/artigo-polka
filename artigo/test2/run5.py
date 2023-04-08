import matplotlib.pyplot as plt

run=5
#csv output format: Type rate:
#unix timestamp;iface_name;bytes_out/s;bytes_in/s;bytes_total/s;bytes_in;bytes_out;packets_out/s;packets_in/s;packets_total/s;packets_in;packets_out;errors_out/s;errors_in/s;errors_in;errors_out\n

for taxa in range(10, 50, 10):
	for sample in range(1, 21):
		arq=f'data/run{run}/{taxa}/a{sample}.csv'
		print(arq)
		f=open(arq)
		linhas=f.readlines()
		f.close()

		y=[]
		x=[]
		cont=1
		for dado in linhas:
			x.append(cont)
			cont=cont+1
			b=dado.split(',')[2]
			fb=float(b)/1024/1024
			if cont==20:
				print(fb)
			y.append(float(b))
		plt.plot(x, y)
		print(f'a{sample}: OK')
	plt.xlabel('tempo (s)') 
	plt.ylabel('taxa de transferência (bytes/s)') 
	plt.title(f'Fluxo de dados')
	current_values = plt.gca().get_yticks().tolist()
	plt.gca().set_yticklabels(['{:.0f}'.format(x) for x in current_values])
	plt.savefig(f'results/run{run}/{taxa}.png')
	plt.clf()

