#Atividade 1VA - Arquitetura e Organizacao de Computadores [2025.1]
#Gabriel Germano dos Santos Wanderley
#Samara Accioly
#Vitor Barros de Carvalho
#Wellington Viana da Silva Junior
#Arquivo referente a questão 1 - letra b
#Implementa a lógica do memcpy 

.data
    origem: .asciiz "Hello World"     #String de origem
    copia:  .space 12                 #espaço reservado para a cópia (11 + 1 para '\0')

.text
main:
    la $a0, copia        #endereço de destino
    la $a1, origem       #endereço de origem
    li $a2, 12           #número de bytes a copiar
    jal memcpy           #chamada da função memcpy(copia, origem, 12)

    # Imprime a string copiada
    li $v0, 4
    la $a0, copia
    syscall

    # Finaliza o programa
    li $v0, 10
    syscall
    
# função memcpy
memcpy:
    move $t0, $a0
    move $t1, $a1
    move $t2, $a2

loop:
    beq $t2, $zero, end
    lb $t3, 0($t1)
    sb $t3, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t2, $t2, -1
    j loop

end:
    move $v0, $a0
    jr $ra
