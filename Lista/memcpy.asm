.data
    string: .asciiz "Hello World"   #string de origem
    dest:   .space 12               #espaço para copiar a string (11 + 1 byte para '\0')

.text
main:
    la $a0, dest         #destino da cópia
    la $a1, string       #origem da cópia
    li $a2, 12           #número de bytes a copiar 
    jal memcpy           #chama memcpy(dest, string, 12)

    # Imprime a string copiada
    li $v0, 4
    la $a0, dest
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