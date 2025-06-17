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


memcpy:                                 
	add $t0, $zero, $a0                 	#escreve o endereço destino para t0
    	add $t1, $zero, $a1                 	#escreve o endereço source para t1
    	add $t2, $zero, $zero               	#escreve 0 em t2 para o contador
    	addi $t4, $zero, 10			#armazena '\n' em ASCII para o fim da operação

	loop:
    		bge $t2, $a2, end_memcpy        	#caso i seja igual a num, encerra a função
        		lb $t3, 0($t1)                  	#carrega o byte de source em t3
        		beq $t3, $t4, end_memcpy		#se o byte for igual a 10('\n') -> fim
        		sb $t3, 0($t0)                  	#grava o byte de t3 em destination
        		addi $t0, $t0, 1                	#incrementa destination
        		addi $t1, $t1, 1                	#incrementa source
        		addi $t2, $t2, 1                	#incrementa i
       	 	
       	 	j loop                   #refaz o loop

	
	end_memcpy:
		addi $t0, $t0, 1
        		sb $zero, 0($t0)
        		jr $ra
