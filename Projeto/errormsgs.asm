.data


invalid_ap_exception: .asciiz "Apartamento invalido!\n"
limite_moradores_excepetion: .asciiz "O limite de moradores foi atingido!\n"
ap_vazio_exception: .asciiz "Este apartamento ja esta vazio!\n"
morador_inexistente_exception: .asciiz "Morador nao existente\n"
espaco_vazio_exception: .asciiz "Espaco nao encontrado!\n"
adicionar_morador_sucess: .asciiz "Morador adicionado com sucesso!\n"
remover_morador_sucess: .asciiz "Morador removido com sucesso!\n"
veiculo_invalido_exception: .asciiz "Veiculo invalido!\n"
limite_vagas_exception: .asciiz "O limite de vagas foi atingido!\n"
adicionar_automovel_sucess: .asciiz "Automovel adicionado com sucesso!\n"
salvar_sucess: .asciiz "Dados salvos com sucesso!\n"
recarregar_sucess: .asciiz "Dados recarregados com sucesso!\n"
arquivo_exception: .asciiz "O arquivo nao foi encontrado! "

cmd_invalido_exception: .asciiz "Comando invalido!\n"
op_invalida_exception: .asciiz "Opcao invalida!\n"
new_line: .asciiz "\n"
tab: .asciiz "\t"

# cmd_6

ap_num: .asciiz "AP: "
moradores_ap: .asciiz "Moradores:\n"
carro_ap: .asciiz "Carro:\n"
moto_ap: .asciiz "Moto:\n"
modelo_ap: .asciiz "Modelo: "
cor_ap: .asciiz "Cor: "
unexpected_error1: .asciiz " - Log: Flag de automovel nao reconhecida\n"
unexpected_error2: .asciiz " - Log: Print all apartments\n"
unexpected_error3: .asciiz " - Log: Print one apartments\n"


add_automovel_vazio_exception: .asciiz "Nao e possivel adicionar o automovel, pois o apartamento esta vazio\n"
remover_automovel_sucess: .asciiz "Automovel removido com sucesso!\n"


.text
.globl tab,op_invalida_exception,ap_num,moradores_ap,carro_ap,moto_ap,cor_ap,unexpected_error1,unexpected_error2,unexpected_,add_automovel_vazio_exception,remover_automovel_sucess,invalid_ap_exception,cmd_invalido_exception,arquivo_exception,salvar_sucess,limite_vagas_exception,adicionar_automovel_exception,limite_moradores_excepetion,ap_vazio_exception,morador_inexistente_exception,espaco_vazio_exception,adicionar_morador_sucess,remover_morador_sucess,veiculo_invalido_exception,


# funcoes para informar erro/sucesso durante a execucao do programa


invalid_ap:
    la $a0, invalid_ap_exception          # carrega o texto
    jal print_str                           # jump para funcao de printar o texto
    j start                                 # retorna ao inicio do programa

limite_moradores:
    la $a0, limite_moradores_excepetion
    jal print_str
    j start

ap_vazio:
    la $a0, ap_vazio_exception
    jal print_str
    j start

morador_inexistente:
    la $a0, morador_inexistente_exception
    jal print_str
    j start

unexpected_error1_ap:
    la $a0, unexpected_error1
    jal print_str
    j start

adicionar_morador:
    la $a0, adicionar_morador_sucess
    jal print_str
    j start

remover_morador:
    la $a0, remover_morador_sucess
    jal print_str
    j start

veiculo_invalido:
    la $a0, veiculo_invalido_exception
    jal print_str
    j start

limite_vagas:
    la $a0, limite_vagas_exception
    jal print_str
    j start

adicionar_automovel:
    la $a0, adicionar_automovel_sucess
    jal print_str
    j start

salvar:
    la $a0, salvar_sucess
    jal print_str
    j start

recarregar:
    la $a0, recarregar_sucess
    jal print_str
    j start


cmd_invalido:                                                  
    la $a0, cmd_invalido_exception                                               
    jal print_str                                                       
    j start                                                             

op_invalida:                                                        
    la $a0, op_invalida_exception                                                
    jal print_str                                                       
    j start                                                             

arquivo_erro:
    la $a0, arquivo_exception
    jal print_str
    la $a0, arquivo
    jal print_str
    la $a0, new_line
    jal print_str
    j start

new_line:
    la $a0, new_line
    addi $sp, $sp, -4           
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
tab:
    la $a0, tab
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


add_automovel_vazio:                                                        
    la $a0, add_automovel_vazio_exception                                               
    jal print_str                                                       
    j start                                                             

remover_automovel:                                                        
    la $a0, remover_automovel_sucess                                                
    jal print_str                                                       
    j start                                                             

 


# cmd_6

unexpected_error1_info:
    la $a0, unexpected_error1   # carrega o texto
    jal print_str               # jump para funcao de printar o texto
    j start			# retorna ao inicio do programa
unexpected_error2_info:
    la $a0, unexpected_error2
    jal print_str
    j start
unexpected_error3_info:
    la $a0, unexpected_error3
    jal print_str
    j start
    
ap_vazio:
    la $a0, ap_vazio_exception     #carrega a mensagem de erro
    addi $sp, $sp, -4		   # decrementa stack pointer
    sw $ra, 0($sp)		  # armazena no registrador
    jal print_str		  # jump para printr a mensagem
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
ap:
    la $a0, ap_num
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
moradores:
    la $a0, moradores_ap
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
carro:
    la $a0, carro_ap
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
moto:
    la $a0, moto_ap
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
modelo:
    la $a0, modelo_ap
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
cor:
    la $a0, cor_ap
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

