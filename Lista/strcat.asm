.data
str1:       .asciiz "Bem"
str2:       .asciiz "Vindo"
resultado:  .space 10 # Espaco para o resultado concatenado

.text
main:
    la $a0, resultado # Endereço do destino (resultado)
    la $a1, str1      # Endereço de str1
    jal copy_string   # Copia str1 para resultado

    # $a0 deve apontar para o final de resultado
    la $a0, resultado # Recarrega resultado
    jal find_end      # Encontra o final da string
    move $a0, $v0     # Move o endereco final para $a0

    la $a1, str2      # Endereço de str2
    jal copy_string   # Copia str2 para resultado 

    # Imprime resultado
    la $a0, resultado
    jal print_string

    li $v0, 10        # Finaliza o programa
    syscall

# copy_string: Copia string de $a1 para $a0
# Mantem o byte nulo no final
copy_string:
    lb $t0, 0($a1)
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    bnez $t0, copy_string
    jr $ra

# find_end: Encontra o final da string em $a0, retorna em $v0
find_end:
    move $v0, $a0
find_loop:
    lb $t0, 0($v0)
    beqz $t0, end_find
    addi $v0, $v0, 1
    j find_loop
end_find:
    jr $ra

# print_string: Imprime a string cujo endereco esta em $a0
print_string:
    li $v0, 4
    syscall
    jr $ra
