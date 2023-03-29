import matplotlib.pyplot as plt

for sample in range(0,10):
	f=open(f'a{sample}.log')
	linhas=f.readlines()
	f.close()

	y=[]
	x=[]
	cont=1
	for ms in linhas:
		x.append(cont)
		cont=cont+1
		y.append(float(ms))

	plt.plot(x, y)
	plt.xlabel('packet') 
	plt.ylabel('Latency (ms)') 
	plt.title(f'Sample{sample}')
	print(f'a{sample}: OK')
plt.savefig(f'test1.png')

