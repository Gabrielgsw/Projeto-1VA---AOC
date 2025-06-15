.data
	int_to_str_buffer: .space 4
	
	# Nome dos comandos
	ad_morador: .asciiz "ad_morador"
	ad_auto: .asciiz "ad_auto"
	rm_morador: .asciiz "rm_morador"
	rm_auto: .asciiz "rm_auto"
	
	info_ap: .asciiz "info_ap"
	limpar_ap: .asciiz "limpar_ap"
	# info_geral: .asciiz "info_geral"
	
	salvar: .asciiz "salvar"
	recarregar: .asciiz "recarregar"
	formatar: .asciiz "formatar"



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

	
.macro voltar
	unstack_reg
	jr $ra
.end_macro

.text
.globl criar_condominio, strcmp, strncmp, memcpy, int_to_str, int_to_str_buffer, str_to_int, get_tamanho_str, get_indice_ap, get_funcao, processar_comando, prox_linha, free 
	


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
		

				

# Funcao memcpy -> copia um total de bytes dado um número do local e salva em memoria
# $a0 -> destino
# $a1 -> source
# $a2 -> numero
memcpy:
	stack_reg
	move $t0, $a0          			# $t0 -> destino
	move $t1, $a1          			# $t1 -> source
	move $t2, $a2          			# $t2 -> num

	loop:
    		beq $t2, $zero, voltar   	# se num == 0, fim
    		lb $t3, 0($t1)       	 	# carrwga 1 byte em surce
    		sb $t3, 0($t0)        		# armazena 1 byte em destino
    		addi $t0, $t0, 1
    		addi $t1, $t1, 1
    		addi $t2, $t2, -1     		# decrementa 1
    		j loop






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


# Funcao get_tamanho_str -> Le de byte a byte para contar qual o tamanho da string
# $a0 -> string a ser lida
# $v0 -> resultado em inteiro do tamanho da string
get_tamanho_str:
	stack_reg
    	move $t0, $a0                               	# Copia o valor da string 
   	li $t1, 0                                   	# Inicializa o contador pra 0

    	loop_tamanho_str:      
       		lb $t2, 0($t0)                          	# Carrega o proximo caractere a ser lido em $t2
        		beq $t2, $zero, fim_funcao       		# Se o caractere e nulo, entao acabou 
       		beq $t2, 10, fim_funcao          		# Se o caractere e \n, entao acabou
        		addi $t0, $t0, 1                        	# Pula pro proximo byte
        		addi $t1, $t1, 1                        	# +1 pro contador
        		j loop_tamanho_str                       	# Volta o loop ate acabar

    	fim_funcao:
       		move $v0, $t1                           	# Retorna o valor da string em $v0
		
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
	mflo $t2					# Indice andar
	mfhi $t4					# Indice apartamento
	
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
	


# Funcao get_funcao ->
get_funcao:
	stack_reg
	add $t0, $zero, $a1
	la $t1, separador
	lb $t1, 0($t1)
	add $t2, $a0, $zero
	
	procurar_hifen:
		lb $t3, 0 ($t0)
		addi $t0, $t0, 1
		beqz $t3, fim_get_funcao
		bne $t3, $t1, procurar_hifen
		addi $t2, $t2, -1
		beqz $t2, guardar_funcao
		j procurar_hifen
		
	guardar_funcao:
		addi $t2, $t0, 0
		achar_funcao:
			lb $t3, 0($t2)
			addi $t2, $t2, 1
			beqz $t3, if_achar_funcao
			bne $t3, $t1, achar_funcao
			addi $t2, $t2, 1
		
		if_achar_funcao:
			sub $t2, $t2, $t0                                           
            		addi $t2, $t2, 1                                            
            		add $a0, $zero, $t2                                        
            		addi $v0, $zero, 9                                         
            		syscall                                                    
            		add $v1, $zero, $t2                                         
            		addi $t2, $t2, -1                                           
            		add $a2, $zero, $t2                                       
            		add $a1, $zero, $t0                                         
            		add $a0, $zero, $v0                                         
            		addi $sp, $sp, -4                                          
            		sw $ra, 0($sp)                                             
            		jal memcpy                                                 
            		lw $ra, 0($sp)                                            
            		addi $sp, $sp, 4                                           
            		unstack_reg                                                                
           		jr $ra                                                      

	
	fim_get_funcao:
		unstack_reg
		j op_invalida
		jr $ra
	
	
# Funcao processar_comando ->
#
#
processar_comando:
	stack_reg                                                               	
    	la $t0, input                                                       	
    	lb $t1, 0($t0)
    	beqz $t1, fim_processar
    	addi $t1, $zero, -1                                               		
    	la $t3, separador                                                   	
    	lb $t3, 0($t3)
    	loop_processar:                                                         	
        		lb $t2, 0($t0)                                                  	
        		beqz $t2, comparar_cmd                                               	
        		beq $t2, $t3, comparar_cmd                                           	
        		addi $t0, $t0, 1                                                
        		addi $t1, $t1, 1                                                	
        		j loop_processar
        		
        		  
        	# Switch case para saber qual o comando que foi digitado pelo usuario
        		                                                   
    	comparar_cmd:                                                      
        		la $a0, ad_morador      				# Carrega para ver se é 'ad_morador'                                       
        		li $a3, 10                                        # Tamanho do comando a ser comparado            
        		jal strncmp                                       # Vai pro strncmp para ver ser é a mesma string  
        		beqz $v0, ad_morador_fn                           # Caso foi, ele redireciona pra funcao do comando
		
		la $a0, ad_auto                                 	# Caso 'ad_auto'                
        		li $a3, 7
        		jal strncmp                                                     
        		beqz $v0, ad_auto_fn                                       
        		
        		la $a0, rm_morador                             	# Caso 'rm_morador'                
        		li $a3, 10
        		jal strncmp                                                   
        		beqz $v0, rm_morador_fn                                         

        		la $a0, rm_auto                            	# Caso 'rm_auto'                     
        		li $a3, 7
        		jal strncmp                                                     
        		beqz $v0, rm_auto_fn                                            
        		
        		la $a0, info_ap                          		# Caso 'info_ap'                      
        		li $a3, 7
        		jal strncmp                                                     
        		beqz $v0, info_ap_fn                           		                

        		la $a0, limpar_ap                			# Caso 'limpar_ap'                               
        		li $a3, 9
        		jal strncmp                                                     
        		beqz $v0, limpar_ap_fn                                          

        		la $a0, recarregar    				# Caso 'recarregar'                                          
        		li $a3, 10
        		jal strncmp                                                     
        		beqz $v0, recarregar_arquivo                                        

		la $a0, salvar                                    # Caso 'salvar'            
        		li $a3, 6
        		jal strncmp                                                     
        		beqz $v0, salvar_arquivo                                        
        		
        		la $a0, formatar                                 	# Caso 'formatar'          
        		li $a3, 8
        		jal strncmp                                                     
       		beqz $v0, formatar_arquivo                                           
        
        		j cmd_invalido_fn                                 # Caso não tenha nenhum acesso, traz a funcao de cmd invalido default
    
    fim_processar:                                                     
        unstack_reg
        j start                                                   # Volta pro inicio, caso chamado novamente, volta pro inicio


prox_linha:
    li   $t9, 0                    		# Inicializa contador de bytes (tamanho da linha)

	loop_prox_linha:
    		lb   $t7, 0($t0)              	# Carrega byte atual do buffer em $t7
    		beq  $t7, 10, fim_linha    	# Se for '\n', finaliza busca
    		addi $t9, $t9, 1              	# Incrementa contador de caracteres
    		addi $t0, $t0, 1             	# Avança ponteiro no buffer
    		j   loop_prox_linha             	# Continua buscando

	fim_linha:
    		addi $t0, $t0, 1              # Move ponteiro para depois do '\n'
    		move $v0, $t9                 # Retorna tamanho da linha
    		jr   $ra                      # Retorna da função


#Funcao free -> 
free:
	stack_reg
	lb $t0, 0($a0)
	sb $zero, 0($a0)
	addi $a0, $a0, 1
	beqz $t0, voltar
	j free


	
