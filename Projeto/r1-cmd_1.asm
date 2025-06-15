.data
contadores: .space 160         #40 apartamentos × 4 bytes = 160 bytes
nomes:      .space 10000       #40 × 5 moradores × 20 bytes = 4.000 bytes
nomeTeste: .asciiz "Samara Lins"
input: .space 100   #espaço para armazenar uma string de entrada (ex: "ad_morador-303-Joao Gomes")
estado_ap: .space 40   # 10 andares * 4 ap = 40 apartamentos
                       # 0 = vazio, 1 = não vazio

.text

# ------------------- função registrarMorador
registrarMorador:
    # Calcular o índice do apartamento: (andar - 1) * 4 + (apto - 1)
    addi $t0, $a0, -1       #$t0 = andar - 1
    mul $t0, $t0, 4         #$t0 = (andar - 1) * 4
    addi $t1, $a1, -1       #$t1 = apto - 1
    add $t0, $t0, $t1       #$t0 = índice final do apartamento

    # Acessa contador de moradores: contadores + 4 * índice
    la $t2, contadores
    mul $t3, $t0, 4
    add $t2, $t2, $t3
    lw $t4, 0($t2)          #$t4 = número de moradores atuais

    li $t5, 5
    bge $t4, $t5, limite_moradores_excepetion

    # Calcula offset do nome: nomes + (índice * 100) + (morador * 20)
    la $t6, nomes
    mul $t7, $t0, 100       #$t7 = base do apartamento
    mul $t8, $t4, 20        #$t8 = slot do morador
    add $t7, $t7, $t8       
    add $t6, $t6, $t7       #$t6 = endereço onde o nome será salvo

    # usa memcpy
    move $a0, $t6           #destino
    move $a1, $a2           #origem (nome)
    # $a3 já contém o tamanho do nome
    jal memcpy

    # Atualiza contador de moradores
    addi $t4, $t4, 1
    sw $t4, 0($t2)

    li $v0, 0
    jr $ra

j limite_moradores_excepetion
    
 #---------------------- comando adicionar morador   
 ad_morador_fn:

    # [1] Extrair número do apartamento (option1) 

    li $a0, 1                 #$a0 = 1, o primeiro argumento (303)
    la $a1, input             #$a1 - endereço do input string
    jal get_funcao            #chama get_fn_option(1, input), resultado no $v0

    move $t0, $v0             #$t0 -> ponteiro para a string "303"

    move $a0, $t0             #prepara argumento para str_to_int
    jal str_to_int            #converte string "303" para inteiro, resultado em $v0

    move $t1, $v0             #$t1 -> valor inteiro do apartamento (ex: 303)

    move $a0, $t0             #libera string "303" da heap
    jal free

    # [2] Validar se o número do apartamento é válido 

        # Dividir 303 → andar = 3, apto = 3
    li $t2, 100
    divu $t1, $t2             #divide 303 por 100
    mflo $t3                  #$t3 -> andar (303 / 100) = 3
    mfhi $t4                  #$t4 -> apto (303 % 100) = 3

    li $t5, 1
    li $t6, 10
    blt $t3, $t5, invalid_ap_exception   #andar < 1 -> inválido
    bgt $t3, $t6, invalid_ap_exception   #andar > 10 -> inválido

    li $t7, 4
    blt $t4, $t5, invalid_ap_exception    #apto < 1 -> inválido
    bgt $t4, $t7, invalid_ap_exception    #apto > 4 -> inválido

    # [3] Extrair nome do morador (option2) 

    li $a0, 2
    la $a1, input
    jal get_fn_option         #retorna ponteiro para string do nome em $v0

    move $a2, $v0             #$a2 -> ponteiro para nome (ex: "Joao Gomes")

    move $a0, $a2             #calcula tamanho da string
    jal get_tamanho_str
    move $a3, $v0             #$a3: tamanho da string do nome

    # [4] Registrar morador (andar, apto, nome, tam_nome) 

    move $a0, $t3             #$a0: andar
    move $a1, $t4             #$a1: apto
    # $a2: nome, $a3: tam_nome (já estão prontos)
    jal registrarMorador      #tenta adicionar o morador, retorno em $v0

    # [5] Checar resultado da função 

    beq $v0, $zero, adicionar_morador_sucess    # se $v0 == 0, sucesso
    
    # Se número anterior de moradores era 0, marcar como "não vazio"
    beq $t5, $zero, marcar_nao_vazio
    j adicionar_morador_sucess

marcar_nao_vazio:
    la $t0, estado_ap
    add $t0, $t0, $t8       # índice direto
    li $t2, 1
    sb $t2, 0($t0)          # estado = 1 (não vazio)


j adicionar_morador_sucess

j invalid_ap_exception 

j limite_moradores_excepetion





