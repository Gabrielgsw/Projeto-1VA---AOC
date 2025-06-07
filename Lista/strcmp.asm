.data
	str1: .asciiz "abacate!"
	str2: .asciiz "abacate!"
	
.text
	main:
	la $a0, str1 							# Armazena o endereço da str1
	la $a1, str2							# Armazena o endereço da str2
	jal strcmp								# Chama o procedimento da função strcmp
	move $a0, $v0							# Move o resultado para $a0 para impressão
	jal print								# Imprime o resultado
	jal end									# Finaliza o programa
	
	#Função strcmp
	strcmp:
	add $t0, $zero, $a0 					# Armazena o endereço da str1
	add $t1, $zero, $a1  					# Armazena o endereço da str2
	
		loop_strcmp:			
		lb $t2, 0($t0)						# Armazenar o primeiro caractere da palavra 1
		lb $t3, 0($t1)						# Armazenar o primeiro caractere da palavra 2
		addi $v0, $zero, -1					# Caso 1: Caractere str1 "menor" que str2 | Caso seja verdade, resultado = -1
		blt $t2, $t3, end_strcmp			# Finalizar a função
		addi $v0, $zero, 1					# Caso 2: Caractere str1 "maior" que str2 | Caso seja verdade, resultado = 1
		bgt $t2, $t3, end_strcmp			# Finalizar a função
		addi $v0, $zero, 0					# Caso 3: Caractere str1 "igual" ao str2 | Caso seja verdade, resultado = 0
		beq $t2, $zero, end_strcmp			# Observar se as strings chegaram ao seu final, com o valor permanecendo 0
		addi $t0, $t0, 1					# Passar para outro caractere
		addi $t1, $t1, 1					# Passar para outro caractere
		j loop_strcmp						# Reinicia o loop da função
		
	j end_strcmp							# Finaliza o procedimento strcmp
		
		
	end_strcmp:								# Procedimento de fim da função strcmp
	jr $ra
	
	print:									# Procedimento de impressão do resultado
	li $v0, 1								# syscall para impressão de inteiros
	syscall
	
	jr $ra					
	
	end:									# Procedimento para fim do programa
	li $v0, 10								# syscall para finalizar o programa
	syscall
	
	jr $ra
