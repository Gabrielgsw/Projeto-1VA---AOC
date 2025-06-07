.data
	str1: .asciiz "abacaxi!"
	str2: .asciiz "abacate!"
	num: .word 6
	
.text
	main:
	la $a0, str1 							# Armazena o endereço da str1
	la $a1, str2							# Armazena o endereço da str2
	lw $a3, num								# Armazena o endereço de num
	subi $a3, $a3, 1						# Subtrai 1 para observar a quantidade real de caractere, visto que o MIPS começa pelo caractere "0"
	jal strncmp								# Chama o procedimento da função strncmp
	move $a0, $v0							# Move o resultado para $a0 para impressão
	jal print								# Imprime o resultado
	jal end									# Finaliza o programa
	
	#Função strncmp
	strncmp:
	add $t0, $zero, $a0 					# Armazena o endereço da str1
	add $t1, $zero, $a1  					# Armazena o endereço da str2
	add $t2, $zero, $a3						# Armazena o endereço do contador
	add $t3, $zero, $zero					# Registrador para o contador de bytes
	
		loop_strncmp:
		bgt $t3, $t2, end_strncmp			# Comparar a quantidade de bits, caso o contador esteja maior do que o num, encerre o programa		
		lb $t4, 0($t0)						# Armazenar o primeiro caractere da palavra 1
		lb $t5, 0($t1)						# Armazenar o primeiro caractere da palavra 2
		addi $v0, $zero, -1					# Caso 1: Caractere str1 "menor" que str2 | Caso seja verdade, resultado = -1
		blt $t4, $t5, end_strncmp			# Finalizar a função
		addi $v0, $zero, 1					# Caso 2: Caractere str1 "maior" que str2 | Caso seja verdade, resultado = 1
		bgt $t4, $t5, end_strncmp			# Finalizar a função
		addi $v0, $zero, 0					# Caso 3: Caractere str1 "igual" ao str2 | Caso seja verdade, resultado = 0
		beq $t4, $zero, end_strncmp			# Observar se as strings chegaram ao seu final, com o valor permanecendo 0
		addi $t0, $t0, 1					# Passar para outro caractere
		addi $t1, $t1, 1					# Passar para outro caractere
		addi $t3, $t3, 1					# Adicionar no contador
		j loop_strncmp						# Reinicia o loop da função
		
	j end_strncmp							# Finaliza o procedimento strncmp
		
		
	end_strncmp:							# Procedimento de fim da função strncmp
	jr $ra
	
	print:									# Procedimento de impressão do resultado
	li $v0, 1								# syscall para impressão de inteiros
	syscall
	
	jr $ra					
	
	end:									# Procedimento para fim do programa
	li $v0, 10								# syscall para finalizar o programa
	syscall
	
	jr $ra
