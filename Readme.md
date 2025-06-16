# Grupo:
### -  Gabriel Germano
### -  Samara Accioly
### -  Vitor Barros
### -  Wellington Viana

# Projeto Condomínio/Lista

O objetivo deste projeto é implementar um sistema de cadastro de pessoas e automóveis para um condomínio. Este sistema de cadastro deve ser operado através de um terminal (shell) que funciona como um interpretador de comandos de texto, ou seja, o sistema vai ficar constantemente checando por entradas de texto (string) e interpretando o que for recebido a partir de uma lista de comandos que o sistema deve ser capaz de executar. Os comandos que devem ser implementados serão descritos adiante na seção de requisitos de projeto. 


# Estrutura do Projeto

```bash
│
│ arquivo.txt                           # Output do projeto
├───Lista                               # Diretório relacionado à Lista de Exercícios
│   └───memcpy.asm                      # Questão 1, letra b)
│   └───strcpy.asm                      # Questão 1, letra a)
│   └───strcmp.asm                      # Questão 1, letra c)
│   └───strncmp.asm                     # Questão 1, letra d)
│   └───strcat.asm                      # Questão 1, letra a)
│   └───qst2.asm                        # Questão 2
├───Projeto                             # Diretório relacionado ao projeto de condomínios
│   └───main.asm                        # Classe principal, onde vai definitivamente rodar o código
│   └───errormsgs.asm                   # Classe relacionada ao armazenamento de logs do sistema
│   └───utils.asm                       # Classe que contém funções úteis para o funcinamento como o strmcp, memcpy ou get_funcao
│   └───cmd_functions.asm               # Classe relacionada as funções do CMD (Requisitos)
```
