import matplotlib.pyplot as plt
import numpy

plt.rc('font', size=16)
plt.rc('axes', titlesize=16)
plt.rc('axes', labelsize=16)
plt.rc('xtick', labelsize=16)
plt.rc('ytick', labelsize=16)
plt.rc('legend', fontsize=10)
plt.rc('figure', titlesize=16)
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
for cont in range(0,len(y)):
	m.append(numpy.mean(y[cont]))

#plt.errorbar(x,m,yerr=d, fmt='-')
plt.plot(x, m, linewidth=1, marker='o', markersize=2 )
plt.xlabel('Tempo (s)') 
plt.ylabel('Latência (ms)') 
plt.title('Diminuição da latência com migração de túnel')
plt.savefig(f'test1.png')

