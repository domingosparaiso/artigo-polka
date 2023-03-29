import matplotlib.pyplot as plt


#csv output format: Type rate:
#unix timestamp;iface_name;bytes_out/s;bytes_in/s;bytes_total/s;bytes_in;bytes_out;packets_out/s;packets_in/s;packets_total/s;packets_in;packets_out;errors_out/s;errors_in/s;errors_in;errors_out\n

for taxa in [ 100, 200, 300, 400, 500, 600, 700, 800 ]:
	for sample in range(1,11):
		f=open(f'{taxa}/a{sample}.csv')
		linhas=f.readlines()
		f.close()

		y=[]
		x=[]
		cont=1
		for dado in linhas:
			x.append(cont)
			cont=cont+1
			b=dado.split(',')[4]
			fb=float(b)/1024/1024
			if cont==20:
				print(fb)
			y.append(float(b))
		plt.plot(x, y)
		plt.xlabel('cont') 
		plt.ylabel('bytes total') 
		plt.title(f'Sample{sample}')
		print(f'a{sample}: OK')
	plt.savefig(f'test2-{taxa}.png')

