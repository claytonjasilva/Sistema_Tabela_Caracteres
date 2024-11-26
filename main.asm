; ======================================================================
; Projeto: Sistema Operacional Controlador de Mem�ria - Atmega2560
; Integrantes:
; Guilherme Resende - 202402075365 - TA
; Guilherme Dias Batista - 202402972091 - TA
; Andr� Casemiro - 202303100418 - TA
; Pedro Caravellos - 202302174264 - TA
; Guilherme Maranh�o - 202301165784 - TA
; Vitor Ribeiro - 202301215145 - TA
; ======================================================================

; Configura��o de Endere�os
.equ TABLE_ASCII_START = 0x200    ; Endere�o inicial da tabela ASCII
.equ SEQUENCE_START = 0x300       ; In�cio das sequ�ncias de caracteres

; Configura��o de Portas
.equ INPUT_PORT = PIND            ; Porta de entrada
.equ INPUT_DDR = DDRD             ; Registrador de dire��o da porta de entrada
.equ OUTPUT_PORT = PORTC          ; Porta de sa�da
.equ OUTPUT_DDR = DDRC            ; Registrador de dire��o da porta de sa�da

; Defini��o de Registradores
.def temp = r16                  ; Registrador tempor�rio
.def command = r17               ; Registrador para armazenar o comando lido
.def data = r18                  ; Registrador para dados de entrada

; ======================================================================
; Segmento de C�digo
.cseg
.org 0x0000

; Reset Vector
rjmp start

; ======================================================================
; Configura��o de Portas
config_ports:
    ; Configurar porta de entrada
    clr r16                     ; R16 = 0 (entrada)
    out INPUT_DDR, r16          ; Configura todos os pinos de INPUT_PORT como entrada

    ; Configurar porta de sa�da
    ldi r16, 0xFF               ; R16 = 0xFF (sa�da)
    out OUTPUT_DDR, r16         ; Configura todos os pinos de OUTPUT_PORT como sa�da

    ret

; ======================================================================
; Sub-rotina para criar a tabela ASCII na mem�ria
create_ascii_table:
    ; Inicializar o endere�o base
    ldi ZH, high(TABLE_ASCII_START) ; Parte alta do endere�o
    ldi ZL, low(TABLE_ASCII_START)  ; Parte baixa do endere�o

    ; Adicionar letras mai�sculas (A = 0x41 a Z = 0x5A)
    ldi temp, 0x41
add_uppercase:
    st Z+, temp                 ; Armazena o caractere atual e incrementa Z
    inc temp                    ; Pr�xima letra
    cpi temp, 0x5B              ; Comparar com 'Z' + 1
    brne add_uppercase          ; Repetir at� 0x5A

    ; Adicionar letras min�sculas (a = 0x61 a z = 0x7A)
    ldi temp, 0x61
add_lowercase:
    st Z+, temp
    inc temp
    cpi temp, 0x7B              ; Comparar com 'z' + 1
    brne add_lowercase

    ; Adicionar d�gitos (0 = 0x30 a 9 = 0x39)
    ldi temp, 0x30
add_digits:
    st Z+, temp
    inc temp
    cpi temp, 0x3A              ; Comparar com '9' + 1
    brne add_digits

    ; Adicionar o espa�o (0x20)
    ldi temp, 0x20
    st Z+, temp

    ; Adicionar o caractere <ESC> (0x1B)
    ldi temp, 0x1B
    st Z+, temp

    ret                         ; Retorna ao chamador

; ======================================================================
; Sub-rotina para processar comandos
process_command:
    ; Comando 0x1C: Ler sequ�ncia de caracteres
    cpi command, 0x1C
    breq read_sequence

    ; Comando 0x1D: Contar caracteres
    cpi command, 0x1D
    breq count_characters

    ; Comando 0x1E: Contar ocorr�ncias de um caractere espec�fico
    cpi command, 0x1E
    breq count_occurrences

    ret                         ; Retorna se o comando n�o for reconhecido

; Sub-rotina para ler sequ�ncia de caracteres
read_sequence:
    ; L�gica para ler e armazenar a sequ�ncia
    ldi temp, 0x20              ; Caractere de espa�o como marcador
    st Z+, temp                 ; Adiciona marcador � sequ�ncia
    ret

; Sub-rotina para contar caracteres
count_characters:
    ; L�gica para contar caracteres na tabela
    ret

; Sub-rotina para contar ocorr�ncias de um caractere
count_occurrences:
    ; L�gica para contar ocorr�ncias de um caractere espec�fico
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
; Fim do C�digo