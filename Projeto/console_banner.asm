.data
	banner: .asciiz "GSVW-shell>> "
	buffer: .space 1000
.text
	loop_flag:
	li $v0, 4 							# syscall --> função de impressão de string
	la $a0, banner 						# Armazenar o endereço da string
	syscall
	
	# Ler comando do usuário
    	li $v0, 8              			# syscall --> função de ler string
    	la $a0, buffer      			# Buffer de destino
    	li $a1, 100           	 		# Número máximo de caracteres
    	syscall
 	
 	j loop_flag
