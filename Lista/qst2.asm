# Atividade 1VA - Arquitetura e Organizacao de Computadores [2025.1]
# Gabriel Germano dos Santos Wanderley
# Samara Accioly
# Vitor Barros de Carvalho
# Wellington Viana da Silva Junior
# Arquivo referente as funcoes de comando do projeto

.data
io_control: .word 0xffff                    # endereco base dos registradores MMIO

.text

main:
    lui $s0, 0xFFFF                         # $s0 = endereco base dos registradores MMIO (0xFFFF0000)
    j main_loop                             # vai para o loop principal

main_loop:
# Espera ate que receiver ready seja 1
wait_receiver_ready:
    lw $t0, 0($s0)                          # $t0 = receiver ready
    beqz $t0, wait_receiver_ready           # se receiver ready == 0, espera

    # Le dado do receiver
    lw $t1, 4($s0)                          # $t1 = receiver data

# Espera ate que transmitter ready seja 1
wait_transmitter_ready:
    lw $t2, 8($s0)                          # $t2 = transmitter ready
    beqz $t2, wait_transmitter_ready        # se transmitter ready == 0, espera

    # Escreve dado no transmitter
    sw $t1, 12($s0)                         # escreve receiver data em transmitter data

    j main_loop                             # repete o loop
