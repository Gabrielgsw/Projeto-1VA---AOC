.data
	int_to_str_buffer: .space 4
	
	# Nome dos comandos
	debug: .asciiz " "
	ad_morador: .asciiz "ad_morador"
	ad_auto: .asciiz "ad_auto"
	rm_morador: .asciiz "rm_morador"
	rm_auto: .asciiz "rm_auto"
	
	info_ap: .asciiz "info_ap"
	limpar_ap: .asciiz "limpar_ap"
	info_geral: .asciiz "info_geral"
	
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
.globl criar_condominio, strcmp, strncmp, memcpy, int_to_str, int_to_str_buffer, str_to_int, get_tamanho_str, get_indice_ap, get_funcao, processar_comando, free 
	
############################# FUNCAO DE ESTRUTURA DO CONDOMINIO #############################

# Função com o propósito de criar a estrutura do apartamento, com 10 andares e 4 apartamentos por andar
# $a0 -> início do apartamento/condomínio
criar_condominio:
	move $t6, $a0				# Salvar o endereço do início do apartamento
		
	li $t0, 0				# Contador dos andares
	li $t1, 0				# Contador dos apartamentos
		
	li $t2, 0				# Contador dos números de apartamentos
	li $t3, 101				# Apartamento inicial 
		
	li $t4, 10				# Quantidade de andares
	li $t5, 4				# Quantidade de apartamentos por andar
		
	loop_preencher_apartamento:
		blt $t0, $t4, loop_por_andar	# Caso não passou por todos os andares (total andar < contador andar), vai pro preenchimento do andar
			
		j sair_loop
		
	loop_por_andar:
		blt $t1, $t5, preencher_ap 	# Caso ele não passou por todos os apartamentos dos andares (
		addi $t0, $t0, 1			# Passa para outro apartamento
		li $t1, 0			# reinicia o contador para 1
		addi $t3, $t3, 100		# Vai para outro andar
			
		j loop_preencher_apartamento	
			
		
	preencher_ap:
		add $t8, $t3, $t1		# Adiciona o apartamento com o numero inicial na contagem
		sw $t8, 0($t6)			# Armazena o valor no array
			
		addi $t2, $t2, 1			# +1 no contador do apartamento
		addi $t1, $t1, 1			# +1 no contador do número de apartamentos
		addi $t6, $t6, 40
		
		j loop_por_andar
		
	sair_loop:
		jr $ra



############################# FUNCOES UTEIS PARA COMPARAR STRINGS #############################


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
	
	end_strcmp:
		voltar		
	
	
# Função strncmp -> compara duas strings em um certo tamanho n
# $a0 -> endereco da primeira string
# $a1 -> endereco da segunda string
# $a3 -> contador maximo de comparacoes
strncmp:                                
stack_reg
    	add $t0, $zero, $a0 			# Armazena o endereco da str1
	add $t1, $zero, $a1  			# Armazena o endereco da str2
	add $t4, $zero, $zero			# Registrador para o contador de bytes   
    
    strncmp_loop:                       
        lb $t2, 0($t0)                		# Armazenar o primeiro caractere da palavra 1
        lb $t3, 0($t1)				# Armazenar o primeiro caractere da palavra 2
        addi $v0, $zero, -1              		# Caso 1: Caractere str1 "menor" que str2 | Caso seja verdade, resultado = -1
        blt $t2, $t3, end_strncmp       		# Finalizar a função
        addi $v0, $zero, 1             		# Caso 2: Caractere str1 "maior" que str2 | Caso seja verdade, resultado = 1
	bgt $t2, $t3, end_strncmp           	# Finalizar a função
	add $v0, $zero, $zero               	# Caso 3: Caractere str1 "igual" ao str2 | Caso seja verdade, resultado = 0
	beqz $t2, end_strncmp               	# Observar se as strings chegaram ao seu final, com o valor permanecendo 0                             
	addi $t0, $t0, 1                  	# Passar para outro caractere  
	addi $t1, $t1, 1              		# Passar para outro caractere
	addi $t4, $t4, 1    			# Adicionar no contador
	bge $t4, $a3, end_strncmp                	# Caso chegue no máximo, finalize a função
	
	j strncmp_loop                      	# Refaz o loop
    
    end_strncmp:
        voltar
				

# Funcao memcpy -> copia um total de bytes dado um número do local e salva em memoria
# $a0 -> destino
# $a1 -> source
# $a2 -> numero
memcpy:                                 
	stack_reg
	add $t0, $zero, $a0                 	# escreve o endereço destino para t0
    	add $t1, $zero, $a1                 	# escreve o endereço source para t1
    	add $t2, $zero, $zero               	# escreve 0 em t2 para o contador
    	addi $t4, $zero, 10			# armazena '\n' em ASCII para o fim da operação

	loop:
    		bge $t2, $a2, end_memcpy        	# caso i seja igual a num, encerra a função
        		lb $t3, 0($t1)                  	# carrega o byte de source em t3
        		beq $t3, $t4, end_memcpy		# se o byte for igual a 10('\n') -> fim
        		sb $t3, 0($t0)                  	# grava o byte de t3 em destination
        		addi $t0, $t0, 1                	# incrementa destination
        		addi $t1, $t1, 1                	# incrementa source
        		addi $t2, $t2, 1                	# incrementa i
       	 	
       	 	j loop                   # refaz o loop

	
	end_memcpy:
		addi $t0, $t0, 1
        		sb $zero, 0($t0)
        		voltar
        		


############################# FUNCOES UTEIS PARA MANIPULACAO DE DADOS #############################
	
						
# Funcao int_to_str -> Converte um número inteiro (0 a 9999) para string decimal sem zeros a esquerda
# $a0 -> o numero a ser convertido
# $a1 -> tamanho maximo do buffer de saida
# $a2 -> ponteiro para o buffer de saida
int_to_str:
	stack_reg
	li $t0, 1000				# Divisor inicial (ASCII)
	li $t1, 10				# Base decimal da divisao
	
	loop_transformar:
		beqz $a1, end_int_to_str		# Se chegou no maximo do buffer de saida, finalize a funcao
		
		div $a0, $t0
					
		mflo $t2				# Digito atual
		mfhi $a0				# O resto vai ser util para as outras divisoes
		
		addi $t2, $t2, 48		# Conversao pra ASCII
        		sb $t2, 0($a2)			# Salvar o caractere no buffer de saida

        		div $t0, $t1			
        		mflo $t0				# Divisor / Base decimal da divisao					
        		addi $a1, $a1, -1		# Reduz a leitura da string a ser transformada
        		addi $a2, $a2, 1			# Passa para o proximo caractere da string
        		j loop_transformar
    
	end_int_to_str:
		voltar

# Funcao str_to_int -> Converte uma string decimal (0-9) em um inteiro 32 bits
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
       	 	blt $t1, $t4, erro_transformacao		# Se o caractere for menor que 0
        		bgt $t1, $t5, erro_transformacao		# Se o caractere for maior que 9
        		sub $t1, $t1, $t4			# Conversao em ASCII	
        		mul $t0, $t0, 10				# resultado = resultado * 10
        		add $t0, $t0, $t1			# Soma o digito transformado
        		addi $a0, $a0, 1				# Vai para o proximo caractere
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
    	move $t0, $a0                  		# Pega o endereco da string a ser lida
    	li $t1, 0                             	# Contador dos tamanhos

	loop_tamanho:      
        		lb $t2, 0($t0)                	# Carrega o byte a ser lido nesse loop
        		beq $t2, $zero, fim_tamanho     	# Se o caractere e nulo, entao acabou
        		beq $t2, 10, fim_tamanho         	# Se o caractere e \n, entao acabou
        		addi $t0, $t0, 1                 	# Pula pro proximo byte
        		addi $t1, $t1, 1               	# +1 pro contador
        		
        		j loop_tamanho                  	# Volta ate o loop acabar

    	fim_tamanho:
        		move $v0, $t1                    # Retorna o valor da string em $v0
        		voltar


############################# FUNCOES UTEIS PARA MOVIMENTACAO NO CONDOMINIO #############################

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
	


# Funcao get_funcao -> Extrair aopção digitada pelo usuário através dos hifens
# $a0 -> Opção desejada (em inteiro)
# $a1 -> Registradores que armazenem as funcoes
# $t1 -> Separador(hifen)
get_funcao:
	stack_reg                                               		# Salva os registradores na pilha para preservar o estado atual
    	add $t0, $zero, $a1                                              	# $t0 recebe o ponteiro para a string de entrada (input)
    	la $t1, separador                                                 	# Carrega o endereço do caractere separador (ex: '-') em $t1
    	lb $t1, 0($t1)                                                    	# Carrega o valor ASCII do separador em $t1
    	add $t2, $a0, $zero                                               	# $t2 armazena a opção que desejamos extrair

    	procurar_hifen:                                                   	
        		lb $t3, 0($t0)                                           	# Carrega o byte atual da string em $t3
        		addi $t0, $t0, 1                                         	# Avança para o próximo byte da string
        		beqz $t3, fim_get_funcao                                 	# Se encontrar o final da string (\0), entao fim da execução
        		bne $t3, $t1, procurar_hifen                              	# Se não for o separador, continua procurando
        		addi $t2, $t2, -1                                        	# Reduz o contador de posição desejada
        		beqz $t2, guardar_funcao                                 	# Se posição chegou a 0, encontramos o separador da opção desejada
        		j procurar_hifen                                         	# Faz o loop
    
    	guardar_funcao:                                                   	
		add $t2, $t0, $zero                                      	# $t2 agora aponta para o início da opção desejada
	
        		achar_funcao:                                            
        			lb $t3, 0($t2)                                  	# Carrega byte atual em $t3
            		addi $t2, $t2, 1                                	# Avança para o próximo byte
            		beqz $t3, if_achar_funcao                       	# Se for byte nulo, chegou ao fim da string -> pula para próxima etapa
            		bne $t3, $t1, achar_funcao                       	# Se não for o separador, continua
            		addi $t2, $t2, -1                                	# Caso tenha encontrado o separador, volta um byte para marcar o fim da string
        
        		if_achar_funcao:                                          	# Calcula tamanho e aloca espaço na heap
            		sub $t2, $t2, $t0                                	# Calcula o tamanho da substring: fim - início
            		addi $t2, $t2, 1                                 	# Adiciona 1 para incluir o byte nulo '\0'
            		add $a0, $zero, $t2                              	# Define a quantidade de memória a ser alocada
            		addi $v0, $zero, 9                               	# syscall 9: alocação de memória na heap
            		syscall                                           	# Chama o sistema para alocar memória
            		add $v1, $zero, $t2                              	# Armazena o tamanho da string no registrador $v1
            		addi $t2, $t2, -1                                	# Remove o espaço extra (deixando apenas o tamanho real da string)
            		add $a2, $zero, $t2                              	# Define o tamanho da string a ser copiada
            		add $a1, $zero, $t0                              	# Ponteiro para o início da substring na string de entrada
            		add $a0, $zero, $v0                              	# Ponteiro para o início do espaço alocado na heap (destino)
            		addi $sp, $sp, -4                                	# Reserva espaço na pilha para salvar $ra
            		sw $ra, 0($sp)                                	# Salva o valor de $ra na pilha
            		jal memcpy                                      	# Chama a função memcpy para copiar a substring
            		lw $ra, 0($sp)                                	# Recupera o valor de $ra da pilha
            		addi $sp, $sp, 4                                	# Libera o espaço da pilha
            		voltar						# Finaliza a execução                                         	

    	fim_get_funcao:                                                  	# Caso a opção não tenha sido encontrada
        		unstack_reg                                              	# Restaura os registradores salvos
        		j op_invalida                                           	# Desvia para a função de erro "op_invalida"

	
	
# Funcao processar_comando -> Processar o input do usuário para descobri qual comendo está sendo utilizado
# input -> entrada do usuário
# separador -> seria o 'hifen' -
# $v0 -> Resultado do comando que foi digitado
processar_comando:
    la $t0, input                                                       	# Armazena o input do usuário
    lb $t1, 0($t0)
    beqz $t1, fim_processar
    addi $t1, $zero, -1                                               	# Tamanho do nome do comando
    la $t3, separador                                                   	# Carrega o hifen (-)
    lb $t3, 0($t3)
    
    loop_processar:                                                      
        lb $t2, 0($t0)                                                  	# Carrega o byte atual lido de input em $t2
        beqz $t2, comparar_cmd                                            	# Se chegar no fim da string, desvia para o comparador de comando
        beq $t2, $t3, comparar_cmd                                       	# Se encontrar o separador, vai pro switch case
        addi $t0, $t0, 1                                                	# +1 no cursor da string input  
        addi $t1, $t1, 1                                                	# +1 no tamanho do nome do comando
        
        j loop_processar                                                  	# Refaz o loop
    
    
    # Switch case para saber qual o comando que foi digitado pelo usuario
    comparar_cmd:                          
        la $a0, ad_morador                                           	# Carrega para ver se é 'ad_morador'
        li $a3, 10                                                      	# Tamanho do comando a ser comparado
        la $a1, input                                                   	# Carrega a string de entranda em $a1
        add $a3, $zero, $t1                                             	# Carrega o tamanho do nome do comando
        jal strncmp                                                     	# Vai pro strncmp para ver ser é a mesma string
        beqz $v0, ad_morador_fn                                         	# Caso foi, ele redireciona pra funcao do comando

        la $a0, rm_morador                                              	# Caso 'rm_morador'
        li $a3, 10
        jal strncmp                                                     
        beqz $v0, rm_morador_fn                                         

        la $a0, ad_auto                                                 	# Caso 'ad_auto'
        li $a3, 7
        jal strncmp                                                    
        beqz $v0, ad_auto_fn                                            

        la $a0, rm_auto                                                 	# Caso 'rm_auto'
        li $a3, 7
        jal strncmp                                                     
        beqz $v0, rm_auto_fn                                            
        
        la $a0, salvar                                                  	# Caso 'salvar'
        li $a3, 6
        jal strncmp                                                     
        beqz $v0, salvar_fn                                             

        la $a0, limpar_ap                                               	# Caso 'limpar_ap'
        li $a3, 9
        jal strncmp                                                     
        beqz $v0, limpar_ap_fn                                          

        la $a0, recarregar                                              	# Caso 'recarregar'
        li $a3, 10
        jal strncmp                                                    
        beqz $v0, recarregar_fn                                         

	# Verificar como aplicar
        la $a0, info_geral                                              	# Caso 'info_geral'
        li $a3, 10
        jal strncmp                                                     
        #beqz $v0, info_geral_fn                                         

        la $a0, formatar                                                	# Caso 'formatar'
        li $a3, 8
        jal strncmp                                                     
        beqz $v0, formatar_fn                                           
        
        la $a0, info_ap                                               	# Caso 'info_ap'
        li $a3, 7
        jal strncmp                                                     
        beqz $v0, info_ap_fn                                           

        j cmd_invalido                                             	# Caso não tenha nenhum acesso, traz a funcao de cmd invalido default
    
    fim_processar:                                                      
        j start                                                      	# Volta pro inicio, caso chamado novamente, volta pro inicio


#Funcao free -> Libera uma string alocada dinamicamente
# $a0 -> Memória alocada a ser liberada
free:
	stack_reg
	lb $t0, 0($a0)			# Primeiro byte da string
	sb $zero, 0($a0)			# Zera o byte lido	
	addi $a0, $a0, 1			# Passa pro próximo caractere
	beqz $t0, end_free		# Se era o último byte, finaliza
	
	j free				# Refaz o loop

	end_free:
		voltar
