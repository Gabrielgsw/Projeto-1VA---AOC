# Atividade 1VA - Arquitetura e Organizacao de Computadores [2025.1]
# Gabriel Germano dos Santos Wanderley
# Samara Accioly
# Vitor Barros de Carvalho
# Wellington Viana da Silva Junior
# Questão 1) letra a)
# Arquivo referente à função 'strcpy': Copia uma string — incluindo o caractere NULL (‘\0’) — apontado pela source diretamente para o bloco de memória apontado pelo destination.

.data
	string: .asciiz "Palavra"
	dest:  .space 7 #aloca os bytes necessários para armazenar a string 
	
.text

  main:

    la $a0, dest       # carrega o endereço de destino
    la $a1, string     # carrega o endereço de origem
    jal strcpy         # chama o label

    li $v0, 4          # imprime string
    la $a0, dest
    syscall

    li $v0, 10         # finaliza programa
    syscall

strcpy:
	add $t0,$a1,$0 #aramazenando em t0 o endereço de origem
	add $t1,$a0,$0 #armazenando em t1 o endereço de destino
	
	
	for:
	   lb $t2,0($t0) #carrega o caractere atual do loop
	   sb $t2,0($t1) #armazena em t2 o caractere atual do loop
	   beq $t2,$0,end #encerra o loop caso o caracete atual seja o \n
	   addi $t0, $t0, 1 #Incrementado ponteiro origem
           addi $t1, $t1, 1#Incrementado ponteiro destino
           j for #Reinicia loop
           
        end:
        	jr $ra 
        	
        	    
        	        
