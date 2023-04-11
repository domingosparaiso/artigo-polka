# wpeif-2023

Os arquivos neste repositório foram usados na pesquisa usada na escrita do artigo a ser submetido ao evento WPEIF – XIV Workshop de Pesquisa Experimental da Internet do Futuro, edição de 2023.

## Organização dos arquivos

- \<artigo> - diretório contendo os experimentos do artigo
- \<simple> - diretório com uma topologia simples para testar o ambiente
- wpeif-2023.pdf - Artigo submetido ao workshop
- atualiza.sh - script para atualização das configurações das máquinas virtuais
- cfgnet.sh - script que configura os arquivos de hardware e software do RARE/freeRtr
- config_net_vbox.sh - script para criar e configurar todas as interfaces de rede das máquinas virtuais
- intnetmap.sh - refaz o mapeamento das redes internas, usado para trocar de topologia
- lista.txt - relação de arquivos que são copiados para as máquinas virtuais
- remove-all-nics.sh - script para remover todas as interfaces de rede das máquinas virtuais
- rtr.sh - script para inicializar o roteador RARE/freeRtr
- ssh_connection.txt - conexão da máquina virtual com a máquina física usada nos comandos ssh
- tcp-offload-off.sh - reconfigura as interfaces ethernet com os parâmetros necessários para o RARE/freeRtr

## Preparação do ambiente

* Instale uma máquina virtual com 20Gb de HD no VirtualBox com Debian 11 que servirá de modelo para as outras.

  - nota: não precisa se preocupar com as interfaces de rede neste momento, elas serão configuradas depois.


* Inicie a máquina virtual modelo e instale os pacotes que achar necessários (net-tools, tcpdump, etc...)

* Atualize os pacotes do Debian com "apt update" e "apt upgrade".

* Crie um par de chaves com o usuário root para ser usado no SSH com o comando a seguir:
```
guest$ ssh-keygen -b 1024 -t rsa
```
  - nota: Pressione \<ENTER\> em todas as opções.
  - nota: Ao criar a chave antes de clonar, todas as máquinas irão compartilhar a mesma chave.

* Importe a chave pública gerada no modelo para o SO guest que executa o VirtualBox inserindo o conteúdo do arquivo da VM /root/.ssh/id_rsa.pub no final do arquivo ~/.ssh/authorized_keys do guest. Fazendo isso o script de atualização vai conseguir copiar os arquivos sem precisar informa a senha.


* Clone a máquina de modelo para gerar os hosts antes de instalar o FreeRtr.

  - nota: o processo de clonagem pode ser feito clonando a máquina toda ou podemos clonar só o disco e criar novas máquinas que vão usar estes discos clonados.

  
* Na máquina modelo, instale o FreeRtr no diretório '/rtr'.


* Copie os arquivos 'atualiza.sh' e 'ssh_connection.txt' para o diretório '/rtr' da máquina modelo.


* Clone a máquina modelo para gerar os roteadores core e edge.

  - nota: As máquinas usadas nas topologias são:
    - simple: core1, edge1, edge2, host1 e host2
    - artigo: core1, core2, core3, core4, core5, edge1, edge2, host1 e host2

  - nota: Instale o Debian 11 sem a interface gráfica, apenas com os pacotes básicos.
  - nota: Baixe o instalador do RARE/freeRtr e execute com o usuário root.

* Entre em cada máquina e altere o nome, para facilitar o processo, use os comandos do exemplo a seguir.

```
modelo:~# cd /rtr
modelo:/rtr# ./atualiza.sh -h core1
```

* Ao concluir a criação de todas as máquinas virtuais, com as máquinas desligadas, execute no guest o script 'remove-nic.sh', ele vai remover todas as configurações de placas de rede das máquinas virtuais deixando preparadas para a configuração da topologia.


* Execute o script 'config_net_vbox.sh' informando o diretório onde está o arquivo 'networks.txt' que você deseja configurar, para a topologia 'simple' este é o nome do diretório mas para a topologia do artigo informe também o teste que deseja configurar, exemplo: 'artigo/test1'. O script vai configurar as interfaces de rede de todas as máquinas virtuais e inserir as configurações das redes internas usando as informações do arquivo 'network.txt', neste arquivo estão indicadas os nomes das VMs, as interfaces que serão ativadas, seus MAC Address e a rede onde elas serão configuradas, caso o nome da rede seja NAT a interface será configurada como NAT no VirtualBox e inseridos Port-Forward para os protocolos SSH e TELNET, caso contrário será configurada como Internal Network e o nome especificado será o nome da rede interna.


* Inicie as máquinas virtuais que serão usadas na topologia escolhida.


* Nas máquinas host1 e host2 é necessário incluir uma rota para que elas se conversem usando a topologia através dos edges, isso é feito configurando um IP estático na segunda interface de rede e incluindo a rota para a outra rede usando o edge como gateway, segue os exemplos para o host1, depois faça o mesmo para o host2 alterando os IPs.

  - Edite o arquivo '/etc/network/interfaces' e inclua o IP estático na configuração:
```
auto enp0s8
iface enp0s8 inet static
    address 40.40.1.2/24
```
  - Crie o arquivo '/etc/network/if-up.d/rota_rede_interna' com o conteúdo abaixo, depois altere a permissão com o comando "chmod 751 rota_rede_interna":
```
#!/bin/bash
if [ "${IFACE}" = "enp0s8" ]; then
    ip route del 40.40.2.0/24 via 40.40.1.1
    ip route add 40.40.2.0/24 via 40.40.1.1
fi
```


* Em cada máquina virtual, entre no diretório '/rtr' execute o script 'atualiza.sh' informando a topologia que deseja usar (simple ou artigo), para o artigo informe também o nome do experimento (test1, test2 ou test3), depois da primeira vez que for informada a topologia essa informação será armazenada e não precisa ser informada novamente a menos que se deseje trocar de topologia.


* Ao executar o script 'atualiza.sh', ele vai baixar o arquivo 'lista.txt' que contém a relação de arquivos que devem ser copiados. Na lista, quando o nome de um arquivo possui a expressão {TOPOLOGIA} antes do nome, ele é copiado a partir do diretório da topologia que será instalada, caso contrário vem do diretório 'wpeif-2023'. Após a cópia, o script 'cfgnet.sh' é executado para gerar os arquivos de hardware e software a partir dos templates baixados.


* As interfaces do Linux são mapeadas nas interfaces do RARE/freeRtr pelo arquivo 'interface_map.txt' dentro do diretório da topologia, em algumas situações as interfaces do Linux mudaram de nome, atualmente estão com os nome enp0s3, enp0s8, enp0s9, enp0s10, enp0s16, etc... mas já ocorreram casos em que mudaram para eth0, eth1, eth2, eth3, eth4, etc... caso as interfaces mudem de nome nas máquinas virtuais, basta editar o arquivo de mapeamento. Cada linha do arquivo possui um mapa contendo o nome da interface real e o nome da interface do RARE/freeRtr separados por ":", exemplo "enp0s8:eth1".


* Os arquivos de template de hardware possuem o nome no formato "template-\<nome do host\>-hw.txt", onde \<nome do host\> é o nome da máquina Linux, exemplo "router1". No template podemos usar os valores {eth1_MAP} que será substituído pelo nome da interface real mepeada para ethernet1 do FreeRtr e {eth1_MAC} que será substituído pelo Mac Address da interface.


* Além do mapeamento das interfaces, o arquivo de harware também precisa saber os MAC Address de cada interface, para facilitar a manutenção do arquivo, estou usando templates para cada roteador e um script que substitui as marcações pelos nomes das interfaces reais e seus MAC Address.

  - O arquivo de hardware é gerado em '/rtr/router-hw.txt' e o arquivo de software em '/rtr/router-sw.txt'.

    - IMPORTANTE: Originalmente eu estava trabalhando com o arquivo de hardware rtr-hw.txt, mas sempre que o Linux é reiniciado, ao subir o serviço "rtr" o arquivo de configuração é carregado e as linhas "proc" são executadas criando os processos com o mapeamento das interfaces pelo MAC. Ao iniciar o FreeRtr manualmente para testar a configuração ele não consegue subir outro processo com as mesmas portar, dessa forma ele fica apresentando mensagem de erro e tentando novamente subir o processo. As soluções possíveis são (a) remover as linhas "proc" do arquivo de hardware, pois o FreeRtr já deixou os processos rodando ou (b) trabalhar com um arquivo de hardware usando outro nome. Adotei a segunda solução colocando a configuração no arquivo router-hw.txt.


* Para inicializar o RARE/freeRtr usamos o script 'rtr.sh', antes de carregar o roteador ele reconfigura as interfaces de rede que não são loopback nem estão na rede NAT usando o script 'tcp-offload-off.sh', isso garante que as interfaces ethernet estão com os devidos parâmetros necessários para o RARE/freeRtr.
