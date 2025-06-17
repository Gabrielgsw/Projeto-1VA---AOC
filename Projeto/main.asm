#Atividade 1VA - Arquitetura e Organizacao de Computadores [2025.1]
#Gabriel Germano dos Santos Wanderley
#Samara Accioly
#Vitor Barros de Carvalho
#Wellington Viana da Silva Junior
#Arquivo que implementa o main do projeto.
 

#Constantes para uso no MMIO
.eqv E 10                                                               #código ASCII de Enter
.eqv BP 8                                                               #código ASCII de Backspace

.data

# Dados iniciais para a execução
building: .space 1600 						      #total de bytes -> 40 por apartamento
hifen: .asciiz "-"                                                    #separador entre os comandos
newline: .asciiz "\n"                                                 #quebra de linha
banner: .asciiz "GSWV-shell>> "                                       #banner da equipe
input: .space 1024                                                    #espaco para o input do usuario
output: .space 1024					              #espaço para output


.text
.globl print_str, start, input, output, hifen, building, newline

main:

    la $a0, building							 #carrega em $a0 o endereço para o building
    jal criar_condominio						 #inicializa a função de criar condominio  

    lui $s0, 0xFFFF                                                     #carrega o endereco base dos registradores do controle mmio em s0
    la $s1, input                                                       #carrega o endereco base do input em s1
    j start
    
start:
    la $a0, banner                                                      #carrega o endereco do banner
    jal print_str                                                       #chama a funcao print string
    jal limpa_input                                                     #chama a funcao para limpar o imput 
    j loop_mmio                                                         #inicia o loop do mmio


limpa_input:                                                            #funcao para limpar o input
    addi $s1, $s1, -1                                                   #decrementa cursor do input em 1
    lb $t0, 0($s1)                                                      #carrega o byte inicial do cursor
    beq $t0, $zero, end_limpa                                           #caso seja \n, input vazio, finaliza
    sb $zero, 0($s1)                                                    #grava 0 no cursor atual
    j limpa_input                                                       #reinicia o loop
    end_limpa:                  
    	addi $s1, $s1, 1                                                #incrementa no cursor e finaliza retornando $ra
        jr $ra                                                          

loop_mmio:                                                              #loop do mmio
    lw $t0, 0($s0)                                                     
    beq $t0,$zero, loop_mmio                                            #enquanto nao recebe input, reinicia o loop
    lw $s2, 4($s0)                                                      #armazena em $s2 o char recebido do input
    beq $s2, BP, backspace                                              #se o character digitado for um backspace, chama funcao backspace
    sb $s2, 0($s1)                                                      #armazena no input
    jal imprime_char                                                    #chama a funcao que mostra o char na tela do mmio
    addi $s1, $s1, 1                                                    #move o cursor do input para o proximo byte
    beq $s2, E, enter                                                   #se o input for enter, chama a funcao enter
    jal loop_mmio                                                         # reinicia loop

imprime_char:                                                           # funcao que imprime um character na tela 
    lw $t1, 8($s0)                                                      
    beqz $t1, imprime_char                                              # caso transmitter($t0) nao esteja pronto, volta ao inicio da funcao
    sw $s2, 12($s0)                                                     # armazena o caractere recebido
    jr $ra                                                              # retorna


print_str:                                                              #imprime uma string na tela mmio 
    addi	$sp, $sp, -4			                        #reserva uma posicao na stack
    sw $ra, 0($sp)                                                      # grava return adress na stack
    lb	$s2, 0($a0)                                                     #carrega o byte da string em s2
    jal	imprime_char				                        #chama a funcao imprime_char
    lw $ra, 0($sp)                                                      #recupera o ra no sp
    addi $sp, $sp, 4                                                    #libera uma posicao 
    addi $a0, $a0, 1                                                    #move o cursor da string 
    bnez $s2, print_str	                                                #se o character nao for zero, reinicia a funcao e continua a imprimir
    jr $ra                                                              #retorna
    
enter:                                                                  
    la $a0, input                                                       #carrega endereco de input
    jal get_tamanho_str                                                 #calcula tamaho da string do input
    beqz $v0, pula_process_comando                                      #caso input esteja vazio, não executa o processamento de comando
    jal processar_comando                                               #chama a funcao que processa o comando
    pula_process_comando:
    jal start                                                           #desvia para o inicio do mmio

backspace:                                                              
    lb $t0, -1($s1)                                                     #carrega o byte da posicao final do input
    beqz $t0, end_backspace                                             #se for o fim da string, encerra a funcao
    la $a0, newline                                                     #pula uma linha
    jal print_str
    la $a0, banner                                                      #imprime o banner
    jal print_str
    addi $s1, $s1, -1                                                   #move o cursor do input para posicao anterior
    sb $zero, 0($s1)                                                    #escreve \0 para indicar o fim da string
    la $a0, input                                                       #inprime o input atualizado na nova linha                                                 
    jal print_str                                                       
    end_backspace:                                                      #encerra a funcao
        jal loop_mmio                                                   #desvia para o inicio de loop_mmio
