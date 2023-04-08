import matplotlib.pyplot as plt
import numpy

y=[]
x=[]
for sample in range(0,6):
	f=open(f'data/a{sample}.log')
	linhas=f.readlines()
	f.close()

	cont=0
	for ms in linhas:
		if sample==0:
			x.append(cont+1)
			y.append([])
		y[cont].append(float(ms))
		cont=cont+1
m=[]
d=[]
for cont in range(0,len(y)):
	m.append(numpy.mean(y[cont]))

#plt.errorbar(x,m,yerr=d, fmt='-')
plt.plot(x, m)
plt.xlabel('Tempo (s)') 
plt.ylabel('Latência (ms)') 
plt.title('Diminuição da latência com migração de túnel')
plt.savefig(f'test1.png')

