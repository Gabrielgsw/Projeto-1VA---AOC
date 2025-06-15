.data


# Salva os registradores
.macro stack_reg
    addi $sp, $sp, -48
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    sw $t7, 28($sp)
    sw $a0, 32($sp)
    sw $a1, 36($sp)
    sw $a2, 40($sp)
    sw $a3, 44($sp)
.end_macro

# Esvazia/recupera os registradores
.macro unstack_reg
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $a0, 32($sp)
    lw $a1, 36($sp)
    lw $a2, 40($sp)
    lw $a3, 44($sp)
    addi $sp, $sp, 48
.end_macro

	int_to_str_buffer: .space 4
	
.macro voltar
	unstack_reg
	jr $ra
.end_macro

.text
.globl criar_condominio, strcmp, strncmp, memcpy, int_to_str, int_to_str_buffer, str_to_int, get_tamanho_str, get_indice_ap 
	


# Função com o propósito de criar a estrutura do apartamento, com 10 andares e 4 apartamentos por andar
# $a0 -> início do apartamento/condomínio
criar_condominio:
	stack_reg
	move $t0, $a0				# Salvar o endereço do início do apartamento
		
	li $t1, 0				# Contador dos andares
	li $t2, 0				# Contador dos apartamentos
		
	li $t3, 0				# Contador dos números de apartamentos
	li $t4, 101				# Apartamento inicial 
		
	li $t5, 10				# Quantidade de andares
	li $t6, 4				# Quantidade de apartamentos por andar
		
	loop_preencher_apartamento:
		bgt $t5, $t1, loop_por_andar	# Caso não passou por todos os andares (total andar < contador andar), vai pro preenchimento do andar
			
		voltar
		
	loop_por_andar:
		bgt $t6, $t2, preencher_ap 	# Caso ele não passou por todos os apartamentos dos andares (
		addi $t1, $t1, 1			# Passa para outro apartamento
		addi $t5, $t5, 100		# Vai para outro andar
		li $t2, 0			# reinicia o contador para 1
			
		j loop_preencher_apartamento	
			
		
	preencher_ap:
		add $t7, $t5, $t2		# Adiciona o apartamento com o numero inicial na contagem
		sw $t7, 0($t0)			# Armazena o valor no array
			
		addi $t2, $t2, 1			# +1 no contador do apartamento
		addi $t3, $t3, 1			# +1 no contador do número de apartamentos
		addi $t0, $t0, 40
		
		j loop_por_andar



# Função strcmp -> Compara duas strings
# $a0 -> endereço da primeira string
# $a1 -> endereço da segunda string
strcmp:
	stack_reg
	add $t0, $zero, $a0 			# Armazena o endereço da str1
	add $t1, $zero, $a1  			# Armazena o endereço da str2
	
	loop_strcmp:			
		lb $t2, 0($t0)			# Armazenar o primeiro caractere da palavra 1
		lb $t3, 0($t1)			# Armazenar o primeiro caractere da palavra 2
		addi $v0, $zero, -1		# Caso 1: Caractere str1 "menor" que str2 | Caso seja verdade, resultado = -1
		blt $t2, $t3, end_strcmp		# Finalizar a função
		addi $v0, $zero, 1		# Caso 2: Caractere str1 "maior" que str2 | Caso seja verdade, resultado = 1
		bgt $t2, $t3, end_strcmp		# Finalizar a função
		addi $v0, $zero, 0		# Caso 3: Caractere str1 "igual" ao str2 | Caso seja verdade, resultado = 0
		beq $t2, $zero, end_strcmp	# Observar se as strings chegaram ao seu final, com o valor permanecendo 0
		addi $t0, $t0, 1			# Passar para outro caractere
		addi $t1, $t1, 1			# Passar para outro caractere
		j loop_strcmp			# Reinicia o loop da função
		
		voltar			# Finaliza o procedimento strcmp
				
	
	
# Função strncmp -> compara duas strings em um certo tamanho n
# $a0 -> endereco da primeira string
# $a1 -> endereco da segunda string
# $a3 -> contador maximo de comparacoes
strncmp:
	stack_reg
	add $t0, $zero, $a0 			# Armazena o endereco da str1
	add $t1, $zero, $a1  			# Armazena o endereco da str2
	add $t2, $zero, $a3			# Armazena o endereco do contador
	add $t3, $zero, $zero			# Registrador para o contador de bytes
	
	loop_strncmp:
		bgt $t3, $t2, end_strncmp	# Comparar a quantidade de bits, caso o contador esteja maior do que o num, encerre o programa		
		lb $t4, 0($t0)			# Armazenar o primeiro caractere da palavra 1
		lb $t5, 0($t1)			# Armazenar o primeiro caractere da palavra 2
		addi $v0, $zero, -1		# Caso 1: Caractere str1 "menor" que str2 | Caso seja verdade, resultado = -1
		blt $t4, $t5, end_strncmp	# Finalizar a função
		addi $v0, $zero, 1		# Caso 2: Caractere str1 "maior" que str2 | Caso seja verdade, resultado = 1
		bgt $t4, $t5, end_strncmp	# Finalizar a função
		addi $v0, $zero, 0		# Caso 3: Caractere str1 "igual" ao str2 | Caso seja verdade, resultado = 0
		beq $t4, $zero, end_strncmp	# Observar se as strings chegaram ao seu final, com o valor permanecendo 0
		addi $t0, $t0, 1			# Passar para outro caractere
		addi $t1, $t1, 1			# Passar para outro caractere
		addi $t3, $t3, 1			# Adicionar no contador
		j loop_strncmp			# Reinicia o loop da funcao
		
		voltar				# Finaliza o procedimento strncmp
		

				

# Falta o memcpy (Falar com samara depois)
memcpy:




# Converte um inteiro para string com o buffer de 4 bytes
# $a0 -> o numero a ser convertido
# $a1 -> tamanho maximo do buffer de saida
# $a2 -> ponteiro para o buffer de saida
int_to_str:
	stack_reg
	li $t0, 1000				# divisor inicial
	li $t1, 10				# base decimal da divisao
	
	loop_transformar:
		beqz $a1, voltar			# se acabou o buffer, saia da funcao
		
		div $a0, $t0
					
		mflo $t2				# pega o digito autal
		mfhi $a0				# resto = novo valor pra divisao
		
		addi $t2, $t2, 48		# conversao pra ASCII
        		sb $t2, 0($a2)			# Salvar o caractere no buffer

        		div $t0, $t1			
        		mflo $t0				# divisor / 10					
        		addi $a1, $a1, -1		# reduz a "string"
        		addi $a2, $a2, 1			# passa para o proximo caractere
        		j loop_transformar
    


# Converte uma string decimal (0-9) em um inteiro 32 bits
# $a0 -> string a ser convertida / ponteiro que percorre a string
# $v0 -> resultado da transformacao	
str_to_int:
	stack_reg
    	li $t0, 0		# acumulador da transformacao
    	li $t4, 48 		# 0  em ASCII
    	li $t5, 57		# 9 em ASCII
    	li $t6, 10		# \n em ASCII
    	loop_str_int:
        		lb $t1, 0($a0)				# Leitura do primeiro caracetre(se estiver em mais de um loop, vai ler o n-caracter)
        		beq $t1, $zero, finalizar		# Verificar se chegou no fim da string '\0'	
        		beq $t1, $t6, finalizar			# Verificar se chegou no '\n' de alguma string, se sim, finalize
       	 	blt $t1, $t4, erro_transformacao		# se o caractere for menor que 0
        		bgt $t1, $t5, erro_transformacao		# se o caractere for maior que 9
        		sub $t1, $t1, $t4			# Conversao em ASCII	
        		mul $t0, $t0, 10				# resultado = resultado * 10
        		add $t0, $t0, $t1			# soma o digito transformado
        		addi $a0, $a0, 1				# vai para o proximo caractere
        		j loop_str_int
        		
    	erro_transformacao:
        		li $v0, -1				# Caso falhe, retorne -1
        		voltar
        		
    	finalizar:
        		add $v0, $zero, $t0			# Caso nao falhe, retorne 0
        		voltar



get_tamanho_str:
	stack_reg
    	move $t0, $a0                               	# Copy the string address to $t0
   	li $t1, 0                                   	# Initialize the counter to 0

    	loop_tamanho_str:      
       		lb $t2, 0($t0)                          	# Load the next character into $t2
        		beq $t2, $zero, fim_funcao       		# If the character is null, exit the loop
       		beq $t2, 10, fim_funcao          		# If the character is \n, exit the loop
        		addi $t0, $t0, 1                        	# Increment the address of the string
        		addi $t1, $t1, 1                        	# Increment the counter
        		j loop_tamanho_str                           	# Jump back to the start of the loop

    	fim_funcao:
       		move $v0, $t1                           	# Set the function return value to the size of the string
		
		voltar




###### PODE DAR ERRO ######
# Funcao que pega o indice do apartamento escolhido (que esta em int)
# $a0 -> indice do apartamento
# $v0 -> saida que retorna o indice do apartamento
# Como e calculado o indice --> (andar - 1) * 4 + (apartamento - 1)
get_indice_ap:
	stack_reg
	add $t0, $a0, $zero
	li $t1, 100
	div $t0, $t1	
	mflo $t2					# indice andar
	mfhi $t4					# indice apartamento
	
	# Validar se o andar e valido
	blez $t2, indice_invalido		# Se o andar e o 0, entao é invalido
	addi $t3, $zero, 10			# Registrador para comparar o maximo
	blt $t3, $t2, indice_invalido		# Se $t3 for menor que $t2, entao o indice do andar esta invalido
	
	
	#Validar se o apartamento e valido
	blez $t4, indice_invalido		# Se o apartamento e o 0, entao e invalido
	addi $t3, $zero, 4			# Registrador para comparar o maximo
	blt $t3, $t4, indice_invalido		# Se $t3 for menor que $t4, entao o indice do andar esta invalido
	
	addi $t2, $t2, -1			# Subtrair 1 do andar
	addi $t4, $t4, -1			# Subtrair 1 do apartamento
	addi $t3, $zero, 4			# Preparar o multiplicador
	
	#pode dar erro aqui, dar uma olhada e testada
	mult $t2, $t3				
	mflo $t2
	add $v0, $t2, $t4
	
	voltar
	
	indice_invalido:
		unstack_reg
		addi $v0, $zero, -1
		jr $ra
	



	
