; ======================================================================
; Projeto: Sistema Operacional Controlador de Memória - Atmega2560
; Integrantes:
; Guilherme Resende - 202402075365 - TA
; Guilherme Dias Batista - 202402972091 - TA
; André Casemiro - 202303100418 - TA
; Pedro Caravellos - 202302174264 - TA
; Guilherme Maranhão - 202301165784 - TA
; Vitor Ribeiro - 202301215145 - TA
; ======================================================================

; Configuração de Endereços
.equ TABLE_ASCII_START = 0x200    ; Endereço inicial da tabela ASCII
.equ SEQUENCE_START = 0x300       ; Início das sequências de caracteres

; Configuração de Portas
.equ INPUT_PORT = PIND            ; Porta de entrada
.equ INPUT_DDR = DDRD             ; Registrador de direção da porta de entrada
.equ OUTPUT_PORT = PORTC          ; Porta de saída
.equ OUTPUT_DDR = DDRC            ; Registrador de direção da porta de saída

; Definição de Registradores
.def temp = r16                  ; Registrador temporário
.def command = r17               ; Registrador para armazenar o comando lido
.def data = r18                  ; Registrador para dados de entrada

; ======================================================================
; Segmento de Código
.cseg
.org 0x0000

; Reset Vector
rjmp start

; ======================================================================
; Configuração de Portas
config_ports:
    ; Configurar porta de entrada
    clr r16                     ; R16 = 0 (entrada)
    out INPUT_DDR, r16          ; Configura todos os pinos de INPUT_PORT como entrada

    ; Configurar porta de saída
    ldi r16, 0xFF               ; R16 = 0xFF (saída)
    out OUTPUT_DDR, r16         ; Configura todos os pinos de OUTPUT_PORT como saída

    ret

; ======================================================================
; Sub-rotina para criar a tabela ASCII na memória
create_ascii_table:
    ; Inicializar o endereço base
    ldi ZH, high(TABLE_ASCII_START) ; Parte alta do endereço
    ldi ZL, low(TABLE_ASCII_START)  ; Parte baixa do endereço

    ; Adicionar letras maiúsculas (A = 0x41 a Z = 0x5A)
    ldi temp, 0x41
add_uppercase:
    st Z+, temp                 ; Armazena o caractere atual e incrementa Z
    inc temp                    ; Próxima letra
    cpi temp, 0x5B              ; Comparar com 'Z' + 1
    brne add_uppercase          ; Repetir até 0x5A

    ; Adicionar letras minúsculas (a = 0x61 a z = 0x7A)
    ldi temp, 0x61
add_lowercase:
    st Z+, temp
    inc temp
    cpi temp, 0x7B              ; Comparar com 'z' + 1
    brne add_lowercase

    ; Adicionar dígitos (0 = 0x30 a 9 = 0x39)
    ldi temp, 0x30
add_digits:
    st Z+, temp
    inc temp
    cpi temp, 0x3A              ; Comparar com '9' + 1
    brne add_digits

    ; Adicionar o espaço (0x20)
    ldi temp, 0x20
    st Z+, temp

    ; Adicionar o caractere <ESC> (0x1B)
    ldi temp, 0x1B
    st Z+, temp

    ret                         ; Retorna ao chamador

; ======================================================================
; Sub-rotina para processar comandos
process_command:
    ; Comando 0x1C: Ler sequência de caracteres
    cpi command, 0x1C
    breq read_sequence

    ; Comando 0x1D: Contar caracteres
    cpi command, 0x1D
    breq count_characters

    ; Comando 0x1E: Contar ocorrências de um caractere específico
    cpi command, 0x1E
    breq count_occurrences

    ret                         ; Retorna se o comando não for reconhecido

; Sub-rotina para ler sequência de caracteres
read_sequence:
    ; Lógica para ler e armazenar a sequência
    ldi temp, 0x20              ; Caractere de espaço como marcador
    st Z+, temp                 ; Adiciona marcador à sequência
    ret

; Sub-rotina para contar caracteres
count_characters:
    ; Lógica para contar caracteres na tabela
    ret

; Sub-rotina para contar ocorrências de um caractere
count_occurrences:
    ; Lógica para contar ocorrências de um caractere específico
    ret

; ======================================================================
; Loop principal
start:
    ; Configurar portas
    call config_ports

    ; Criar tabela ASCII
    call create_ascii_table

    ; Loop principal do sistema
main_loop:
    ; Ler o comando da porta de entrada
    in command, INPUT_PORT

    ; Processar o comando
    call process_command

    ; Continuar o loop principal
    rjmp main_loop

; ======================================================================
; Fim do Código