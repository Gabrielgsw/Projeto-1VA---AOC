.data                                                                                                                   

arquivo: .asciiz "C:\\Users\\Gabriel Germano\\Desktop\\Projeto1-AOC\\output.txt"
info_geral_print: .asciiz "Nao vazios:    xxxx (xxx%)\nVazios:        xxxx (xxx%)\n"
info_apartamento: .asciiz "all"
cmd_5_limpar_ap_fn: .asciiz "limpar_ap-<apt>\n"

input_file: .space 1000000

.text
.globl ad_morador_fn,info_geral_fn, rm_morador_fn, ad_auto_fn, salvar_fn, rm_auto_fn, recarregar_fn, formatar_fn, info_ap_fn, arquivo
    

######################################################### CMD_1 ######################################################### 
# adiciona um morador a um apartamento: ad_morador-<ap>-<nome>
ad_morador_fn:                                              

# extrair e valida o numero do apartamento
    addi $a0, $zero, 1                                      # extrai a opcao 1 (numero do ap)
    la   $a1, input                                         # input recebido do terminal
    jal  get_funcao                                         # extrai string da opcao 1
    move $a0, $v0                                           # $a0 endereco da string

    jal  str_to_int                                         # converte string para inteiro
    move $a0, $a0                                           # $a0 libera a string da heap
    jal  free

    move $a0, $v0                                           # $a0 numero do apartamento
    jal  get_indice_ap                                      # obtem o indice (0-39) do vetor de apartamentos
    move $t0, $v0                                           # $t0 indice do apartamento

    bltz $v0, invalid_ap                                    # se indice < 0, apartamento invalido -> aborta

# localizar endereco do apartamento na memoria
    la   $t4, building                                      # endereco base da estrutura building
    li   $t1, 40                                            # cada apartamento ocupa 40 bytes
    addi $t0, $t0, -1                                       # ajusta indice para base 0
    mult $t0, $t1                                           # calcula offset do apartamento
    mflo $t2
    add  $t4, $t4, $t2                                      # $t4: endereco do apartamento desejado

# checar se ainda ha vagas para moradores
    addi $t5, $t4, 4                                        # $t5: endereco do numero de moradores
    lw   $t6, 0($t5)                                        # $t6: numero de moradores
    bge  $t6, 5, limite_moradores                           # se ja houver 5 moradores -> aborta

# incrementar numero de moradores
    lw   $t3, 0($t5)                                        # $t3: numero de moradores
    addi $t3, $t3, 1                                        # $t3 = $t3 + 1
    sw   $t3, 0($t5)                                        # atualiza numero de moradores

# buscar slot vazio para novo morador
    addi $t5, $t5, 4                                        # $t5: endereco do primeiro slot de morador
    add  $t7, $t5, 28                                       # $t7: limite superior (ultimo slot)

busca_espaco_vazio:                                           # inicio da busca por slot vazio
# verificar se ha espaco disponivel antes de comecar a varredura
    bge  $t5, $t7, ap_return_exception                     # se nao houver espaco, erro inesperado

buscar_slot:
    lw   $t6, 0($t5)                                        # carrega conteudo do slot atual
    beq  $t6, $zero, slot_livre                             # se estiver vazio, ir para slot_livre
    addi $t5, $t5, 4                                        # avanca para proximo slot
    blt  $t5, $t7, buscar_slot                              # continua enquanto nao atingir o fim
    j    ap_return_exception                               # se passou do limite, erro inesperado

slot_livre:                                                 # slot vazio encontrado
    li   $a0, 2                                             # extrai a segunda opcao do input (nome)
    la   $a1, input
    jal  get_funcao
    sw   $v0, 0($t5)                                        # armazena nome no slot livre
    j    adicionar_morador                             	    # finaliza processo

      
  
######################################################### CMD_2 ######################################################### 
# remove um morador de um apartamento: rm_morador-<apartamento>-<nome do morador>
rm_morador_fn:                                              

# validar numero de apartamento
    li $a0, 1                                               # extrai opcao 1 (numero do ap)
    la $a1, input
    jal get_funcao
    move $a0, $v0                                           # endereco da string do numero do ap

    jal str_to_int                                          # converte string para inteiro
    move $a0, $v0                                           # valor inteiro do numero do ap
    jal get_indice_ap                                       # converte para indice
    bltz $v0, invalid_ap                              	    # aborta se indice invalido

    move $t0, $v0                                           # $t0: indice do apartamento

# calcular endereco do apartamento
    la $t4, building                                        # $t4: endereco base da estrutura building
    li $t1, 40                                              # cada apartamento tem 40 bytes
    addi $t0, $t0, -1
    mult $t0, $t1
    mflo $t2
    add $t4, $t4, $t2                                       # $t4: aponta para o apartamento desejado

# verificar se ha moradores
    lw $t6, 4($t4)                                          # carrega numero de moradores
    blez $t6, ap_vazio_erro                                 # se zero ou negativo, aborta

# extrair nome do morador
    li $a0, 2                                               # extrai opcao 2 (nome do morador)
    la $a1, input
    jal get_funcao
    move $a0, $v0                                           # $a0: string do nome

# passar pela lista de moradores
    addi $t5, $t4, 8                                        # $t5: inicio da lista de moradores
    addi $t7, $t5, 28                                       # $t7: limite (8 + 28 = 36)

busca_morador_loop:
    bge $t5, $t7, morador_nao_encontrado                    # chegou ao fim, nao encontrou
    lw $t6, 0($t5)                                          # carrega slot do morador
    beqz $t6, proximo_morador                               # se slot vazio, tenta proximo

    move $a1, $t6                                           # $a1: string do morador salvar
    jal strcmp
    beqz $v0, remover_morador_auxiliar                      # se bateu, vai remover

proximo_morador:
    addi $t5, $t5, 4                                        # proximo slot
    j busca_morador_loop

morador_nao_encontrado:
    j morador_inexistente                                   # exibe erro e volta ao inicio

# remover morador
remover_morador_auxiliar:
    sw $zero, 0($t5)                                        # limpa slot de morador

    lw $t3, 4($t4)                                          # atualiza numero de moradores
    addi $t3, $t3, -1
    sw $t3, 4($t4)

    blez $t3, limpar_automoveis                             # se zero moradores, limpa veiculos
    j remover_morador

# limpar veiculos se necessario
limpar_automoveis:
    sw $zero, 28($t4)                                       # veiculo 1
    sw $zero, 32($t4)                                       # veiculo 2
    sw $zero, 36($t4)                                       # flag de automoveis

    j remover_morador

######################################################### CMD_3 ######################################################### 
# adiciona um automovel no apartamento: ad_auto-<apartamento>-<tipo>-<modelo>-<cor>
ad_auto_fn:

# validar numero do apartamento
    addi $a0, $zero, 1             			    # opcao 1: indice 1 da entrada = numero do apartamento
    la   $a1, input                			    # endereco do input
    jal  get_funcao             			    # extrai string do numero do AP e coloca em $v0

    move $a0, $v0                  			    # $a0: ponteiro para string do numero
    jal  str_to_int                			    # converte string para inteiro -> retorna em $v0

    move $a0, $a0
    jal  free                      			    # libera a string do numero da heap

    move $a0, $v0                  			    # $a0: numero inteiro do apartamento
    jal  get_indice_ap              			    # converte numero para indice interno da estrutura
    bltz $v0, invalid_ap     			 	    # se indice < 0, apartamento e invalido

    move $t0, $v0                  			    # salva o indice valido em $t0
    la   $t4, building             			    # carrega endereco base da estrutura 'building'

# calcular endereco da estrutura do apartamento
    addi $t1, $zero, 40            			    # cada AP ocupa 40 bytes
    addi $t0, $t0, -1              			    # indice da estrutura comeca em 0
    mult $t0, $t1
    mflo $t2                       			    # $t2: offset do AP
    add  $t4, $t4, $t2             			    # $t4: endereco do apartamento dentro da estrutura

    lw $t9, 4($t4)                 			    # verifica se o apartamento tem moradores
    beqz $t9, add_automovel_vazio     			    # se nao tiver, pula para rotina de AP vazio

    addi $t4, $t4, 28             			    # avanca para a area de automoveis na estrutura do AP

# verificar espaco para automoveis
    lw   $t7, 8($t4)               			    # $t7: flag de quantidade de veiculos (1 = carro, 2/3 = motos)
    beq  $t7, 1, limite_vagas    			    # se ja tem um carro, nao pode adicionar mais

    li   $a0, 2
    la   $a1, input
    jal  get_funcao             			    # extrai o tipo do veiculo (opcao 2)
    move $t0, $v0                  			    # $t0: ponteiro para string 'c' ou 'm'
    move $t2, $t0                  	  		    # guarda para liberar depois
    lb   $t0, 0($t0)               			    # carrega caractere da opcao: 'c' ou 'm'

    move $a0, $t2
    jal  free                      			    # libera a string da heap

    li   $t1, 99                   			    # ASCII de 'c'
    beq  $t0, $t1, se_carro        			    # se for 'c', pula para rotina de carro

    li   $t1, 109                  			    # ASCII de 'm'
    beq  $t0, $t1, se_moto         			    # se for 'm', pula para rotina de moto

    j    veiculo_invalido              			    # tipo invalido

# logica de insercao de carro
se_carro:
    lw   $t7, 8($t4)               			   # verifica flag de quantidade de veiculos
    bgtz $t7, limite_vagas        			   # ja tem carro/moto? nao cabe
    li   $t7, 1                    			   # flag 1 = 1 carro
    sw   $t7, 8($t4)               			   # grava flag
    j    salvar_automovel         			   # continua para alocar dados do carro

# logica de insercao de moto
se_moto:
    lw   $t7, 8($t4)               			   # le flag de quantidade de veiculos
    beqz $t7, add_moto_1       			   # nenhum veiculo ainda? adiciona primeira moto
    li   $t8, 3
    beq  $t7, $t8, limite_vagas   			   # ja tem 2 motos? nao cabe mais
    li   $t8, 2
    beq  $t7, $t8, add_moto_2 			   # tem uma moto? vai adicionar a segunda

    j    veiculo_invalido              			   # se nao for nenhuma das condicoes, invalido

add_moto_1:
    li   $t7, 2                    			   # flag 2 = 1 moto
    sw   $t7, 8($t4)               			   # salva flag
    j    salvar_automovel

add_moto_2:
    li   $t7, 3                    			   # flag 3 = 2 motos
    sw   $t7, 8($t4)             			   # salva nova flag
    addi $t4, $t4, 4               			   # pula para segundo slot de moto
    j    salvar_automovel

# alocar memoria e copiar dados do automovel
salvar_automovel:
    la   $a0, input
    jal  get_tamanho_str              			   # retorna tamanho da string de entrada
    move $a0, $v0
    addi $a0, $a0, -11             			   # ignora prefixo 'ad_auto-' (11 chars)

    li   $v0, 9
    syscall                        			   # aloca espaco na heap
    sw   $v0, 0($t4)               			   # salva o endereco do automovel no slot apropriado

    move $a2, $a0                  			   # $a2: tamanho
    move $a0, $v0                  			   # $a0: destino
    la   $a1, input
    addi $a1, $a1, 11              			   # $a1: fonte, ignora "ad_auto-"
    jal  memcpy                    			   # copia modelo e cor para a heap

    j    adicionar_automovel             		   # finaliza procedimento
    
######################################################### CMD_4 ######################################################### 
# remove um automóvel de um apartamento: rm_auto-<apartamento>-<tipo>-<modelo>-<cor>
rm_auto_fn:

# extrair o numero do apartamento (opcao 1 do input)
    li $a0, 1
    la $a1, input
    jal get_funcao
    move $t0, $v0             				   # $t0: ponteiro para string com o numero do apartamento
    li $t9, 0                 				   # $t9: indicar se estamos tratando a segunda moto

# converter numero do apartamento para inteiro
    move $a0, $t0
    jal str_to_int
    move $a0, $t0
    jal free                  				   # libera a string da heap

    move $a0, $v0             				   # passa o numero convertido como inteiro
    jal get_indice_ap          				   # retorna o indice do apartamento
    bltz $v0, invalid_ap  				   # se indice < 0, apartamento invalido

    move $t0, $v0             				   # $t0: indice do apartamento

# calcular endereco do apartamento na estrutura 'building'
    la $t4, building
    li $t1, 40                				   # cada apartamento ocupa 40 bytes
    addi $t0, $t0, -1         				   # indice comeca em 0
    mult $t0, $t1
    mflo $t2
    add $t4, $t4, $t2         				   # $t4 agora aponta para o apartamento
    addi $t4, $t4, 28         				   # avanca para a area de automoveis

# extrair tipo do automovel (opcao 2 do input)
    li $a0, 2
    la $a1, input
    jal get_funcao
    move $t2, $v0            				   # $t2: string com 'c' ou 'm'
    lw $t0, 0($t2)           				   # $t0: caractere (ASCII) 'c' ou 'm'
    move $a0, $t2
    jal free                				   # libera a string

# verificar se o tipo ao 'c' (carro) ou 'm' (moto)
    li $t1, 99   					   # ASCII de 'c'
    li $t3, 109  					   # ASCII de 'm'
    beq $t0, $t1, check_car
    beq $t0, $t3, check_moto
    j veiculo_invalido             			   # tipo invalido

# checar se pode remover CARRO
check_car:
    lw $t2, 8($t4)            				   # carrega flag de veiculos
    beqz $t2, sem_aut
    li $t3, 1
    bne $t2, $t3, tipo_nao_confere  			   # flag diferente de 1 -> nao carro
    j verificar_dados_auto

# checar se pode remover MOTO 
check_moto:
    lw $t2, 8($t4)            				   # carrega flag
    li $t3, 2
    beq $t2, $t3, verificar_dados_auto   		   # 1 moto
    li $t3, 3
    beq $t2, $t3, verificar_dados_auto  		   # 2 motos
    j sem_aut         		   # nenhum veiculo ou tipo errado

# tipo solicitado nao corresponde ao que ha no AP
tipo_nao_confere:
    la $a0, cmd_4_exception      				   # mensagem: tipo nao confere
    jal print_str
    j start

# verificar se modelo e cor coincidem com o veiculo salvar
verificar_dados_auto:
# extrair modelo do input (opcao 3)
    li $a0, 3
    la $a1, input
    jal get_funcao
    move $t6, $v0             				   # $t6: modelo informado pelo usuario

# extrair modelo salvar na heap do veiculo
    li $a0, 2
    lw $a1, 0($t4)            				   # $a1: endereco do automovel
    jal get_funcao
    move $t7, $v0

# comparar modelo
    move $a0, $t6
    move $a1, $t7
    jal strcmp
    bnez $v0, auto_nao_encontrado  			   # modelos nao coincidem

# extrair cor do input (opcao 4)
    li $a0, 4
    la $a1, input
    jal get_funcao
    move $t6, $v0             				   # $t6: cor informada

# extrair cor salva
    li $a0, 3
    lw $a1, 0($t4)
    jal get_funcao
    move $t7, $v0

# comparar cor
    move $a0, $t6
    move $a1, $t7
    jal strcmp
    bnez $v0, auto_nao_encontrado  			   # cor nao coincide

# ambos modelo e cor coincidem -> remove veiculo
    lw $a0, 0($t4)
    jal free                   				   # libera heap do automovel
    sw $zero, 0($t4)           				   # zera ponteiro

# decidir como atualizar a flag de veiculos
    blt $t2, 3, limpar_flag         		           # so 1 veiculo (carro ou 1 moto)
    beq $t2, 3, remover_duas_motos 			   # 2 motos
    j remover_automovel

# limpar flag quando so havia um veicculo
limpar_flag:
    sw $zero, 8($t4)           				   # flag = 0 (sem veiculos)
    j remover_automovel

# caso haja 2 motos, reorganiza
remover_duas_motos:
    li $t8, 2                  				   # nova flag: apenas 1 moto
    bnez $t9, limpar_moto_2  			   # se ja estamos na segunda moto
    sw $t8, 8($t4)             				   # atualiza flag
    lw $t8, 4($t4)             				   # move a segunda moto para a primeira posicao
    sw $zero, 4($t4)           				   # limpa segunda posicao
    sw $t8, 0($t4)
    j remover_automovel

# limpar a segunda moto diretamente
limpar_moto_2:
    sw $t8, 4($t4)             				   # $t8: aqui e a flag 2 (1 moto)
    j remover_automovel

# caso modelo/cor da primeira moto nao coincidam, tenta a segunda
remover_moto_2:
    addi $t4, $t4, 4           				   # vai para segunda moto
    addi $t9, $t9, 1           				   # marca que estamos tratando a segunda
    j verificar_dados_auto

# erro: nao ha¡ veiculo no apartamento
sem_aut:
    la $a0, sem_aut_exception
    jal print_str
    j start

# erro: modelo ou cor nao coincidem
auto_nao_encontrado:
    bnez $t9, fim_nao_encontrado    			   # ja testamos a segunda moto? entao fim
    lw $t8, 8($t4)
    li $t1, 3
    beq $t8, $t1, remover_moto_2 			   # tenta a segunda moto se houver 2
                                      			   # caso contrario

# exibe erro: automovel nao encontrado
fim_nao_encontrado:
    la $a0, cmd_4_exception
    jal print_str
    j start


######################################################### CMD_5 ######################################################### 
#limpa o apartamento no codigo: limpar_ap-<apartamento>
limpar_ap_fn:                                              # funcao chamada no comando limpar_ap-<ap>
    addi $a0, $zero, 1                                     # carrega indice da opcao 1 (numero do apartamento)
    la   $a1, input                                        # carrega o endereco da string de input
    jal  get_funcao                                        # extrai o valor da opcao
    move $a0, $v0                                          # move o endereco para $a0
    jal  str_to_int                                        # converte string para inteiro
    move $a0, $v0                                          # $a0: numero do apartamento
    jal  get_indice_ap                                     # obtem o indice do apartamento no vetor
    move $a0, $v0                                          # $a0: indice do apartamento

    jal  limpa_ap_aux                                  # chama metodo auxiliar para limpar
    j    start                                             # retorna ao inicio do programa


limpa_ap_aux:                                          # funcao auxiliar para limpar apartamento
    move $t0, $a0                                          # $t0: numero do apartamento (indice ja convertido)

# verificar se numero de apartamento esta dentro dos limites
    ble  $t0, $zero, erro_ap_invalido
    bgt  $t0, 40, erro_ap_invalido
    j    contador

erro_ap_invalido:
    li   $v0, 4
    la   $a0, invalid_ap                                   # carrega mensagem de erro
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    jal  print_str                                         # imprime erro
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    syscall                                                # chamada dummy, pode ser omitida
    jr   $ra

contador:
    la   $t4, building                                     # endereco base do vetor de apartamentos
    li   $t1, 40                                           # tamanho de cada apartamento
    addi $t0, $t0, -1                                      # converte numero para indice base 0
    mult $t0, $t1                                          # offset = ap_index * 40
    mflo $t2
    add  $t4, $t4, $t2                                     # $t4: aponta para o inicio do apartamento
    li   $t0, 9                                            # contador para limpar 9 posicoes (moradores + automoveis)

limpando_ap:
    addi $t4, $t4, 4                                       # avanca para proxima word (comeca ap's offset +8)
    addi $t0, $t0, -1                                      # decrementa contador
    sw   $zero, 0($t4)                                     # zera a word atual
    bnez $t0, limpando_ap                                  # se ainda nao terminou, continua loop

fim:
    jr $ra 

    
######################################################### CMD_6 ######################################################### 
#informacoes sobre o apartamento no codigo: info_ap-<apartamento>
info_ap_fn:

# pegar numero do apartamento do input (como string)
    addi $a0, $zero, 1              			   # ID da opcao do input (1)
    la $a1, input                   			   # endereco da string de entrada
    jal get_funcao              			   # chama funcao que retorna a string de input em $v0

    add $t0, $zero, $v0            			   # salva input em $t0

# verificar se o input e 'all' (mostrar todos os apartamentos)
    add $a0, $zero, $t0
    la $a1, info_apartamento      			   # string 'all'
    jal strcmp                     			   # compara $t0 e 'all'
    beqz $v0, info_ap_all          			   # se iguais, pula para mostrar todos os apartamentos

# input e um numero (mostrar apenas um apartamento)
    add $a0, $zero, $t0
    jal str_to_int                 			   # converte string para inteiro

    add $a0, $zero, $a0
    jal free                       			   # libera memoria da string

    add $a0, $zero, $v0
    jal get_indice_ap               			   # converte numero do apartamento para indice

    add $t0, $zero, $v0
    bltz $v0, invalid_ap     				   # se indice for invalido (< 0), aborta

# acessar estrutura do apartamento
    la $t4, building               			   # endereco base da estrutura dos apartamentos
    addi $t1, $zero, 40            			   # tamanho de um apartamento (em bytes)
    addi $t0, $t0, -1              			   # ajusta o indice (comeca em 1)

    mult $t0, $t1
    mflo $t2                       			   # $t2: offset do apartamento
    add $t4, $t4, $t2             			   # $t4: endereco do apartamento

    jal info_ap_one               			   # chama a funcao para imprimir os dados
    j start                        			   # retorna ao inicio do programa

info_ap_all:

    li $t9, 40                     			   # numero total de apartamentos
    la $t4, building               			   # endereco do primeiro apartamento

info_ap_all_loop:
    beqz $t9, fim_info_loop_aps  			   # se contador zerar, fim do loop
    addi $t9, $t9, -1              			   # decrementa contador
    jal info_ap_one               			   # imprime dados do apartamento atual
    addi $t4, $t4, 40              			   # avanca para o proximo apartamento
    j info_ap_all_loop            			   # loop

fim_info_loop_aps:
    j start                        			   # volta ao inicio do programa

info_ap_one:

    addi $sp, $sp, -4              			   # salva RA na pilha
    sw $ra, 0($sp)

# imprimir numero do apartamento
    jal new_line
    jal ap

    lw $t3, 0($t4)                 			   # $t3: numero do apartamento
    add $a0, $t3, $zero
    li $a1, 4
    la $a2, int_to_str_buffer
    jal int_to_str              			   # converte numero para string

    la $a0, int_to_str_buffer
    jal print_str                  			   # imprime o numero
    jal new_line

# verificar se o apartamento esta vazio
    addi $t5, $t4, 4               			   # endereco do numero de moradores
    lw $t6, 0($t5)
    beqz $t6, apartamento_vazio      			   # se zero, apartamento vazio

print_tenants:
    jal moradores            				   # imprimir 'Moradores:'

    add $t7, $t5, 24              		           # $t7: fim da lista de moradores (6 slots * 4 bytes)

print_info_morador:
    addi $t5, $t5, 4              			   # proximo slot de morador
    blt $t5, $t7, loop_info_moradores
    j print_veiculo               			   # fim da lista: vai para veiculos

loop_info_moradores:
    lw $t6, 0($t5)                			   # carrega string do nome do morador
    bnez $t6, print_morador       			   # se existe, imprime
    j print_info_morador

print_morador:
    jal tab
    add $a0, $zero, $t6
    jal print_str
    jal new_line
    j print_info_morador

print_veiculo:
    addi $t7, $t4, 36             			   # endereco da flag de veiculos
    lw $t7, 0($t7)                			   # carrega flag

    beq $t7, 0, flag_0            			   # sem veiculo
    beq $t7, 1, flag_1            			   # 1 carro
    beq $t7, 2, flag_2            			   # 1 moto
    beq $t7, 3, flag_2            			   # 2 motos (tratado em flag_3)

    add $a0, $t4, $zero
    j flag_exception_info      			   # erro inesperado

flag_0:
    j fim_info_ap

flag_1:
    jal carro                				   # imprime 'Carro:'

    jal tab
    jal modelo              				   # imprime 'Modelo:'
    li $a0, 2
    lw $a1, 28($t4)
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    jal tab
    jal cor              				   # imprime 'Cor:'
    li $a0, 3
    lw $a1, 28($t4)
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    j fim_info_ap

flag_2:
    jal moto               				   # imprime 'Moto:'

    jal tab
    jal modelo
    li $a0, 2
    lw $a1, 28($t4)
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    jal tab
    jal cor
    li $a0, 3
    lw $a1, 28($t4)
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    beq $t7, 3, flag_3            			   # se sao 2 motos, imprime a segunda
    j fim_info_ap

flag_3:
    jal tab
    jal modelo
    li $a0, 2
    lw $a1, 32($t4)              			   # segunda moto
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    jal tab
    jal cor
    li $a0, 3
    lw $a1, 32($t4)
    jal get_funcao
    add $a0, $zero, $v0
    jal print_str
    jal new_line

    j fim_info_ap

apartamento_vazio:
    jal ap_vazio      					   # imprimir 'Apartamento vazio'

fim_info_ap:
    lw $ra, 0($sp)                			   # restaura RA
    addi $sp, $sp, 4              			   # libera pilha
    jr $ra                        			   # retorna


 ######################################################### CMD_7 #########################################################

info_geral_fn:

    la $t0, building                                        # carrega o endereco de building
    li $t1, 40                                              # bytes por apartamento
    li $t2, 40                                              # numero de apartamentos
                        
    add $t3, $zero, $zero                                   # apartamentos vazios
                            
                        
    carrega_info_geral:                        
        addi $t2, $t2, -1                       
        beq $t2,$zero, fim_info_geral                            	
        lw $t4, 4($t0)                                      # carrega o numero de moradores do apartamento
        add $t0, $t0, $t1                       
        beq $t4,$zero,  carrega_info_geral                       
                        
        addi $t3, $t3, 1                        
        bnez $t2, carrega_info_geral                       
                        
    fim_info_geral:                     
        li $t7, 10                      
        mult	$t7, $t3			                        # $t7 * $t3 = Hi and Lo registers
        mflo	$t8					                        # numero de apartamentos vazios * 10
                                
        li $t2, 4                       
        div $t8, $t2			                        # $t3 / $t1
        mflo $t2					                        # aps vazios * 10 / 4 = porcentagem de apartamentos vazios
      
        add $a0, $t3, $zero                                 # numero de apartamentos vazios
        li $a1, 4                                           # converte o numero de apartamentos vazios para string
        la $a2, int_to_str_buffer                           # 
        jal int_to_str                                   # 

        la $a1, int_to_str_buffer                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_print                              # carrega o endereco do texto de info geral
        addi $a0, $t5, 15                                   # offset 15: campo com o numero de apartamentos nao vazios
        li $a2, 4                                           # 4 bytes para copia
        jal memcpy                                          # copia o numero para o texto de info geral
 
        la $t5, info_geral_print                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 40                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 20($t5)                                     # 

        # ----------------------------------

        add $a0, $t2, $zero                                 # porcentagem de apartamentos nao vazios
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, int_to_str_buffer                           # 
        jal int_to_str                                   #

        la $a1, int_to_str_buffer                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_print                              # carrega o endereco do texto de info geral
        addi $a1, $a1, 1                                    # offset para apenas 3 bytes serem copiados
        addi $a0, $t5, 21                                   # offset 21: campo com a porcentagem de apartamentos nao vazios
        li $a2, 3                                           # tamanho da string para copia
        jal memcpy                                          # 

        la $t5, info_geral_print                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 41                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 25($t5)                                     #

        # ---------------------------------

        addi $t5, $zero 40                                  # obtem o complemento de apartamentos vazios
        sub $a0, $t5, $t3                                   #
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, int_to_str_buffer                           #
        jal int_to_str                                   #

        la $a1, int_to_str_buffer                           # carrega o endereco do numero convertido para string
        la $t5, info_geral_print                              # carrega o endereco do texto de info geral
        addi $a0, $t5, 42                                   # offset 42: campo com o numero de apartamentos vazios
        li $a2, 4                                           # 4 bytes para copia
        jal memcpy                                          # copia o numero para o texto de info geral

        la $t5, info_geral_print                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 40                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 47($t5)                                     #

        # ----------------------------------

        addi $t5, $zero, 100                                # obtem o complemento da porcentagem
        sub $a0, $t5, $t2                                   #
        li $a1, 4                                           # converte a pocentagem de apartamentos vazios para string
        la $a2, int_to_str_buffer                            # carrega o endereco do numero convertido para string
        jal int_to_str                                   #

        la $a1, int_to_str_buffer                            # carrega o endereco do numero convertido para string
        la $t5, info_geral_print                              # carrega o endereco do texto de info geral
        addi $a1, $a1, 1                                    # offset para apenas 3 bytes serem copiados
        addi $a0, $t5, 48                                   # offset 48: campo com a porcentagem de apartamentos nao vazios
        li $a2, 3                                           # tamanho da string para copia
        jal memcpy                                          #

        la $t5, info_geral_print                              # neste momento, a funcao memcpy adicionou \0 ao fim da string
        li $t6, 41                                          # completa de volta com o caracter especifico para nao quebrar a string
        sb $t6, 52($t5)                                     #

        # ---------------------------------



        la $a0, info_geral_print                              # imprime info geral 
        jal print_str                                       #

        j start                                             # volta para o inicio do programa

       
######################################################### CMD_8 ######################################################### 
# salva o estado atual dos apartamentos: salvar
salvar_fn:

# abrir o arquivo em modo de escrita (modo = 1)
    la $a0, arquivo               			   # nome do arquivo
    li $a1, 1                     			   # modo escrita
    li $a2, 0                     			   # flag (nao utilizado)
    li $v0, 13                   			   # syscall para abrir arquivo
    syscall

    blt $v0,$zero, arquivo_erro   				   # se $v0 < 0, erro ao abrir o arquivo

    add $s7, $zero, $v0          			   # salva o file descriptor em $s7

# inicializar ponteiros e contadores
    la $t0, building             			   # endereco inicial da estrutura dos apartamentos
    li $t1, 40                   			   # tamanho de um apartamento
    li $t2, 40                   			   # numero total de apartamentos

escrever_ap:
    add $t4, $zero, $t0          			   # $t4: sera o ponteiro temporario para cada ap

# gravar numero do apartamento
    lw $t3, 0($t0)               			   # $t3: numero do apartamento
    move $a0, $t3
    li $a1, 4
    la $a2, int_to_str_buffer
    jal int_to_str            				   # converte numero do ap para string

    move $a0, $s7               		   	   # file descriptor
    la $a1, int_to_str_buffer    			   # string a ser escrita
    addi $a2, $zero, 4           			   # 4 bytes
    li $v0, 15                   			   # syscall write
    syscall

    jal pular_linha_arquivo       			   # escreve quebra de linha

# gravar numero de moradores
    lw $a0, 4($t4)               			   # numero de moradores
    li $a1, 4
    la $a2, int_to_str_buffer
    jal int_to_str

    la $t9, int_to_str_buffer
    addi $a1, $t9, 3             			   # apenas 1 caractere final (numero de moradores)
    move $a0, $s7
    addi $a2, $zero, 1
    li $v0, 15
    syscall

    jal pular_linha_arquivo       			   # quebra de linha

# gravar nomes dos moradores
    li $t6, 7                    			   # contador de palavras (6 moradores + flag)

salvar_dados:
    lw $t5, 8($t4)               			   # carrega endereco da string
    beq $t6,$zero, fim_salvar_dados    			   # se contador zerar, sai
    beq $t5,$zero, pula_salvar_dados  		   # se string for nula, pula escrita

    add $a0, $zero, $t5
    jal get_tamanho_str             			   # obtem tamanho da string

    move $a0, $s7                		  	   # file descriptor
    add $a1, $zero, $t5          			   # endereco da string
    add $a2, $zero, $v0          			   # tamanho da string
    li $v0, 15
    syscall

pula_salvar_dados:
    jal pular_linha_arquivo       			   # quebra de linha apos string (ou mesmo nula)

    addi $t4, $t4, 4             			   # avanca para proxima palavra da estrutura
    addi $t6, $t6, -1
    j salvar_dados

fim_salvar_dados:
# gravar flag de automovel
    addi $t4, $t4, 8             			   # chega na word da flag de veiculo
    lw $a0, 0($t4)
    li $a1, 4
    la $a2, int_to_str_buffer
    jal int_to_str

    la $t4, int_to_str_buffer
    addi $t4, $t4, 3            			   # apenas 1 byte final (valores 0-3)
    move $a0, $s7
    add $a1, $zero, $t4
    addi $a2, $zero, 1
    li $v0, 15
    syscall

    jal pular_linha_arquivo       			   # quebra de linha final

# avancar para o proximo apartamento
    add $t0, $t0, $t1            			   # avanca 40 bytes
    addi $t2, $t2, -1
    ble $t2,$zero, end_escrever_ap       			   # se contador zerou, fim
    j escrever_ap

# quebra de linha
pular_linha_arquivo:
    move $a0, $s7                			   # file descriptor
    la $a1, newline            			   # contem '\n'
    addi $a2, $zero, 1
    li $v0, 15
    syscall
    jr $ra

# fechar o arquivo e retorna
end_escrever_ap:
    add $a0, $zero, $s7
    li $v0, 16                   			   # syscall close
    syscall

    j salvar                      			   # retorna ao programa principal




######################################################### CMD_9 ######################################################### 
# recarrega o estado anterior dos apartamentos(sobrescreve): recarregar
recarregar_fn:

# abrir arquivo em modo de leitura
    la   $a0, arquivo                  			   # nome do arquivo
    li   $a1, 0                        			   # modo leitura
    li   $a2, 0                        			   # flag
    li   $v0, 13                       			   # syscall: open
    syscall

    bltz $v0, arquivo_erro    				   # erro ao abrir o arquivo
    move $s7, $v0                      			   # salva file descriptor em $s7

# ler conteudo do arquivo para o buffer input_file
    li   $v0, 14                       			   # syscall: read
    move $a0, $s7                     			   # file descriptor
    la   $a1, input_file              			   # endereco destino
    li   $a2, 1000000                 			   # ate 1MB
    syscall

# inicializar ponteiros
    la   $t0, input_file              			   # ponteiro de leitura do arquivo
    la   $t1, building                			   # ponteiro de escrita em building
    li   $t2, 40                      			   # contador de apartamentos

carregar_ap_loop:
    blez $t2, fim_recarregar         			   # fim da leitura

# le e ignora numero do apartamento
    jal  busca_proxima_linha              			   # avanca ponteiro apos numero do apartamento

# ler numero de moradores
    move $a0, $t0
    jal  str_to_int                  			   # converte string p/ inteiro
    sw   $v0, 4($t1)                 			   # salva numero de moradores no offset 4

# carregar moradores
    li   $t3, 7                      			   # contador de moradores
    addi $t4, $t1, 8                			   # $t4: aponta para a primeira string de morador

carregar_moradores_loop:
    beqz $t3, fim_moradores

    jal  busca_proxima_linha             			   # avanca $t0 para proxima string
    move $a0, $t0
    jal  get_tamanho_str               			   # calcula tamanho da string

    beqz $v0, pular_morador         			   # se string vazia, ignora

# alocar memoria e copia nome
    addi $a0, $v0, 1                			   # +1 para \0
    move $t5, $a0
    li   $v0, 9                     			   # syscall: sbrk
    syscall

    sw   $v0, 0($t4)                			   # salva ponteiro em building
    move $a0, $v0                   			   # destino
    move $a1, $t0                   			   # origem
    move $a2, $t5                   			   # tamanho
    jal  memcpy                     			   # copia nome

pular_morador:
    addi $t4, $t4, 4               			   # proximo slot de string
    addi $t3, $t3, -1              			   # decrementa contador
    j    carregar_moradores_loop

fim_moradores:
# ler a flag do automovel
    move $a0, $t0
    jal  str_to_int
    sw   $v0, 36($t1)              			   # offset da flag no apartamento

    jal  busca_proxima_linha            			   # pula para a proxima linha

# avancar para o proximo apartamento
    addi $t1, $t1, 40            			   # proximo apartamento
    addi $t2, $t2, -1
    j    carregar_ap_loop

fim_recarregar:
# fechar o arquivo
    move $a0, $s7
    li   $v0, 16                   			   # syscall: close
    syscall

    j recarregar                 			   # volta para o inicio do programa



busca_proxima_linha:                                            # pula para a proxima linha no buffer do arquivo
    add $t9, $t9, $zero                                    # inicia o contador
    
    buscando_prox_linha:
        lb $t7, 0($t0)                                     # carrega o byte atual de input_file
        beq $t7, 10, fim_busca                         # caso chegou em um \n, finaliza
        addi $t9, $t9, 1                                   # incrementa o contador
        addi $t0, $t0, 1                                   # proximo byte em t0
        j buscando_prox_linha                                     # reinicia o loop

    fim_busca:
        addi $t0, $t0, 1                                   # endereco do inicio da proxima linha
        add $v0, $t9, $zero                                # retorna o tamanho da linha
        jr $ra                                             # retorna pra funcao principal






formatar_fn:
# inicializar contador
    li   $t0, 0                    			    # contador de apartamentos (0 a 39)

limpar_loop:
    bge  $t0, 40, fim_formatar     			    # se t0 >= 40, termina o loop

# chamar funcao para limpar o apartamento t0 
    move $a0, $t0                  			    # passa indice do apartamento via $a0
    jal  limpa_ap_aux          			            # limpa o apartamento

    addi $t0, $t0, 1               			    # incrementa o indice
    j    limpar_loop               			    # repete para o proximo apartamento

fim_formatar:
    j start                        			    # retorna para o inicio do programa  

