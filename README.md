# artigo-polka


1) Preparação do ambiente:

Instale uma máquina virtual com 20Gb de HD no VirtualBox com Debian 11 que servirá de modelo para as outras.

  nota: não precisa se preocupar com as interfaces de rede neste momento, elas serão configuradas depois.


Inicie a máquina virtual modelo e instale os pacotes que achar necessários (net-tools, tcpdump, etc...)

Atualize os pacotes do Debian com "apt update" e "apt upgrade".

Crie um par de chaves com o usuário root para ser usado no SSH com o comando a seguir:
- ssh-keygen -b 1024 -t rsa
  nota: Pressione \<ENTER\> em todas as opções.
  nota: Ao criar a chave antes de clonar, todas as máquinas irão compartilhar a mesma chave.

Importe a chave pública gerada no modelo para o SO guest que executa o VirtualBox inserindo o conteúdo do arquivo da VM /root/.ssh/id_rsa.pub no final do arquivo ~/.ssh/authorized_keys do guest. Fazendo isso o script de atualização vai conseguir copiar os arquivos sem precisar informa a senha.

  
Clone a máquina de modelo para gerar os hosts antes de instalar o FreeRtr.

  nota: o processo de clonagem pode ser feito clonando a máquina toda ou podemos clonar só o disco e criar novas máquinas que vão usar estes discos clonados.

  
Na máquina modelo, instale o FreeRtr no diretório '/rtr'.


Copie o arquivo 'atualiza.sh' para o diretório '/rtr' da máquina modelo.


Edite o script 'atualiza.sh' alterando o IP, usuário e caminho no guest que contém os arquivos desse repositório.


Clone a máquina modelo para gerar os roteadores core e edge.

nota: As máquinas usadas nas topologias são:
- simple: core1, edge1, edge2, host1 e host2
- artigo: core1, core2, core3, core4, core5, edge1, edge2, host1 e host2

nota: Não entrei nos detalhes de como instalar o Debian 11 e o FreeRtr nele, para informações sobre esse passo veja os sites dos respectivos projetos.


Ao concluir a criação de todas as máquinas virtuais, com as máquinas desligadas, execute no guest o script 'remove-nic.sh', ele vai remover todas as configurações de placas de rede das máquinas virtuais deixando preparadas para a configuração da topologia.


Execute o script './config_net_vbox.sh \<topologia\>', ele vai configurar as interfaces de rede de todas as máquinas virtuais já inserindo as configurações das redes internas usando as informações do arquivo 'network.txt' dentro do diretório da topologia escolhida, neste arquivo estão indicadas os nomes das VMs, as interfaces que serão ativadas, seus MAC Address e a rede onde elas serão configuradas, caso o nome da rede seja NAT a interface será configurada como NAT no VirtualBox e inseridos Port-Forward para os protocolos SSH e TELNET, caso contrário será configurada como Internal Network e o nome especificado será o nome da rede interna.


Inicie as máquinas virtuais que serão usadas na topologia escolhida.


Nas máquinas host é necessário inclui uma rota para que elas se conversem usando a topologia pelos edges, isso é feito configurando um IP estático na segunda interface de rede e incluindo a rota para a outra rede usando o edge como gateway, segue os exemplos para o host1, depois faça o mesmo para o host2 alterando os IPs.

Edite o arquivo '/etc/network/interfaces' e inclua o IP estático na configuração:
```
auto enp0s8
iface enp0s8 inet static
    address 40.40.1.2/24
```
Crie o arquivo '/etc/network/if-up.d/rota_rede_interna' com o conteúdo abaixo, depois altere a permissão com o comando "chmod 751 rota_rede_interna":
```
#!/bin/bash
if [ "${IFACE}" = "enp0s8" ]; then
    ip route del 40.40.2.0/24 via 40.40.1.1
    ip route add 40.40.2.0/24 via 40.40.1.1
fi
```

Em cada máquina virtual, entre no diretório '/rtr' execute o script 'atualiza.sh' informando a topologia que deseja usar (simple ou artigo), depois da primeira vez que for informada a topologia essa informação será armazenada e não precisa ser informada novamente a menos que se deseje trocar de topologia.


Ao executar o script 'atualiza.sh', ele vai baixar o arquivo 'lista.txt' que contém a lista de arquivos que serão copiados (na lista quando o nome do arquivo possui {TOPOLOGIA} antes do nome, ele é copiado de dentro do diretório da topologia que será instalada. Após a cópia, o script 'cfgnet.sh' é executado para gerar os arquivos de hardware e software a partir dos templates baixados.


As interfaces do Linux são mapeadas nas interfaces do FreeRtr pelo arquivo 'interface_map.txt' dentro do diretório da topologia, em algumas situações as interfaces do Linux mudaram de nome, atualmente estão com os nome enp0s3, enp0s8, enp0s9, enp0s10, enp0s16, etc... mas em alguma situação mudaram para eth0, eth1, eth2, eth3, eth4, etc... caso as interfaces mudem de nome nas máquinas virtuais, basta editar o arquivo de mapeamento. Cada linha do arquivo possui um mapa contendo o nome da interface real e o nome da interface do FreeRtr separadas por ":", exemplo "enp0s8:eth1".


Os arquivos de template de hardware possuem o nome no formato "template-\<nome do host\>-hw.txt", onde \<nome do host\> é o nome da máquina Linux, exemplo "router1". No template podemos usar os valores {eth1_MAP} que será substituído pelo nome da interface real mepeada para ethernet1 do FreeRtr e {eth1_MAC} que será substituído pelo Mac Address da interface.


Além do mapeamento das interfaces, o arquivo de harware também precisa dos MAC Address de cada interface, para facilitar a manutenção do arquivo, estou usando templates para cada roteador e um script que atualiza substitui as marcações pelos nomes das interfaces reais e seus MAC Address.
O arquivo de hardware é gerado em '/rtr/router-hw.txt' e o arquivo de software em '/rtr/router-sw.txt'.


IMPORTANTE: Originalmente eu estava trabalhando com o arquivo de hardware rtr-hw.txt, mas sempre que o Linux é reiniciado, ao subir o serviço "rtr" o arquivo de configuração é carregado e as linhas "proc" são executadas criando os processos com o mapeamento das interfaces pelo MAC. Ao iniciar o FreeRtr manualmente para testar a configuração ele não consegue subir outro processo com as mesmas portar, dessa forma ele fica apresentando mensagem de erro e tentando novamente subir o processo. As soluções possíveis são (a) remover as linhas "proc" do arquivo de hardware, pois o FreeRtr já deixou os processos rodando ou (b) trabalhar com um arquivo de hardware usando outro nome. Adotei a segunda solução colocando a configuração no arquivo router-hw.txt.


Durante a inicialização do script 'rtr.sh' as interfaces de rede que não são loopback nem estão na rede NAT, serão configuradas pelo script 'tcp-offload-off.sh'.


A topologia mais básica está no diretório "simple", 2 hosts conectados por 2 edges e 1 core.


A topologia do arquivo está no diretório "artigo", 2 hosts conectador por 2 edges e 5 cores.


Os detalhes de cada topologia estão mostrados nos arquivos simple.png e artigo.png.
